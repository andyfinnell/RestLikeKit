import Foundation

public protocol Loggable {
    func log(_ output: (String) -> Void)
}

extension String: Loggable {
    public func log(_ output: (String) -> Void) {
        output(self)
    }
}
