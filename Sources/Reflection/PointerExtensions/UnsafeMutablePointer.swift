extension UnsafeMutablePointer {
    init(type: Any.Type) {
        self = unsafeBitCast(type, to: UnsafeMutablePointer<Pointee>.self)
    }
    
    init(offset: inout Int32) {
        self = withUnsafePointer(to: &offset) { [offset] in
            UnsafeMutablePointer(mutating: UnsafeRawPointer($0)
                .advanced(by: numericCast(offset))
                .assumingMemoryBound(to: Pointee.self)
            )
        }
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
    
    func genericArgumentVector(offset: Int = 2) -> UnsafeMutablePointer<Any.Type> {
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
        let numberOfFields = Int(typeDescriptor.numberOfFields)
        let fieldOffsetVectorPointer = UnsafeMutableRawPointer(self)
            .assumingMemoryBound(to: Int.self)
            .advanced(by: numericCast(typeDescriptor.offsetToTheFieldOffsetVector))
        let offsets = UnsafeBufferPointer(
            start: UnsafeRawPointer(fieldOffsetVectorPointer)
                .assumingMemoryBound(to: Pointee.Descriptor.OffsetType.self),
            count: numberOfFields
        )
        return mapFieldRecord(count: numberOfFields, offset: offset) {
            Property(owner: type, name: $0, type: $1!, isVar: $2, offset: numericCast(offsets[$3]))
        }
    }
    
    mutating func mapFieldRecord<Result>(
        count: Int,
        offset: Int = 2,
        mapping: (String, Any.Type?, Bool, Int) -> Result
    ) -> [Result] {
        if count == 0 { return [] }
        let fields = typeDescriptor.fieldDescriptor.fields.buffer(n: count)
        let genericVector = UnsafeRawPointer(genericArgumentVector(offset: offset))
        return (0..<count).map { index in
            var type: Any.Type?
            if fields[index].mangledTypeNameOffset != 0 {
                let typeName = UnsafeMutablePointer<CChar>(offset: &fields[index].mangledTypeNameOffset)
                let pointer = UnsafeRawPointer(typeName)
                var nameLength = 0
                while let current = Optional(pointer.load(fromByteOffset: nameLength, as: UInt8.self)), current != 0 {
                    nameLength += 1
                    if current >= 0x1 && current <= 0x17 {
                        nameLength += 4
                    } else if current >= 0x18 && current <= 0x1F {
                        nameLength += MemoryLayout<Int>.size
                    }
                }
                type = swift_getTypeByMangledNameInContext(
                    typeName,
                    Int32(nameLength),
                    pointee.typeDescriptor,
                    genericVector.assumingMemoryBound(to: Optional<UnsafeRawPointer>.self)
                )
            }
            return mapping(fields[index].fieldName, type, fields[index].isVar, index)
        }
    }
}
