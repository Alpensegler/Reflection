public protocol Reflectable {
    var rf: Reflecting<Self> { get set }
}

public extension Reflectable {
    var rf: Reflecting<Self> {
        get {
            Reflecting(
                reflection: try? Reflection(reflecting: Self.self),
                value: self
            )
        }
        set {
            self = newValue.value
        }
    }
}

public extension Reflectable where Self: AnyObject {
    var rf: Reflecting<Self> {
        get {
            Reflecting(
                reflection: try? Reflection(reflecting: Self.self),
                value: self
            )
        }
        nonmutating set { }
    }
}

@dynamicMemberLookup
public struct Reflecting<T> {
    let reflection: Reflection<T>?
    var value: T
    
    public subscript(dynamicMember name: String) -> Any? {
        get {
            try? reflection?[name]?.get(from: value)
        }
        set {
            guard let newValue = newValue else { return }
            try? reflection?[name]?.set(newValue, to: &value)
        }
    }
}
