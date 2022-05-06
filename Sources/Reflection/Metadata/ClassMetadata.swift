struct ClassMetadata: NominalMetadata {
    struct Descriptor: TypeDescriptor {
        typealias OffsetType = Int
        
        let flags: Int32
        let parent: Int32
        @CCharRelativeDirectPointer var mangledName: String
        let fieldTypesAccessor: Int32
        @RelativeDirectPointer var fieldDescriptor: FieldDescriptor
        let superClass: Int32
        let negativeSizeAndBoundsUnion: Int32
        let metadataPositiveSizeInWords: Int32
        let numImmediateMembers: Int32
        let numberOfFields: Int32
        let offsetToTheFieldOffsetVector: Int32
        let genericContextHeader: TargetTypeGenericContextDescriptorHeader
    }
    
    let kind: Int
    let superClass: Any.Type
    #if !swift(>=5.4) || canImport(ObjectiveC)
    let objCRuntimeReserve: (Int, Int)
    let rodataPointer: Int
    #endif
    let classFlags: Int32
    let instanceAddressPoint: UInt32
    let instanceSize: UInt32
    let instanceAlignmentMask: UInt16
    let reserved: UInt16
    let classSize: UInt32
    let classAddressPoint: UInt32
    var typeDescriptor: UnsafeMutablePointer<Descriptor>
    let iVarDestroyer: UnsafeRawPointer
}

extension UnsafeMutablePointer where Pointee == ClassMetadata {
    var areImmediateMembersNegative: Bool {
        (typeDescriptor.flags >> 16) & 0x1000 != 0
    }
}
