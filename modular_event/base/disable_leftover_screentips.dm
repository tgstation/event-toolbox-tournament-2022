// This is for whatever implements MouseEnter to still not have screentips
/datum/preference/choiced/enable_screentips/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentips_enabled = FALSE

/datum/hud/New(mob/owner)
	. = ..()

	screentips_enabled = SCREENTIP_PREFERENCE_DISABLED

/atom/Initialize(mapload, ...)
	. = ..()
	flags_1 |= NO_SCREENTIPS_1
