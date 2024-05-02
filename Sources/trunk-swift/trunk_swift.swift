import Foundation
import Logging

public struct TrunkLogHandler: LogHandler {
  public var label: String
  public var metadata: Logger.Metadata = [:]
  public var logLevel: Logger.Level = .trace  // Set the default log level to .trace

  private let colorReset = "\u{001B}[0m"  // Reset to default terminal color
  private let colors: [Logger.Level: (textColor: String, levelName: String)] = [
    .trace: ("\u{001B}[0;36m", "trace"),  // Cyan
    .debug: ("\u{001B}[0;34m", "debug"),  // Blue
    .info: ("\u{001B}[0;32m", "info"),  // Green
    .notice: ("\u{001B}[0;35m", "notice"),  // Magenta
    .warning: ("\u{001B}[0;33m", "warning"),  // Yellow
    .error: ("\u{001B}[0;31m", "error"),  // Red
    .critical: ("\u{001B}[0;97;41m", "critical"),  // Bright white text on red background
  ]

  public subscript(metadataKey key: String) -> Logger.Metadata.Value? {
    get { return metadata[key] }
    set { metadata[key] = newValue }
  }

  public init(label: String) {
    self.label = label
  }

  public func log(
    level: Logger.Level, message: Logger.Message, metadata: Logger.Metadata?, file: String,
    function: String, line: UInt
  ) {
    // Ensure we log messages of this level or higher
    if level >= logLevel {
      let colorPair = colors[level] ?? (textColor: colorReset, levelName: "\(level)")
      let formattedDate = ISO8601DateFormatter().string(from: Date())

      // Apply color to the timestamp and log level only
      print(
        "\(colorPair.textColor)\(formattedDate) \(colorPair.levelName)\(colorReset) : [\(label)] \(message)"
      )
    }
  }

  public mutating func setLogLevel(_ level: Logger.Level) {
    self.logLevel = level
  }
}

extension TrunkLogHandler {
  public static func bootstrap(withLogLevel level: Logger.Level = .trace) {
    LoggingSystem.bootstrap { label in
      var handler = TrunkLogHandler(label: label)
      handler.setLogLevel(level)
      return handler
    }
  }
}
