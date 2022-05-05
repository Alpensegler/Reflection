public struct StructReflection: ReflectionType {
    public let type: Any.Type
    public let mangledName: String
    public let size: Int
    public let alignment: Int
    public let stride: Int
    public let genericTypes: [Any.Type]
    public let properties: [Property]
    
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
    init(reflecting type: Any.Type) throws {
        guard Kind(type: type) == .struct else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: StructReflection.self)
        }
        self.init(type)
    }
    
    func instance(
        propertySetter setter: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer { pointer.deallocate() }
        for property in properties {
            let value = try setter(property) ?? property.instance(propertySetter: setter)
            ProtocolTypeContainer.set(type: property.type, value: value, to: pointer.advanced(by: property.offset), initialize: true)
        }
        return ProtocolTypeContainer.get(type: type, from: pointer)
    }
}
