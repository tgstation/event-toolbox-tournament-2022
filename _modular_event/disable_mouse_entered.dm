/// Preserves MouseEntered on the given type, use sparingly
#define PROTECT_MOUSE_ENTERED(type) ##type/MouseEntered(location, control, params) { MouseEnteredInternal(location, control, params); }

PROTECT_MOUSE_ENTERED(/obj/effect/abstract/info)

// Screen objects, made as specific as necessary, to avoid
// defining MouseEntered too low in the hierarchy
PROTECT_MOUSE_ENTERED(/atom/movable/screen/alert)
PROTECT_MOUSE_ENTERED(/atom/movable/screen/inventory)
PROTECT_MOUSE_ENTERED(/atom/movable/screen/lobby/button)
PROTECT_MOUSE_ENTERED(/atom/movable/screen/movable/action_button)
PROTECT_MOUSE_ENTERED(/atom/movable/screen/radial)

#undef PROTECT_MOUSE_ENTERED

// Disables MouseEntered completely.
// This has to be done through this hack, since MouseEntered
// just being DEFINED causes bandwidth issues
#define MouseEntered MouseEnteredInternal

/// If you really need to, you can call this to call the normal MouseEntered define
/atom/proc/MouseEnteredInternal(location, control, params)
	return
