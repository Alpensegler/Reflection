public struct Property<T> {
    public let owner: Any.Type
    public let name: String
    public let type: Any.Type
    public let isVar: Bool
    public let offset: Int
    
    @usableFromInline
    func instance(_ propertyValue: (Property<Any>) throws -> Any?) throws -> Any {
        if let defaultInitializable = type as? DefaultInitializable.Type {
            return defaultInitializable.init()
        }
        return try Reflection(reflecting: type).instance(propertyValue)
    }
    
    @usableFromInline
    func instance(properties: [String: Any]) throws -> Any {
        try instance { properties[$0.name] }
    }
}

public extension Property {
    @inlinable
    func get(from object: T) throws -> Any {
        try withUnsafePointer(to: object) {
            let pointer = try UnsafeMutableRawPointer(pointer: $0).advanced(by: offset)
            return ProtocolTypeContainer.get(type: type, from: pointer)
        }
    }
    
    @inlinable
    func set(_ value: Any, to object: inout T) throws {
        try withUnsafePointer(to: &object) {
            let pointer = try UnsafeMutableRawPointer(pointer: $0).advanced(by: offset)
            ProtocolTypeContainer.set(type: type, value: value, to: pointer)
        }
    }
    
    @inlinable
    func set(_ value: Any, to object: T) throws where T: AnyObject {
        var object = object
        try withUnsafePointer(to: &object) {
            let pointer = try UnsafeMutableRawPointer(pointer: $0).advanced(by: offset)
            ProtocolTypeContainer.set(type: type, value: value, to: pointer)
        }
    }
}
