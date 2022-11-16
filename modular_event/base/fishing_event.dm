/datum/mind
	var/fishing_score = 0

/obj/item/fish/coinfish
	name = "coin fish"
	desc = "A widely used piece of currency, though depreciated in value."
	icon = 'modular_event/arena_assets/eventfish.dmi'
	icon_state = "coin_fish"
	average_size = 5
	average_weight = 50

/obj/item/fish/toolboxfish
	name = "toolbox fish"
	desc = "A solitary fish, known to swim vertically, refusing to go horizontal."
	icon = 'modular_event/arena_assets/eventfish.dmi'
	icon_state = "toolbox_fish"
	average_size = 30
	average_weight = 500

//water and fishing code

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

/turf/open/water/event
	name = "water"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS

/turf/open/water/event/deep
	name = "deep water"
	desc = "Too bad you can't swim!"
	color = "#0FFFFF"

/turf/open/water/event/deep/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/event)

/turf/open/water/event/deep/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(iscarbon(mover))
		//if(target.buckled)
		return TRUE
	if (isvehicle(mover))
		return TRUE

//fishing boat

/obj/vehicle/ridden/fishingboat
	name = "fishing boat"
	desc = "A boat used for traversing water."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	can_buckle = TRUE
	max_buckled_mobs = 3 //doesn't work
	var/allowed_turf = list(/turf/open/water/event, /turf/open/water/event/deep)

/datum/component/riding/vehicle/fishingboat
	vehicle_move_delay = 1
	var/allowed_turf = list(/turf/open/water/event, /turf/open/water/event/deep)
	keytype = null

/datum/component/riding/vehicle/fishingboat/handle_specials()
	. = ..()
	allowed_turf_typecache = typecacheof(allowed_turf)

/obj/vehicle/ridden/fishingboat/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/fishingboat)

//fishing scores

/datum/fishing_challenge/complete(win = FALSE, perfect_win = FALSE)
	for(var/fishing_score in (/datum/mind/))
		fishing_score += 1
		to_chat(user, span_warning("Your new score is [fishing_score]."))
