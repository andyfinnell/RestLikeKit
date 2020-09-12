import Foundation
@testable import RestLikeKit

final class FakeLogger: LoggerType {
    func info(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        
    }
    
    func debug(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        
    }
    
    func error(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        
    }
    
    func fault(_ value: @autoclosure () -> Loggable, tag: LogTag) {
        
    }
}
