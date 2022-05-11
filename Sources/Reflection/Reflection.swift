public protocol ReflectionType {
    var type: Any.Type { get }
    var size: Int { get }
    var alignment: Int { get }
    var stride: Int { get }
    init(reflecting type: Any.Type) throws
}

public protocol PropertyContainerReflectionType: ReflectionType {
    var properties: [Property] { get }
    func instance(_ propertyValue: (Property) throws -> Any?) throws -> Any
}

public enum Reflection: PropertyContainerReflectionType {
    case `struct`(StructReflection)
    case `class`(ClassReflection)
    case `enum`(EnumReflection)
    case tuple(TupleReflection)
    case function(FunctionReflection)
}

public extension Reflection {
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
    
    init(reflecting type: Any.Type) throws {
        switch Kind(type: type) {
        case .struct: self = .struct(StructReflection(type))
        case .class: self = .class(try ClassReflection(type))
        case .enum: self = .enum(EnumReflection(type))
        case .tuple: self = .tuple(TupleReflection(type))
        case .function: self = .function(FunctionReflection(type))
        default: throw ReflectionError.unsupportedRefelction(type: type, reflection: Reflection.self)
        }
    }
    
    var properties: [Property] {
        switch self {
        case .struct(let reflection): return reflection.properties
        case .class(let reflection): return reflection.properties
        case .tuple(let reflection): return reflection.properties
        default: return []
        }
    }
    
    func instance(
        _ propertyValue: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
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
    func instance(_ propertyValue: (Property) throws -> Any? = { _ in nil }) throws -> Any {
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer { pointer.deallocate() }
        try setPropertyValue(pointer: pointer, propertyValue)
        return ProtocolTypeContainer.get(type: type, from: pointer)
    }
    
    func instance(_ properties: [String: Any]) throws -> Any {
        try instance { properties[$0.name] }
    }
}

extension PropertyContainerReflectionType {
    func setPropertyValue(
        pointer: UnsafeMutableRawPointer,
        _ propertyValue: (Property) throws -> Any?
    ) throws {
        for property in properties {
            let value: Any
            if let propertyValue = try propertyValue(property) {
                if Swift.type(of: propertyValue) == property.type {
                    value = propertyValue
                } else if let index = propertyValue as? Int, Kind(type: property.type) == .enum {
                    value = try EnumReflection(property.type).instance(caseIndex: index)
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
