public protocol Reflectable {
    var rf: Reflecting<Self> { get set }
}

public extension Reflectable {
    @inlinable
    var rf: Reflecting<Self> {
        get { Reflecting(value: self) }
        set {
            self = newValue.value
        }
    }
}

public extension Reflectable where Self: AnyObject {
    @inlinable
    var rf: Reflecting<Self> {
        get { Reflecting(value: self) }
        nonmutating set { }
    }
}

@dynamicMemberLookup
@frozen
public struct Reflecting<Value> {
    @usableFromInline
    var value: Value
    
    @usableFromInline
    init(value: Value) {
        self.value = value
    }
    
    public subscript(dynamicMember name: String) -> Any? {
        get {
            try? Reflection.get(name, from: value)
        }
        set {
            guard let newValue = newValue else { return }
            try? Reflection.set(name, with: newValue, to: &value)
        }
    }
}
