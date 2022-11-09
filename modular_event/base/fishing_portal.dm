/obj/item/fish/coinfish
	name = "coin fish"
	desc = "A great piece of currency, though depreciated in value."
	icon = 'modular_event/arena_assets/eventfish.dmi'
	icon_state = "coin_fish"

/obj/item/fish/toolboxfish
	name = "toolbox fish"
	desc = "A solitary fish, known to swim vertically, refusing to go horizontal."
	icon = 'modular_event/arena_assets/eventfish.dmi'
	icon_state = "toolbox_fish"

/datum/fish_source/event
	fish_table = list(
		/obj/item/skub = 5,
		/obj/item/fish/clownfish = 15,
		/obj/item/fish/pufferfish = 15,
		/obj/item/fish/cardinal = 15,
		/obj/item/fish/greenchromis = 15,
		/obj/item/fish/gunner_jellyfish = 10,
		/obj/item/fish/lanternfish = 10,
		/obj/item/fish/toolboxfish = 5,
		/obj/item/fish/coinfish = 5,
	)
	fishing_difficulty = FISHING_DEFAULT_DIFFICULTY + 5

/turf/open/water/jungle/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/event)

#define isfish(A) (istype(A, /obj/item/fish))

/obj/effect/fishing_portal
	name = "fishing portal"
	desc = "You throw your caught fish in there."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "portal"
	anchored = TRUE
	density = TRUE
	layer = HIGH_OBJ_LAYER
	var/fishing_score = 0

/obj/effect/fishing_portal/proc/fish_input(atom/movable/M)
	if(!isfish(M))
		return
	else
		if (istype(M,/obj/item/fish/lanternfish) || (istype(M,/obj/item/fish/gunner_jellyfish)))
			fishing_score +=15
		if (istype(M,/obj/item/fish/toolboxfish))
			fishing_score +=25
		if (istype(M,/obj/item/fish/coinfish))
			fishing_score +=1
		else
			fishing_score +=10
		qdel(M)


/obj/effect/fishing_portal/Bumped(atom/movable/bumper)
	fish_input(bumper)

/obj/effect/fishing_portal/attackby(obj/item/item, mob/user, params)
	fish_input(item)
	to_chat(user, span_warning("[src] accepts your catch! Your new score is [fishing_score]."))
	balloon_alert(user, "[src] lets that sink in.")
