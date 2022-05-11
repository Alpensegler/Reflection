struct Vector<Element> {
    var element: Element
    
    mutating func buffer(n: Int) -> UnsafeMutableBufferPointer<Element> {
        withUnsafePointer(to: &self) {
            $0.withMemoryRebound(to: Element.self, capacity: 1) {
                UnsafeMutableBufferPointer(start: UnsafeMutablePointer(mutating: $0), count: n)
            }
        }
    }
}
