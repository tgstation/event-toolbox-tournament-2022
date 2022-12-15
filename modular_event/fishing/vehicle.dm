/obj/vehicle/ridden/fishingboat
	name = "fishing boat"
	desc = "A boat used for traversing water. Has a lantern attached to it."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	light_range = 5
	can_buckle = TRUE
	max_buckled_mobs = 3 //doesn't work
	var/allowed_turf = list(/turf/open/water/event, /turf/open/water/event/deep)

/obj/vehicle/ridden/fishingboat/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob != user)
		return FALSE // Cannot unbuckle others and strand them in the water
	return ..()

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
