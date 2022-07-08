// This is for whatever implements MouseEnter to still not have screentips
/datum/preference/toggle/enable_screentips/apply_to_client(client/client, value)
	client.mob?.hud_used?.screentips_enabled = FALSE

/datum/hud/New(mob/owner)
	. = ..()

	screentips_enabled = FALSE
