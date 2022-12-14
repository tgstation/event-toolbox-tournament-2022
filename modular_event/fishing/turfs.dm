/turf/open/water/event
	name = "shallow water"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	color = "#0FFFFF"

/turf/open/water/event/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/event)

/turf/open/water/event/deep
	name = "deep water"
	desc = "Too bad you suck at swimming!"
	color = "#0ce1f0"
	slowdown = 12

/turf/open/water/event/deep/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/event)
