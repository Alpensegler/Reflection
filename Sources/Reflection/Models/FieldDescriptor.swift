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
    @CCharRelativeDirectPointer var mangledTypeName: String
    @CCharRelativeDirectPointer var fieldName: String
    
    var isVar: Bool {
        fieldRecordFlags & 0x2 == 0x2
    }

    mutating func type(
        genericContext: UnsafeRawPointer?,
        genericArguments: UnsafeRawPointer?
    ) -> Any.Type {
        let typeName = _mangledTypeName.get(), pointer = UnsafeRawPointer(typeName)
        var nameLength = 0
        while let current = Optional(pointer.load(fromByteOffset: nameLength, as: UInt8.self)), current != 0 {
            nameLength += 1
            if current >= 0x1 && current <= 0x17 {
                nameLength += 4
            } else if current >= 0x18 && current <= 0x1F {
                nameLength += MemoryLayout<Int>.size
            }
        }
        
        return swift_getTypeByMangledNameInContext(
            typeName,
            Int32(nameLength),
            genericContext,
            genericArguments?.assumingMemoryBound(to: Optional<UnsafeRawPointer>.self)
        )!
    }
}
