/datum/controller/subsystem/air
	can_fire = FALSE

/datum/controller/subsystem/air/add_to_active(turf/open/T, blockchanges)
	// add_to_active gets non-open turfs passed through turf/open :woozy:
	if (istype(T))
		T.air?.parse_gas_string(T.real_initial_gas_mix)

/obj/effect/hotspot/Initialize()
	..()
	return INITIALIZE_HINT_QDEL

/turf
	var/real_initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/Initialize(mapload)
	planetary_atmos = FALSE
	return ..()

// Avoid all initial gas mixes, without doing it on Initialize and eating up memory
/datum/gas_mixture/copy_from_turf(turf/model)
	parse_gas_string(model.real_initial_gas_mix)
	return TRUE
