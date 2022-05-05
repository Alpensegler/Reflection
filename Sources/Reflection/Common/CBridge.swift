@_silgen_name("swift_getTypeByMangledNameInContext")
func swift_getTypeByMangledNameInContext(
    _ name: UnsafePointer<CChar>?,
    _ nameLength: Int32,
    _ genericContext: UnsafeRawPointer?,
    _ genericArguments: UnsafeRawPointer?
) -> Any.Type?

@_silgen_name("swift_allocObject")
func swift_allocObject(
    _ type: UnsafeRawPointer?,
    _ requiredSize: Int32,
    _ requiredAlignmentMask: Int32
) -> UnsafeRawPointer?
