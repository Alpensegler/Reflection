public struct TupleReflection<T>: PropertyContainerReflectionType {
    public let type: Any.Type
    public let size: Int
    public let alignment: Int
    public let stride: Int
    public let properties: [Property<T>]
    
    @usableFromInline
    init(_ type: Any.Type) {
        let metadata = UnsafeMutablePointer<TupleMetadata>(type: type)
        let infos = metadata.infos
        self.type = type
        self.size = infos.size
        self.alignment = infos.alignment
        self.stride = infos.stride
        let count = metadata.pointee.numberOfElements
        let elements = metadata.pointee.elementVector.buffer(n: count)
        let labels = Int(bitPattern: metadata.pointee.labelsString) == 0
            ? Array(repeating: "", count: count)
            : String(cString: metadata.pointee.labelsString)
                .split(separator: " ")
                .map { String($0) }
        self.properties = (0..<count).map {
            Property(
                owner: type,
                name: labels[$0],
                type: elements[$0].type,
                isVar: true,
                offset: elements[$0].offset
            )
        }
    }
}

public extension TupleReflection {
    @inlinable
    init(reflecting type: T.Type) throws {
        guard Kind(type: type) == .tuple else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: TupleReflection.self)
        }
        self.init(type)
    }
    
    @inlinable
    init(reflecting type: Any.Type) throws where T == Any {
        guard Kind(type: type) == .tuple else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: TupleReflection.self)
        }
        self.init(type)
    }
}
