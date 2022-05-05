#if canImport(Foundation)
import Foundation
#endif

protocol DefaultInitializable {
    init()
}

extension Int: DefaultInitializable { }
extension Int8: DefaultInitializable { }
extension Int16: DefaultInitializable { }
extension Int32: DefaultInitializable { }
extension Int64: DefaultInitializable { }
extension UInt: DefaultInitializable { }
extension UInt8: DefaultInitializable { }
extension UInt16: DefaultInitializable { }
extension UInt32: DefaultInitializable { }
extension UInt64: DefaultInitializable { }

extension String: DefaultInitializable { }
extension Substring: DefaultInitializable { }
extension Character: DefaultInitializable {
    init() { self = " " }
}

extension Bool: DefaultInitializable { }
extension Double: DefaultInitializable { }
extension Float: DefaultInitializable { }

extension Array: DefaultInitializable { }
extension ArraySlice: DefaultInitializable { }
extension ContiguousArray: DefaultInitializable { }
extension Dictionary: DefaultInitializable { }
extension Set: DefaultInitializable { }
extension Optional: DefaultInitializable {
    public init() { self = .none }
}

#if canImport(Foundation)
extension Decimal: DefaultInitializable { }
extension UUID: DefaultInitializable { }
extension Date: DefaultInitializable { }
extension Data: DefaultInitializable { }
#endif
