import Foundation
import os

public struct LogTag: RawRepresentable, Hashable {
    public let rawValue: String
    
    public static let http = LogTag("http")
    public static let general = LogTag("general")
    
    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }
    
    public init?(rawValue: String) {
        self.rawValue = rawValue
    }
}

public protocol LoggerType {
    func info(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func debug(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func error(_ value: @autoclosure () -> Loggable, tag: LogTag)
    func fault(_ value: @autoclosure () -> Loggable, tag: LogTag)
}

public protocol HasLogger {
    var logger: LoggerType { get }
}

public final class Logger: LoggerType {
    private var logs = [LogTag: OSLog]()
    
    public init() {}
    
    public func info(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value(), tag: tag, level: .info)
    }

    public func debug(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value(), tag: tag, level: .debug)
    }
    
    public func error(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value(), tag: tag, level: .error)
    }
    
    public func fault(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        print(value(), tag: tag, level: .fault)
    }
    
    private func print(_ value: @autoclosure () -> Loggable, tag: LogTag, level: OSLogType) {
        guard isEnabled else {
            return
        }
        
        let l = log(for: tag)
        value().log { string in
            os_log("%{public}@", log: l, type: level, string)
        }
    }

    private func log(for tag: LogTag) -> OSLog {
        guard let cachedLog = logs[tag] else {
            let subsystem = Bundle.main.bundleIdentifier ?? "com.losingfight.restlikekit.default"
            let log = OSLog(subsystem: subsystem, category: tag.rawValue)
            logs[tag] = log
            return log
        }
        return cachedLog
    }
    
    
    private var isEnabled: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
}
