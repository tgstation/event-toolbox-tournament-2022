/// Tournament controllers mapped to arena ID
GLOBAL_LIST_EMPTY(tournament_controllers)

/// Controller for the tournament
/obj/machinery/computer/tournament_controller
	name = "tournament machine"
	desc = "contact mothblocks if you want to learn more"

	/// The arena ID to be looking for
	var/arena_id = EVENT_ARENA_DEFAULT_ID

	var/list/contestants = list()
	var/list/toolboxes = list()

	/// Turfs near the spawn beacons for team member mobs
	var/list/valid_team_spawns = list()
	/// Turfs that make up the entire prep room, for sweeping items
	var/list/prep_room_turfs = list()

	/// "Shutters" that separate teams from the arena
	var/list/obj/effect/oneway/arena_oneways = list()

	/// The places to disband team members

	/// Old mobs by client
	var/list/old_mobs = list()
	/// Old mobs loc by client
	var/list/old_mobs_loc = list()

	/// The places to spawn toolboxes
	var/list/toolbox_spawns = list()

	var/static/list/arena_templates

	/// HUD indexes indexed by team ID
	var/static/list/team_hud_ids

	/// Internal radio for death announcements
	var/obj/item/radio/radio


	var/countdown_started = FALSE
	var/loading = FALSE

/obj/machinery/computer/tournament_controller/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()

	radio = new(src)
	radio.independent = TRUE
	radio.set_frequency(FREQ_CENTCOM)

	if (arena_id in GLOB.tournament_controllers)
		stack_trace("Tournament controller had arena_id \"[arena_id]\", which is reused!")
		return INITIALIZE_HINT_QDEL

	GLOB.tournament_controllers[arena_id] = src

	if (isnull(arena_templates))
		arena_templates = list()
		INVOKE_ASYNC(src, .proc/load_arena_templates)

	if (isnull(team_hud_ids))
		team_hud_ids = setup_team_huds()

/obj/machinery/computer/tournament_controller/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "TournamentController")
		ui.open()

/obj/machinery/computer/tournament_controller/ui_static_data(mob/user)
	return list(
		"arena_id" = arena_id,
		"arena_templates" = assoc_to_keys(arena_templates),
		"team_names" = assoc_to_keys(GLOB.tournament_teams),
	)

/obj/machinery/computer/tournament_controller/ui_data(mob/user)
	return list(
		"old_mobs" = old_mobs.len,
	)

/obj/machinery/computer/tournament_controller/ui_act(action, list/params)
	. = ..()
	if (.)
		return .

	switch (action)
		if ("clear_arena")
			clear_arena(usr, manual = TRUE)
			return TRUE
		if ("close_shutters")
			close_oneways()
			return TRUE
		if ("disband_teams")
			disband_teams(usr)
			return TRUE
		if ("open_shutters")
			open_oneways()
			return TRUE
		if ("start_countdown")
			start_countdown(usr)
			return TRUE
		if ("load_arena")
			load_arena(usr, params["arena_template"])
			return TRUE
		if ("check_teams_online")
			check_teams_online(usr, list(params["team_a"], params["team_b"]))
			return TRUE
		if ("spawn_teams")
			spawn_teams(usr, list(params["team_a"], params["team_b"]), params["clear"])
			return TRUE
		if ("vv_teams")
			if (usr.client)
				usr.client.debug_variables(GLOB.tournament_teams)
			return TRUE
		if ("export_teams")
			export_tournament_teams()

/obj/machinery/computer/tournament_controller/ui_state(mob/user)
	return GLOB.admin_state

/obj/machinery/computer/tournament_controller/ui_status(mob/user)
	return GLOB.admin_state.can_use_topic(src, user)

/obj/machinery/computer/tournament_controller/proc/get_landmark_turf(landmark_tag)
	for(var/obj/effect/landmark/arena/arena_landmark in GLOB.landmarks_list)
		if (arena_landmark.arena_id == arena_id && arena_landmark.landmark_tag == landmark_tag && isturf(arena_landmark.loc))
			return arena_landmark.loc

/obj/machinery/computer/tournament_controller/proc/get_load_point()
	var/turf/corner_a = get_landmark_turf(EVENT_ARENA_CORNER_A)
	var/turf/corner_b = get_landmark_turf(EVENT_ARENA_CORNER_B)
	return locate(min(corner_a.x, corner_b.x), min(corner_a.y, corner_b.y), corner_a.z)

/obj/machinery/computer/tournament_controller/proc/close_oneways()
	for(var/obj/effect/oneway/oneway in arena_oneways)
		oneway.density = 1
		oneway.color = "#ff0000"

/obj/machinery/computer/tournament_controller/proc/warn_oneways()
	for(var/obj/effect/oneway/oneway in arena_oneways)
		oneway.density = 1
		oneway.color = "#ffc917"

/obj/machinery/computer/tournament_controller/proc/open_oneways()
	for(var/obj/effect/oneway/oneway in arena_oneways)
		oneway.density = 0
		oneway.color = "#62ff62"

/obj/machinery/computer/tournament_controller/proc/get_arena_turfs()
	var/load_point = get_load_point()
	var/turf/corner_a = get_landmark_turf(EVENT_ARENA_CORNER_A)
	var/turf/corner_b = get_landmark_turf(EVENT_ARENA_CORNER_B)
	var/turf/high_point = locate(max(corner_a.x, corner_b.x),max(corner_a.y, corner_b.y), corner_a.z)
	return block(load_point, high_point)

/obj/machinery/computer/tournament_controller/proc/load_arena_templates()
	var/arena_dir = "_maps/toolbox_arenas/"
	var/list/default_arenas = flist(arena_dir)
	for(var/arena_file in default_arenas)
		var/simple_name = replacetext(replacetext(arena_file, arena_dir, ""), ".dmm", "")
		var/datum/map_template/map_template = new("[arena_dir]/[arena_file]", simple_name)
		arena_templates[simple_name] = map_template

/obj/machinery/computer/tournament_controller/proc/load_arena(mob/user, arena_template_name)
	if (loading)
		to_chat(user, span_warning("An arena is already loading."))
		return

	var/datum/map_template/template = arena_templates[arena_template_name]
	if(!template)
		to_chat(user, span_warning("The arena \"[arena_template_name]\" does not exist."))
		return

	clear_arena()
	close_oneways()

	var/turf/corner_a = get_landmark_turf(EVENT_ARENA_CORNER_A)
	var/turf/corner_b = get_landmark_turf(EVENT_ARENA_CORNER_B)
	var/width = abs(corner_a.x - corner_b.x) + 1
	var/height = abs(corner_a.y - corner_b.y) + 1
	if(template.width > width || template.height > height)
		to_chat(user, span_warning("Arena template is too big for the current arena!"))
		return

	loading = TRUE
	var/bounds = template.load(get_load_point())
	loading = FALSE

	if (!bounds)
		to_chat(user, span_warning("Something went wrong while loading the map."))
		return

	message_admins("[key_name_admin(user)] loaded [arena_template_name] map for [arena_id] arena.")
	log_admin("[key_name(user)] loaded [arena_template_name] map for [arena_id] arena.")

/obj/machinery/computer/tournament_controller/proc/clear_arena(mob/user, manual = FALSE)
	for (var/turf/arena_turf in get_arena_turfs())
		arena_turf.empty(turf_type = /turf/open/floor/plating, baseturf_type = /turf/open/floor/plating)

	if(manual)
		message_admins("[key_name_admin(user)] manually cleared the map for [arena_id] arena.")
		log_admin("[key_name_admin(user)] manually cleared the map for [arena_id] arena.")

/obj/machinery/computer/tournament_controller/proc/check_teams_online(mob/user, list/team_names)
	var/output = ""
	for (var/team_name in team_names)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		if (!istype(team))
			to_chat(user, span_warning("Couldn't find team: [team_name]"))
			return

		var/list/clients = team.get_clients()
		output += "Team: [team_name]<br />[clients.len]/[team.roster.len] members connected<br />"
		for(var/key in team.roster)
			output += (GLOB.directory[key]) ? "Online: [key]<br />" : "<strong>Offline</strong>: [key]<br />"
		output += "<br /><br />"

	user << browse("<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Team Online Status</title></head><body>[output]</body></html>","window=team_online_status;size=400x400")


/obj/machinery/computer/tournament_controller/proc/spawn_teams(mob/user, list/team_names, clear_existing)
	if (clear_existing)
		QDEL_LIST(contestants)
		QDEL_LIST(toolboxes)
		for (var/turf/prep_room_turf in prep_room_turfs)
			for (var/obj/item/garbage in prep_room_turf.contents)
				if (!garbage.anchored)
					qdel(garbage) // so fresh and so clean

	var/list/new_contestants = list()

	var/index = 1

	for (var/team_name in team_names)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		if (!istype(team))
			to_chat(user, span_warning("Couldn't find team: [team_name]"))
			return

		var/team_spawn_id = valid_team_spawns[index]

		var/list/clients = team.get_clients()

		for (var/client/client as anything in clients)
			var/mob/old_mob = client?.mob

			if (isliving(old_mob) && !(old_mob in contestants))
				old_mobs[client] = old_mob
				old_mobs_loc[client] = get_turf(old_mob)
				old_mob.visible_message(span_notice("[old_mob] teleported away to participate in the tournament! Watch this space."))
				playsound(get_turf(old_mob), 'sound/magic/wand_teleport.ogg', 50, TRUE)
				old_mob.forceMove(src)

			var/mob/living/carbon/human/contestant_mob = new

			client?.prefs?.apply_prefs_to(contestant_mob)
			if (!(contestant_mob.dna?.species?.type in list(/datum/species/human, /datum/species/moth, /datum/species/lizard, /datum/species/human/felinid)))
				contestant_mob.set_species(/datum/species/human)
			contestant_mob.forceMove(pick(valid_team_spawns[team_spawn_id]))
			contestant_mob.equip_inert_outfit(team.outfit)
			var/obj/item/card/id/advanced/centcom/ert/id_card = new(contestant_mob.loc)
			id_card.desc = "A Toolbox Tournament Competitor ID Card"
			id_card.registered_name = contestant_mob.real_name
			id_card.assignment = team.name
			id_card.update_label()
			id_card.update_icon()
			contestant_mob.equip_to_slot_if_possible(id_card, ITEM_SLOT_ID)
			contestant_mob.key = client?.key
			contestant_mob.reset_perspective()
			contestant_mob.job = team.name
			contestant_mob.set_nutrition(NUTRITION_LEVEL_FED + 50)
			contestant_mob.add_mood_event("event", /datum/mood_event/toolbox_arena)
			ADD_TRAIT(contestant_mob, TRAIT_BYPASS_MEASURES, "arena")
			RegisterSignal(contestant_mob, COMSIG_LIVING_DEATH, .proc/contestant_died)

			new_contestants += contestant_mob

			//assign_team_hud(contestant_mob, team_spawn_id)

		spawn_toolboxes(team.toolbox_color, team_spawn_id, clients.len)

		index += 1

	radio.talk_into(src, "Setting up [team_names.Join(" vs ")].")
	var/message = "spawned teams ([team_names.Join(", ")]) at [arena_id] arena."
	message_admins("[key_name_admin(user)] [message]")
	log_admin("[key_name(user)] [message]")

	contestants = new_contestants

/obj/machinery/computer/tournament_controller/proc/contestant_died(source, gibbed)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/contestant_mob = source
	radio.talk_into(src, "[contestant_mob] ([contestant_mob.job]) has died in the [arena_id] arena!")
	UnregisterSignal(source, COMSIG_LIVING_DEATH)

/obj/machinery/computer/tournament_controller/proc/spawn_toolboxes(toolbox_color, team_spawn_id, number_to_spawn)
	var/list/spawns = toolbox_spawns[team_spawn_id]
	spawns = spawns.Copy()

	for (var/_ in 1 to number_to_spawn)
		var/obj/spawn_landmark = pick_n_take(spawns)

		var/obj/item/storage/toolbox/toolbox = new
		var/obj/item/toolbox_soul/soul = new
		toolbox.color = toolbox_color
		toolbox.forceMove(get_turf(spawn_landmark))
		soul.forceMove(get_turf(spawn_landmark))

		toolboxes += toolbox
		toolboxes += soul

/obj/machinery/computer/tournament_controller/proc/disband_teams(mob/user)
	for (var/client/client as anything in old_mobs)
		var/mob/living/old_mob = old_mobs[client]
		if (isnull(old_mob))
			continue

		if (old_mob.stat <= CONSCIOUS)
			old_mob.fully_heal(admin_revive = TRUE)

		old_mob.forceMove(old_mobs_loc[client])
		old_mob.key = client?.key
		playsound(get_turf(old_mob), 'sound/magic/wand_teleport.ogg', 50, TRUE)

	QDEL_LIST(contestants)
	old_mobs.Cut()
	old_mobs_loc.Cut()

	message_admins("[key_name_admin(user)] disbanded [arena_id] arena teams.")
	log_admin("[key_name_admin(user)] disbanded [arena_id] arena teams.")

/datum/mood_event/toolbox_arena
	description = "I am taking part in the Toolbox Tournament!"
	mood_change = 42
	timeout = 5 MINUTES

/area/centcom/tdome/arena/team_prep
	name = "Thunderdome Arena Team Prep"
