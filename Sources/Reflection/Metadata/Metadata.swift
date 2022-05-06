protocol Metadata {
    var kind: Int { get }
}

protocol TypeDescriptor {
    associatedtype OffsetType: FixedWidthInteger
    
    var flags: Int32 { get }
    var mangledName: String { mutating get }
    var fieldDescriptor: FieldDescriptor { mutating get set }
    var numberOfFields: Int32 { get }
    var offsetToTheFieldOffsetVector: Int32 { get }
    var genericContextHeader: TargetTypeGenericContextDescriptorHeader { get }
}

protocol NominalMetadata: Metadata {
    associatedtype Descriptor: TypeDescriptor
    var typeDescriptor: UnsafeMutablePointer<Descriptor> { get set }
}

struct TargetTypeGenericContextDescriptorHeader {
    let instantiationCache: Int32
    let defaultInstantiationPattern: Int32
    let numberOfParams: UInt16 // in base: TargetGenericContextDescriptorHeader
}

struct ValueWitnessTable {
    enum Flags {
        static let alignmentMask = 0x0000FFFF
    }
    let initializeBufferWithCopyOfBuffer: UnsafeRawPointer
    let destroy: UnsafeRawPointer
    let initializeWithCopy: UnsafeRawPointer
    let assignWithCopy: UnsafeRawPointer
    let initializeWithTake: UnsafeRawPointer
    let assignWithTake: UnsafeRawPointer
    let getEnumTagSinglePayload: UnsafeRawPointer
    let storeEnumTagSinglePayload: UnsafeRawPointer
    let size: Int
    let stride: Int
    let flags: Int
}

extension UnsafeMutablePointer {
    init(type: Any.Type) {
        self = unsafeBitCast(type, to: UnsafeMutablePointer<Pointee>.self)
    }
    
    var infos: (size: Int, alignment: Int, stride: Int) {
        let table = UnsafeMutableRawPointer(self)
            .advanced(by: -MemoryLayout<UnsafeRawPointer>.size)
            .assumingMemoryBound(to: UnsafeMutablePointer<ValueWitnessTable>.self)
            .pointee
            .pointee
        return (table.size, (table.flags & ValueWitnessTable.Flags.alignmentMask) + 1, table.stride)
    }
}

extension UnsafeMutablePointer where Pointee: NominalMetadata {
    var typeDescriptor: Pointee.Descriptor {
        get { pointee.typeDescriptor.pointee }
        _modify { yield &pointee.typeDescriptor.pointee }
    }
    
    var isGeneric: Bool {
        typeDescriptor.flags & 0x80 != 0
    }
    
    func genericArgumentVector(offset: Int) -> UnsafeMutablePointer<Any.Type> {
        UnsafeMutableRawPointer(self)
            .advanced(by: offset * MemoryLayout<UnsafeRawPointer>.size)
            .assumingMemoryBound(to: Any.Type.self)
    }
    
    func genericArguments(offset: Int = 2) -> UnsafeMutableBufferPointer<Any.Type> {
        guard isGeneric else { return .init(start: nil, count: 0) }
        
        let count = Int(typeDescriptor.genericContextHeader.numberOfParams)
        return UnsafeMutableBufferPointer(start: genericArgumentVector(offset: offset), count: count)
    }

    mutating func properties(offset: Int = 2, type: Any.Type) -> [Property] {
        let genericVector = genericArgumentVector(offset: offset)
        let numberOfFields = Int(typeDescriptor.numberOfFields)
        let fields = typeDescriptor.fieldDescriptor.fields.buffer(n: numberOfFields)
        let fieldOffsetVectorPointer = UnsafeMutableRawPointer(self)
            .assumingMemoryBound(to: Int.self)
            .advanced(by: numericCast(typeDescriptor.offsetToTheFieldOffsetVector))
        let offsets = UnsafeBufferPointer(
            start: UnsafeRawPointer(fieldOffsetVectorPointer)
                .assumingMemoryBound(to: Pointee.Descriptor.OffsetType.self),
            count: numberOfFields
        )
        
        return (0..<numberOfFields).map { index in
            Property(
                owner: type,
                name: fields[index].fieldName,
                type: fields[index].type(
                    genericContext: pointee.typeDescriptor,
                    genericArguments: genericVector
                ),
                isVar: fields[index].isVar,
                offset: numericCast(offsets[index])
            )
        }
    }
}
