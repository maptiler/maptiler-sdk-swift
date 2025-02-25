//
//  MTLogger.swift
//  MapTilerSDK
//

/// Protocol requirement for all Logger objects.
public protocol MTLoggable: Sendable {
    func log(_ message: String, type: MTLogType) async
}

public class MTLogger {
    public static let infoMarker: String = "MTInfo"

    /// Add a log.
    public static func log(_ message: String, type: MTLogType) {
        Task {
            await MTLoggerInternal.shared.log(message, type: type)
        }
    }

    /// Print all current logs to the console.
    public static func printLogs() {
        Task {
            await MTLoggerInternal.shared.printLogs()
        }
    }

    /// Inject a custom logger conforming to the MTLoggable protocol.
    public static func setCustomLogger(_ logger: MTLoggable) {
        Task {
            await MTLoggerInternal.shared.setCustomLogger(logger)
        }
    }
}

package actor MTLoggerInternal {
    package enum Constants {
        static let maxLogCount: Int = 1000
        static let maxCountExceededMessage: String =
        "Maximum in-memory log count exceeded, earliest logs now accessible only through OS Logs."
    }

    package static var shared: MTLoggerInternal = MTLoggerInternal()
    private var logger: MTLoggable = OSLogger()

    private init() {}

    private var logs: [MTLog] = []

    package func log(_ message: String, type: MTLogType) async {
        Task {
            let log = MTLog(message: message, type: type)
            await handleLog(log)

            await logger.log(message, type: type)
        }
    }

    package func printLogs() {
        logs.forEach { log in
            print(log)
        }
    }

    package func setCustomLogger(_ logger: MTLoggable) {
        self.logger = logger
    }

    private func handleLog(_ log: MTLog) async {
        logs.append(log)

        if logs.count > Constants.maxLogCount {
            await logger.log(Constants.maxCountExceededMessage, type: .warning)

            logs.removeFirst()
        }
    }
}
