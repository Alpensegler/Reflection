public struct EnumReflection: ReflectionType {
    public struct Case {
        public let name: String
        public let payloadType: Any.Type?
    }
    
    public let type: Any.Type
    public let mangledName: String
    public let size: Int
    public let alignment: Int
    public let stride: Int
    public let genericTypes: [Any.Type]
    public let cases: [Case]
    let payloadCasesCount: UInt32
    
    init(_ type: Any.Type) {
        var metadata = UnsafeMutablePointer<EnumMetadata>(type: type)
        let infos = metadata.infos
        self.type = type
        self.size = infos.size
        self.alignment = infos.alignment
        self.stride = infos.stride
        self.mangledName = metadata.typeDescriptor.mangledName
        self.genericTypes = Array(metadata.genericArguments())
        self.payloadCasesCount = metadata.typeDescriptor.numPayloadCasesAndPayloadSizeOffset & 0x00FFFFFF
        let count = Int(metadata.typeDescriptor.numEmptyCases + payloadCasesCount)
        self.cases = metadata.mapFieldRecord(count: count) { name, type, _, _ in Case(name: name, payloadType: type) }
    }
}

public extension EnumReflection {
    init(reflecting type: Any.Type) throws {
        guard Kind(type: type) == .enum else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: EnumReflection.self)
        }
        self.init(type)
    }
    
    func instance() throws -> Any {
        guard payloadCasesCount == 0 else {
            throw ReflectionError.unsupportedInstance(type: type)
        }
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer { pointer.deallocate() }
        return ProtocolTypeContainer.get(type: type, from: pointer)
    }
}
    
