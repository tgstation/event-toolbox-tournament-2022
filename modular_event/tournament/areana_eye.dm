GLOBAL_LIST_EMPTY(arena_eye_list)

/obj/effect/landmark/arena_eye
	var/arena_id = ""

/obj/effect/landmark/arena_eye/Initialize(mapload)
	. = ..()
	GLOB.arena_eye_list += src

/obj/item/binoculars/examine(mob/user)
	. = ..()
	. += span_notice("Always see the best view of the nearest arena on your level.")

/obj/item/binoculars/on_wield(obj/item/source, mob/user)
	var/eye_dist = INFINITY
	var/obj/effect/landmark/arena_eye/selected_arena
	for(var/obj/effect/landmark/arena_eye/an_arena as anything in GLOB.arena_eye_list)
		if(an_arena.z == user.z && get_dist(user, an_arena) < eye_dist)
			selected_arena = an_arena
			eye_dist = get_dist(user, an_arena)
	if(!selected_arena)
		return ..()

	RegisterSignal(user, COMSIG_MOVABLE_MOVED, .proc/on_walk)
	listeningTo = user
	user.visible_message(span_notice("[user] holds [src] up to [user.p_their()] eyes."), span_notice("You hold [src] up to your eyes."))
	inhand_icon_state = "binoculars_wielded"
	user.regenerate_icons()
	user.reset_perspective(selected_arena)

/obj/item/binoculars/on_unwield(obj/item/source, mob/user)
	user.reset_perspective()
	return ..()
