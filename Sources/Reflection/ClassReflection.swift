public struct ClassReflection: ReflectionType {
    class Temp {}
    static let swiftObject = UnsafeMutablePointer<ClassMetadata>(type: Temp.self)
        .pointee
        .superClass
    
    public let type: Any.Type
    public let mangledName: String
    public let size: Int
    public let alignment: Int
    public let stride: Int
    public let genericTypes: [Any.Type]
    public let properties: [Property]
    public let inheritance: [ClassReflection]
    
    init(_ type: Any.Type) throws {
        var metadata = UnsafeMutablePointer<ClassMetadata>(type: type)
        guard (metadata.typeDescriptor.flags >> 16) & 0x2000 == 0 else {
            // has resilient superclass, unsupported now
            throw ReflectionError.unsupportedRefelction(type: type, reflection: ClassReflection.self)
        }
        let infos = metadata.infos
        self.type = type
        self.size = infos.size
        self.alignment = infos.alignment
        self.stride = infos.stride
        self.mangledName = metadata.typeDescriptor.mangledName
        let genericArgumentOffset = (metadata.typeDescriptor.flags >> 16) & 0x1000 != 0
            ? -Int(metadata.typeDescriptor.negativeSizeAndBoundsUnion)
            : Int(metadata.typeDescriptor.metadataPositiveSizeInWords - metadata.typeDescriptor.numImmediateMembers)
        self.genericTypes = Array(metadata.genericArguments(offset: genericArgumentOffset))
        let properties = metadata.properties(offset: genericArgumentOffset, type: type)
        if metadata.pointee.superClass != Self.swiftObject {
            let info = try ClassReflection(metadata.pointee.superClass)
            self.properties = info.properties + properties
            self.inheritance = info.inheritance + [info]
        } else {
            self.properties = properties
            self.inheritance = []
        }
    }
    
    func instance(
        alloc: (UnsafeRawPointer?, Int32, Int32) -> UnsafeMutableRawPointer?,
        propertySetter setter: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
        let typePointer = unsafeBitCast(type, to: UnsafeRawPointer.self)
        let metadata = UnsafeMutablePointer<ClassMetadata>(type: type)
        let instanceSize = Int32(metadata.pointee.instanceSize)
        let alignmentMask = Int32(metadata.pointee.instanceAlignmentMask)
        guard let pointer = alloc(typePointer, instanceSize, alignmentMask) else {
            throw ReflectionError.unsupportedInstance(type: type)
        }
        for property in properties {
            let value = try setter(property) ?? property.instance(propertySetter: setter)
            ProtocolTypeContainer.set(type: property.type, value: value, to: pointer.advanced(by: property.offset), initialize: true)
        }
        return unsafeBitCast(pointer, to: AnyObject.self)
    }
}

public extension ClassReflection {
    init(reflecting type: Any.Type) throws {
        guard Kind(type: type) == .class else {
            throw ReflectionError.unsupportedRefelction(type: type, reflection: ClassReflection.self)
        }
        try self.init(type)
    }
    
    func instance(
        propertySetter setter: (Property) throws -> Any? = { _ in nil }
    ) throws -> Any {
        try instance(alloc: swift_allocObject, propertySetter: setter)
    }
}
