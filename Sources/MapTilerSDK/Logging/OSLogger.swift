//
//  OSLogger.swift
//  MapTilerSDK
//

import Foundation
import os

package class OSLogger: MTLoggable, @unchecked Sendable {
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: String(describing: MTLog.self)
    )

    package func log(_ message: String, type: MTLogType) async {
        let logLevel = await MTConfig.shared.logLevel
        let verbose = logLevel == .debug(verbose: true)

        switch type {
        case .info:
            if logLevel != .none {
                logger.info("\(message)")
            }
        case .warning:
            if logLevel != .none {
                logger.warning("\(message)")
            }
        case .error:
            if (logLevel == .debug(verbose: false)) || verbose {
                logger.error("\(message)")
            }
        case .criticalError:
            if (logLevel == .debug(verbose: false)) || verbose {
                logger.critical("\(message)")
            }
        case .event:
            if verbose && logLevel != .none {
                logger.info("\(message)")
            }
        }
    }
}
