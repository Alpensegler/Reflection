protocol RelativeDirectPointerType {
    associatedtype Pointee
    var offset: Int32 { get set }
}

extension RelativeDirectPointerType {
    mutating func get() -> UnsafeMutablePointer<Pointee> {
        withUnsafePointer(to: &self) { [offset = self.offset] p in
            UnsafeMutablePointer(mutating: UnsafeRawPointer(p)
                .advanced(by: numericCast(offset))
                .assumingMemoryBound(to: Pointee.self)
            )
        }
    }
}

@propertyWrapper
struct RelativeDirectPointer<Pointee>: RelativeDirectPointerType {
    var offset: Int32
    
    var wrappedValue: Pointee {
        mutating get { get().pointee }
        _modify { yield &get().pointee }
    }
}

@propertyWrapper
struct CCharRelativeDirectPointer: RelativeDirectPointerType {
    typealias Pointee = CChar
    var offset: Int32
    
    var wrappedValue: String {
        mutating get { String(cString: get()) }
    }
}
