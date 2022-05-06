@propertyWrapper
struct RelativeDirectPointer<Pointee> {
    var offset: Int32
    
    var wrappedValue: Pointee {
        mutating get { UnsafeMutablePointer(offset: &offset).pointee }
        _modify { yield &UnsafeMutablePointer(offset: &offset).pointee }
    }
}

@propertyWrapper
struct CCharRelativeDirectPointer {
    var offset: Int32
    
    var wrappedValue: String {
        mutating get { String(cString: UnsafeMutablePointer<CChar>(offset: &offset)) }
    }
}
