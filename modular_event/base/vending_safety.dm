/obj/machinery/vending/Initialize(mapload)
	. = ..()
	tiltable = FALSE

/obj/machinery/vending/examine(mob/user)
	. = ..()
	if(!tiltable)
		. += span_notice("This extra safe model cannot be tilted.")
