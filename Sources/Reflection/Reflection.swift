public protocol ReflectionType {
    var type: Any.Type { get }
    var size: Int { get }
    var alignment: Int { get }
    var stride: Int { get }
    init(reflecting type: Any.Type) throws
}

public enum Reflection: ReflectionType {
    case `struct`(StructReflection)
    case `class`(ClassReflection)
    case `enum`(EnumReflection)
    case function(FunctionReflection)
}

public extension Reflection {
    var type: Any.Type {
        switch self {
        case .struct(let reflection): return reflection.type
        case .class(let reflection): return reflection.type
        case .enum(let reflection): return reflection.type
        case .function(let reflection): return reflection.type
        }
    }
    
    
    var size: Int {
        switch self {
        case .struct(let reflection): return reflection.size
        case .class(let reflection): return reflection.size
        case .enum(let reflection): return reflection.size
        case .function(let reflection): return reflection.size
        }
    }
    
    var alignment: Int  {
        switch self {
        case .struct(let reflection): return reflection.alignment
        case .class(let reflection): return reflection.alignment
        case .enum(let reflection): return reflection.alignment
        case .function(let reflection): return reflection.alignment
        }
    }
    
    var stride: Int  {
        switch self {
        case .struct(let reflection): return reflection.stride
        case .class(let reflection): return reflection.stride
        case .enum(let reflection): return reflection.stride
        case .function(let reflection): return reflection.stride
        }
    }
    
    init(reflecting type: Any.Type) throws {
        switch Kind(type: type) {
        case .struct: self = .struct(StructReflection(type))
        case .class: self = .class(try ClassReflection(type))
        case .enum: self = .enum(EnumReflection(type))
        case .function: self = .function(FunctionReflection(type))
        default: throw ReflectionError.unsupportedRefelction(type: type, reflection: Reflection.self)
        }
    }
    
    func instance(
        propertySetter setter: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
        switch self {
        case .struct(let reflection): return try reflection.instance(propertySetter: setter)
        case .class(let reflection): return try reflection.instance(propertySetter: setter)
        default: throw ReflectionError.unsupportedInstance(type: type)
        }
    }
}
