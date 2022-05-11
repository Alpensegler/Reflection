public enum ReflectionError: Error {
    case unsupportedRefelction(type: Any.Type, reflection: ReflectionType.Type)
    case cannotGetPointer(type: Any.Type, value: Any)
    case unsupportedInstance(type: Any.Type)
    case propertyTypeMismatch(property: Property<Any>, value: Any)
    case noProperty(name: String, value: Any)
}
