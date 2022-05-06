struct EnumMetadata: NominalMetadata {
    struct Descriptor: TypeDescriptor {
        typealias OffsetType = Int32
        
        let flags: Int32
        let parent: Int32
        @CCharRelativeDirectPointer var mangledName: String
        let accessFunctionPtrOffset: Int32
        @RelativeDirectPointer var fieldDescriptor: FieldDescriptor
        let numPayloadCasesAndPayloadSizeOffset: UInt32
        let numEmptyCases: UInt32
        let offsetToTheFieldOffsetVector: Int32
        let genericContextHeader: TargetTypeGenericContextDescriptorHeader
        var numberOfFields: Int32 { 0 }
    }
    
    var kind: Int
    var typeDescriptor: UnsafeMutablePointer<Descriptor>
}
