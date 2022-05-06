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
