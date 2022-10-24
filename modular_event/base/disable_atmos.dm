/datum/controller/subsystem/air
	can_fire = FALSE

/datum/controller/subsystem/air/add_to_active(turf/open/T, blockchanges = FALSE)
	if(istype(T) && T.air)
		T.air = T.create_gas_mixture()

/obj/effect/hotspot/Initialize()
	..()
	return INITIALIZE_HINT_QDEL

/turf/open/Initialize(mapload)
	planetary_atmos = FALSE
	if(!blocks_air)
		initial_gas_mix = OPENTURF_DEFAULT_ATMOS
		air = create_gas_mixture()
	return ..()
