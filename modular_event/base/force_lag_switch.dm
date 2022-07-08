/datum/controller/subsystem/lag_switch/Initialize(start_timeofday)
	. = ..()

	set_all_measures(state = TRUE, automatic = TRUE)
