import Foundation

@objc public class Sharing: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}
