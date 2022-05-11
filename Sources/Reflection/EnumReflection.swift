public struct EnumReflection<T>: ReflectionType {
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
    init(reflecting type: T.Type) throws {
        guard Kind(type: type) == .enum else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: EnumReflection.self)
        }
        self.init(type)
    }
    
    init(reflecting type: Any.Type) throws where T == Any {
        guard Kind(type: type) == .enum else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: EnumReflection.self)
        }
        self.init(type)
    }
    
    func instance(caseIndex: Int = 0) throws -> T {
        guard payloadCasesCount == 0, caseIndex < cases.count else {
            throw ReflectionError.unsupportedInstance(type: type)
        }
        let pointer = UnsafeMutableRawPointer.allocate(byteCount: size, alignment: alignment)
        defer { pointer.deallocate() }
        ProtocolTypeContainer.set(type: Int8.self, value: Int8(caseIndex), to: pointer, initialize: true)
        return ProtocolTypeContainer.get(type: type, from: pointer) as! T
    }
}
    
