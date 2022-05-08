public struct FunctionReflection: ReflectionType {
    public let type: Any.Type
    public let size: Int
    public let alignment: Int
    public let stride: Int
    public let argumentTypes: [Any.Type]
    public let returnType: Any.Type
    public let `throws`: Bool
    
    init(_ type: Any.Type) {
        let metadata = UnsafeMutablePointer<FunctionMetadata>(type: type)
        let infos = metadata.infos
        self.type = type
        self.size = infos.size
        self.alignment = infos.alignment
        self.stride = infos.stride
        self.throws = metadata.pointee.flags & 0x01000000 != 0
        let numberOfArguments = metadata.pointee.flags & 0x00FFFFFF
        let argTypeBuffer = metadata.pointee.argumentVector.buffer(n: numberOfArguments + 1)
        self.returnType = argTypeBuffer[0]
        self.argumentTypes = Array(argTypeBuffer.dropFirst())
    }
}

public extension FunctionReflection {
    init(reflecting type: Any.Type) throws {
        guard Kind(type: type) == .function else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: FunctionReflection.self)
        }
        self.init(type)
    }
}
