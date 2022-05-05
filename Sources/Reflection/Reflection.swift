public protocol ReflectionType {
    var size: Int { get }
    var alignment: Int { get }
    var stride: Int { get }
    init(reflecting type: Any.Type) throws
}

public enum Reflection: ReflectionType {
    case `struct`(StructReflection)
    
}

public extension Reflection {
    var size: Int {
        switch self {
        case .struct(let reflection): return reflection.size
        }
    }
    
    var alignment: Int  {
        switch self {
        case .struct(let reflection): return reflection.alignment
        }
    }
    
    var stride: Int  {
        switch self {
        case .struct(let reflection): return reflection.stride
        }
    }
    
    init(reflecting type: Any.Type) throws {
        switch Kind(type: type) {
        case .struct: self = .struct(StructReflection(type))
        default: throw ReflectionError.unsupportedRefelction(type: type, reflection: Reflection.self)
        }
    }
    
    func instance(
        propertySetter setter: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
        switch self {
        case .struct(let reflection): return try reflection.instance(propertySetter: setter)
        }
    }
}
