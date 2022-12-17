/obj/effect/landmark/toolbox
	name = "toolbox spawner"
	icon = 'icons/effects/random_spawners.dmi'
	icon_state = "toolbox"
	layer = HIGH_OBJ_LAYER

	var/arena_id = EVENT_ARENA_DEFAULT_ID
	var/team_id = EVENT_ARENA_RED_TEAM

	var/obj/machinery/computer/tournament_controller/tournament_controller

/obj/effect/landmark/toolbox/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/landmark/toolbox/LateInitialize()
	. = ..()

	tournament_controller = GLOB.tournament_controllers[arena_id]
	if (isnull(tournament_controller))
		stack_trace("Toolbox spawn had an invalid arena_id: \"[arena_id]\"")
		qdel(src)
		return

	tournament_controller.toolbox_spawns[team_id] += list(src)

/obj/effect/landmark/toolbox/Destroy()
	if (!isnull(tournament_controller))
		tournament_controller.toolbox_spawns[team_id] -= src

	return ..()

// Participants can now give toolboxes their soul back. This is purely a cosmetic option.
// Some people are just boomers who prefer the old sprites. -Riggle
/obj/item/toolbox_soul
	name = "toolbox soul"
	desc = "An authentic crystalized toolbox soul. Use on a toolbox to give it back its soul."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "purified_soulstone2"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	layer = HIGH_OBJ_LAYER
	w_class = WEIGHT_CLASS_TINY
	slot_flags = ITEM_SLOT_BELT

/obj/item/toolbox_soul/pre_attack(atom/A, mob/living/user, params)
	var/obj/item/storage/toolbox/target_toolbox = A
	if(!istype(target_toolbox) || target_toolbox.icon_state == "toolbox_blue_old")
		return ..()

	user.visible_message("<span class='notice'>[user] holds [src] above [user.p_their()] head and forces it into [target_toolbox] with a flash of light!", \
		span_notice("You hold [src] above your head briefly, then force it into [target_toolbox], transferring the soul stored within!"))

	target_toolbox.name = "soulful toolbox"
	target_toolbox.icon = 'icons/obj/storage/storage.dmi'
	target_toolbox.icon_state = "toolbox_blue_old"
	target_toolbox.has_latches = FALSE
	playsound(user, 'sound/magic/magic_block_holy.ogg', 50, TRUE)
	var/effect = mutable_appearance('icons/effects/genetics.dmi', "servitude", -MUTATIONS_LAYER)
	user.add_overlay(effect)
	addtimer(CALLBACK(user, /atom/proc/cut_overlay, effect), 2 SECONDS)
	qdel(src)
