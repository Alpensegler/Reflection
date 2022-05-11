public protocol ReflectionType {
    var type: Any.Type { get }
    var size: Int { get }
    var alignment: Int { get }
    var stride: Int { get }
}

public protocol PropertyContainerReflectionType: ReflectionType {
    associatedtype T
    
    var properties: [Property<T>] { get }
    func instance(_ propertyValue: (Property<Any>) throws -> Any?) throws -> T
}

public enum Reflection<T>: PropertyContainerReflectionType {
    case `struct`(StructReflection<T>)
    case `class`(ClassReflection<T>)
    case `enum`(EnumReflection<T>)
    case tuple(TupleReflection<T>)
    case function(FunctionReflection<T>)
    
    init(_ type: Any.Type) throws {
        switch Kind(type: type) {
        case .struct: self = .struct(StructReflection(type))
        case .class: self = .class(try ClassReflection(type))
        case .enum: self = .enum(EnumReflection(type))
        case .tuple: self = .tuple(TupleReflection(type))
        case .function: self = .function(FunctionReflection(type))
        default: throw ReflectionError.unsupportedRefelction(type: type, reflection: Reflection.self)
        }
    }
}

public extension Reflection {
    static func get(_ name: String, from object: T) throws -> Any {
        guard let property = try Reflection(Swift.type(of: object))[name] else {
            throw ReflectionError.noProperty(name: name, value: object)
        }
        return try property.get(from: object)
    }
    
    static func set(_ name: String, with value: Any, to object: inout T) throws {
        guard let property = try Reflection(Swift.type(of: object))[name] else {
            throw ReflectionError.noProperty(name: name, value: object)
        }
        try property.set(value, to: &object)
    }
    
    static func set(_ name: String, with value: Any, to object: T) throws where T: AnyObject {
        guard let property = try Reflection(Swift.type(of: object))[name] else {
            throw ReflectionError.noProperty(name: name, value: object)
        }
        try property.set(value, to: object)
    }
    
    var type: Any.Type {
        switch self {
        case .struct(let reflection): return reflection.type
        case .class(let reflection): return reflection.type
        case .enum(let reflection): return reflection.type
        case .tuple(let reflection): return reflection.type
        case .function(let reflection): return reflection.type
        }
    }
    
    
    var size: Int {
        switch self {
        case .struct(let reflection): return reflection.size
        case .class(let reflection): return reflection.size
        case .enum(let reflection): return reflection.size
        case .tuple(let reflection): return reflection.size
        case .function(let reflection): return reflection.size
        }
    }
    
    var alignment: Int  {
        switch self {
        case .struct(let reflection): return reflection.alignment
        case .class(let reflection): return reflection.alignment
        case .enum(let reflection): return reflection.alignment
        case .tuple(let reflection): return reflection.alignment
        case .function(let reflection): return reflection.alignment
        }
    }
    
    var stride: Int  {
        switch self {
        case .struct(let reflection): return reflection.stride
        case .class(let reflection): return reflection.stride
        case .enum(let reflection): return reflection.stride
        case .tuple(let reflection): return reflection.stride
        case .function(let reflection): return reflection.stride
        }
    }
    
    init(reflecting type: T.Type) throws {
        try self.init(type)
    }
    
    init(reflecting type: Any.Type) throws where T == Any {
        try self.init(type)
    }
    
    var properties: [Property<T>] {
        switch self {
        case .struct(let reflection): return reflection.properties
        case .class(let reflection): return reflection.properties
        case .tuple(let reflection): return reflection.properties
        default: return []
        }
    }
    
    func instance(
        _ propertyValue: (Property<Any>) throws -> Any? = { _ in nil }
    ) throws -> T {
        switch self {
        case .struct(let reflection): return try reflection.instance(propertyValue)
        case .class(let reflection): return try reflection.instance(propertyValue)
        case .enum(let reflection): return try reflection.instance()
        case .tuple(let reflection): return try reflection.instance(propertyValue)
        default: throw ReflectionError.unsupportedInstance(type: type)
        }
    }
}

public extension PropertyContainerReflectionType {
    func instance(_ propertyValue: (Property<Any>) throws -> Any? = { _ in nil }) throws -> T {
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer { pointer.deallocate() }
        try setPropertyValue(pointer: pointer, propertyValue)
        return ProtocolTypeContainer.get(type: type, from: pointer) as! T
    }
    
    func instance(_ properties: [String: Any]) throws -> T {
        try instance { properties[$0.name] }
    }
    
    subscript(name: String) -> Property<T>? {
        guard let property = properties.first(where: { $0.name == name }) else { return nil }
        return property
    }
}

extension PropertyContainerReflectionType {
    func setPropertyValue(
        pointer: UnsafeMutableRawPointer,
        _ propertyValue: (Property<Any>) throws -> Any?
    ) throws {
        for property in properties {
            let value: Any, property = unsafeBitCast(property, to: Property<Any>.self)
            if let propertyValue = try propertyValue(property) {
                if Swift.type(of: propertyValue) == property.type {
                    value = propertyValue
                } else if let index = propertyValue as? Int, Kind(type: property.type) == .enum {
                    value = try EnumReflection<Any>(property.type).instance(caseIndex: index)
                } else if let properties = propertyValue as? [String: Any] {
                    value = try property.instance(properties: properties)
                } else {
                    throw ReflectionError.propertyTypeMismatch(property: property, value: propertyValue)
                }
            } else {
                value = try property.instance(propertyValue)
            }
            ProtocolTypeContainer.set(type: property.type, value: value, to: pointer.advanced(by: property.offset), initialize: true)
        }
    }
}
