extension UnsafeMutableRawPointer {
    init<Value>(pointer: UnsafePointer<Value>) throws {
        switch Kind(type: Value.self) {
        case .struct:
            self.init(mutating: UnsafeRawPointer(pointer))
        case .class:
            self = pointer.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                $0.pointee
            }
        case .existential:
            self = pointer.withMemoryRebound(to: ExistentialContainer.self, capacity: 1) {
                let container = $0.pointee, kind = Kind(type: container.type)
                let pointer = UnsafeMutablePointer<Metadata>(type: container.type)
                guard kind == .class || pointer.infos.size > ExistentialContainer.Buffer.size() else {
                    return UnsafeMutableRawPointer(UnsafeMutablePointer(mutating: $0))
                }
                return $0.withMemoryRebound(to: UnsafeMutableRawPointer.self, capacity: 1) {
                    guard kind == .struct else { return $0.pointee }
                    let existentialHeaderSize = MemoryLayout<Int>.size == 8 ? 16 : 8
                    return $0.pointee.advanced(by: existentialHeaderSize)
                }
            }
        default:
            throw ReflectionError.cannotGetPointer(type: Value.self, value: pointer.pointee)
        }
    }
}
