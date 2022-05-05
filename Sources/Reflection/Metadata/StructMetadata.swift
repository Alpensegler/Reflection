struct StructMetadata: NominalMetadata {
    struct Descriptor: TypeDescriptor {
        typealias OffsetType = Int32
        
        let flags: Int32
        let parent: Int32
        @CCharRelativeDirectPointer var mangledName: String
        let accessFunctionPtrOffset: Int32
        @RelativeDirectPointer var fieldDescriptor: FieldDescriptor
        let numberOfFields: Int32
        let offsetToTheFieldOffsetVector: Int32
        let genericContextHeader: TargetTypeGenericContextDescriptorHeader
    }
    
    var kind: Int
    var typeDescriptor: UnsafeMutablePointer<Descriptor>
}
