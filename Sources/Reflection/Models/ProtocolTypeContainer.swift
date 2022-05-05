protocol Getters {}
extension Getters {
    static func get(from pointer: UnsafeRawPointer) -> Any {
        pointer.assumingMemoryBound(to: Self.self).pointee
    }
}

protocol Setters {}
extension Setters {
    static func set(value: Any, pointer: UnsafeMutableRawPointer, initialize: Bool) {
        guard let value = value as? Self else { return }
        let boundPointer = pointer.assumingMemoryBound(to: self)
        if initialize {
            boundPointer.initialize(to: value)
        } else {
            boundPointer.pointee = value
        }
    }
}

struct ProtocolTypeContainer {
    let type: Any.Type
    let witnessTable: Int
    
    static func get(type: Any.Type, from pointer: UnsafeRawPointer) -> Any {
        unsafeBitCast(ProtocolTypeContainer(type: type, witnessTable: 0), to: Getters.Type.self)
            .get(from: pointer)
    }
    
    static func set(type: Any.Type, value: Any, to pointer: UnsafeMutableRawPointer, initialize: Bool = false) {
        unsafeBitCast(ProtocolTypeContainer(type: type, witnessTable: 0), to: Setters.Type.self)
            .set(value: value, pointer: pointer, initialize: initialize)
    }
}
