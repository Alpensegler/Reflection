public enum Kind {
    enum Flags {
        static let isNonHeap = 0x200
        static let isRuntimePrivate = 0x100
        static let isNonType = 0x400
    }
    
    case `struct`
    case `enum`
    case optional
    case opaque
    case tuple
    case function
    case existential
    case metatype
    case objCClassWrapper
    case existentialMetatype
    case foreignClass
    case heapLocalVariable
    case heapGenericLocalVariable
    case errorObject
    case `class`
    
    init(flag: Int) {
        switch flag {
        case (0 | Flags.isNonHeap), 1: self = .struct
        case (1 | Flags.isNonHeap), 2: self = .enum
        case (2 | Flags.isNonHeap), 3: self = .optional
        case (3 | Flags.isNonHeap), 16: self = .foreignClass
        case (0 | Flags.isRuntimePrivate | Flags.isNonHeap), 8: self = .opaque
        case (1 | Flags.isRuntimePrivate | Flags.isNonHeap), 9: self = .tuple
        case (2 | Flags.isRuntimePrivate | Flags.isNonHeap), 10: self = .function
        case (3 | Flags.isRuntimePrivate | Flags.isNonHeap), 12: self = .existential
        case (4 | Flags.isRuntimePrivate | Flags.isNonHeap), 13: self = .metatype
        case (5 | Flags.isRuntimePrivate | Flags.isNonHeap), 14: self = .objCClassWrapper
        case (6 | Flags.isRuntimePrivate | Flags.isNonHeap), 15: self = .existentialMetatype
        case (0 | Flags.isNonType), 64: self = .heapLocalVariable
        case (0 | Flags.isNonType | Flags.isRuntimePrivate), 65: self = .heapGenericLocalVariable
        case (1 | Flags.isNonType | Flags.isRuntimePrivate), 128: self = .errorObject
        default: self = .class
        }
    }
    
    public init(type: Any.Type) {
        self.init(flag: unsafeBitCast(type, to: UnsafeMutablePointer<Int>.self).pointee)
    }
}
