// include/swift/Reflection/Records.h
struct FieldDescriptor {
    let mangledTypeNameOffset: Int32
    let superClassOffset: Int32
    let kind: UInt16
    let fieldRecordSize: Int16
    let numFields: Int32
    var fields: Vector<FieldRecord>
}

struct FieldRecord {
    let fieldRecordFlags: Int32
    var mangledTypeNameOffset: Int32
    @CCharRelativeDirectPointer var fieldName: String
    
    var isVar: Bool {
        fieldRecordFlags & 0x2 == 0x2
    }
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

struct ExistentialContainer {
    struct Buffer {
        let buffer1, buffer2, buffer3: Int
        
        static func size() -> Int {
            return MemoryLayout<Buffer>.size
        }
    }
    let buffer: Buffer
    let type: Any.Type
    let witnessTable: Int
}
