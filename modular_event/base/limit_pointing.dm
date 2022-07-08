/mob
	COOLDOWN_DECLARE(point_cooldown)

/mob/pointed(atom/pointed_atom)
	if (COOLDOWN_FINISHED(src, point_cooldown))
		COOLDOWN_START(src, point_cooldown, 2 SECONDS)
		return ..()

	balloon_alert(src, "your arm is sore!")

	return FALSE
