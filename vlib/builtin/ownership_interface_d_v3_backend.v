module builtin

// OwnershipV3InterfacePayload matches the v3 runtime interface header.
struct OwnershipV3InterfacePayload {
	payload  voidptr
	typ      int
	is_boxed bool
}

fn drop_owned_v3_interface[T](value T) {
	$if T.unaliased_typ is $interface {
		mut owned := value
		raw_interface := unsafe { &OwnershipV3InterfacePayload(voidptr(&owned)) }
		if raw_interface.is_boxed {
			// The v3 C backend recognizes builtin.drop_owned as an intrinsic and uses
			// the interface type id to destroy the concrete value before freeing its box.
			drop_owned(owned)
		}
	}
}

fn drop_owned_interface[T](value T) {
	drop_owned_v3_interface(value)
}

// drop_owned_result_error_interface destroys a boxed error. Pointer-backed errors
// remain borrowed; only boxed concrete values are owned. Destroying one takes a
// branch for every error type of the program, so that code is generated for the
// program, as an instance of the generic function. This function is generic as
// well (`E` is always IError): the object of this module then neither differs
// between programs nor needs an instance from a program that drops no error.
fn drop_owned_result_error_interface[E](err IError) {
	drop_owned_interface(err)
}
