/**
 * This datum defines an action that can be used by any mob/living to instantly admin heal themselves.
 * By default it has a 30 second cooldown.
 */
/datum/action/cooldown/aheal
	name = "Fully Heal Self"
	icon_icon = 'modular_event/base/event_aheal/icons/button.dmi'
	button_icon_state = "arena_heal"
	cooldown_time = 30 SECONDS

/datum/action/cooldown/aheal/UpdateButtonIcon(status_only, force)
	button_icon_state = IsAvailable() ? initial(button_icon_state) : "arena_heal_used"
	return ..()

/datum/action/cooldown/aheal/Activate(atom/target)
	var/mob/living/user = usr

	// custom lightning bolt for sound
	var/turf/lightning_source = get_step(get_step(user, NORTH), NORTH)
	lightning_source.Beam(user, icon_state="lightning[rand(1,12)]", time = 5)
	playsound(get_turf(user), 'sound/magic/charge.ogg', 50, TRUE)
	if (ishuman(user))
		var/mob/living/carbon/human/human_target = user
		human_target.electrocution_animation(LIGHTNING_BOLT_ELECTROCUTION_ANIMATION_LENGTH)
	user.revive(TRUE, TRUE)

	StartCooldown()

	return TRUE
