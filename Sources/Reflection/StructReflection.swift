public struct StructReflection<T>: PropertyContainerReflectionType {
    public let type: Any.Type
    public let mangledName: String
    public let size: Int
    public let alignment: Int
    public let stride: Int
    public let genericTypes: [Any.Type]
    public let properties: [Property<T>]
    
    @usableFromInline
    init(_ type: Any.Type) {
        var metadata = UnsafeMutablePointer<StructMetadata>(type: type)
        let infos = metadata.infos
        self.type = type
        self.size = infos.size
        self.alignment = infos.alignment
        self.stride = infos.stride
        self.mangledName = metadata.typeDescriptor.mangledName
        self.genericTypes = Array(metadata.genericArguments())
        self.properties = metadata.properties(type: type)
    }
}

public extension StructReflection {
    @inlinable
    init(reflecting type: T.Type) throws {
        guard Kind(type: type) == .struct else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: StructReflection.self)
        }
        self.init(type)
    }
    
    @inlinable
    init(reflecting type: Any.Type) throws where T == Any {
        guard Kind(type: type) == .struct else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: StructReflection.self)
        }
        self.init(type)
    }
}
