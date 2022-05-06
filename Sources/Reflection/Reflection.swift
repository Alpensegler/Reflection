public protocol ReflectionType {
    var size: Int { get }
    var alignment: Int { get }
    var stride: Int { get }
    init(reflecting type: Any.Type) throws
}

public enum Reflection: ReflectionType {
    case `struct`(StructReflection)
    case `class`(ClassReflection)
}

public extension Reflection {
    var size: Int {
        switch self {
        case .struct(let reflection): return reflection.size
        case .class(let reflection): return reflection.size
        }
    }
    
    var alignment: Int  {
        switch self {
        case .struct(let reflection): return reflection.alignment
        case .class(let reflection): return reflection.size
        }
    }
    
    var stride: Int  {
        switch self {
        case .struct(let reflection): return reflection.stride
        case .class(let reflection): return reflection.size
        }
    }
    
    init(reflecting type: Any.Type) throws {
        switch Kind(type: type) {
        case .struct: self = .struct(StructReflection(type))
        case .class: self = .class(try ClassReflection(type))
        default: throw ReflectionError.unsupportedRefelction(type: type, reflection: Reflection.self)
        }
    }
    
    func instance(
        propertySetter setter: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
        switch self {
        case .struct(let reflection): return try reflection.instance(propertySetter: setter)
        case .class(let reflection): return try reflection.instance(propertySetter: setter)
        }
    }
}
