// Disease can spread from lots of things, specifically the rot component.
// This prevents them from existing at all.
/mob/living/CanContractDisease(datum/disease/D)
	return FALSE

/datum/component/rot/Initialize(delay, scaling, severity)
	// Remove the component after Initialize, since `qdel(src)` in Initialize produces strange behavior,
	// and COMPONENT_INCOMPATIBLE makes a runtime.
	QDEL_IN(src, 0)
	return ..()
