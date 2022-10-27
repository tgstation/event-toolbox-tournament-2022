// Prevents mapload objects from being destroyed
/obj/structure/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	resistance_flags |= INDESTRUCTIBLE
	flags_1 |= NODECONSTRUCT_1

/obj/machinery/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	resistance_flags |= INDESTRUCTIBLE
	flags_1 |= NODECONSTRUCT_1

/turf
	explosion_block = 50

/turf/rust_heretic_act()
	return

/turf/acid_act(acidpwr, acid_volume, acid_id)
	return FALSE

/turf/Melt()
	to_be_destroyed = FALSE
	return src

/turf/singularity_act()
	return

//I need mineral turfs for z2 for pretty smoothing but they also need to be indestructible by tools so...

/turf/closed/mineral/ex_act(severity, target)
	return

/turf/closed/mineral/attack_alien(mob/living/carbon/alien/user, list/modifiers)
	return

/turf/closed/mineral/attack_hulk(mob/living/carbon/human/H)
	return

/turf/closed/mineral/attackby(obj/item/I, mob/user, params)
	return

/turf/closed/mineral/attack_robot(mob/living/silicon/robot/user)
	return

/turf/closed/mineral/attack_animal(mob/living/simple_animal/user, list/modifiers)
	return
