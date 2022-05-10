struct TupleMetadata: Metadata {
    struct Element {
        let type: Any.Type
        let offset: Int
    }
    
    let kind: Int
    let numberOfElements: Int
    let labelsString: UnsafeMutablePointer<CChar>
    var elementVector: Vector<Element>
}
