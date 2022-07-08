/datum/game_mode/dynamic/New()
	. = ..()
	GLOB.dynamic_forced_extended = TRUE

/datum/game_mode/dynamic/send_intercept()
	return
