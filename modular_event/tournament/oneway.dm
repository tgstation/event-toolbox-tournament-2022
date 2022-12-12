/obj/effect/oneway/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/effect/oneway/LateInitialize()
	. = ..()
	name = "arena one way"
	desc = "Green means go!"
	invisibility = 0
	color = "#62ff62"
	var/obj/machinery/computer/tournament_controller/tournament_controller = GLOB.tournament_controllers[id_tag]
	if (!istype(tournament_controller))
		return

	tournament_controller.arena_oneways += src

/obj/effect/oneway/Destroy()
	var/obj/machinery/computer/tournament_controller/tournament_controller = GLOB.tournament_controllers[id_tag]
	if (istype(tournament_controller))
		tournament_controller.arena_oneways -= src

	return ..()
