public struct Property {
    public let owner: Any.Type
    public let name: String
    public let type: Any.Type
    public let isVar: Bool
    public let offset: Int
    
    func instance(propertySetter setter: (Property) throws -> Any?) throws -> Any {
        if let defaultInitializable = type as? DefaultInitializable.Type {
            return defaultInitializable.init()
        }
        return try Reflection(reflecting: type).instance(propertySetter: setter)
    }
    
}

public extension Property {
    func get<Object>(from object: Object) throws -> Any {
        try withUnsafePointer(to: object) {
            let pointer = try UnsafeMutableRawPointer(pointer: $0).advanced(by: offset)
            return ProtocolTypeContainer.get(type: type, from: pointer)
        }
    }
    
    func set<Object>(_ value: Any, to object: inout Object) throws {
        try withUnsafePointer(to: &object) {
            let pointer = try UnsafeMutableRawPointer(pointer: $0).advanced(by: offset)
            ProtocolTypeContainer.set(type: type, value: value, to: pointer)
        }
    }
}
