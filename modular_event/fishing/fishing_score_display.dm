GLOBAL_VAR_INIT(fish_scoring_active, FALSE)

/obj/effect/fishing_score_display
	anchored = TRUE
	icon = 'modular_event/arena_assets/eventfish.dmi'
	icon_state = "score_display"
	maptext_width = 256
	maptext_height = 4*2*32
	maptext_x = -32
	maptext_y = 32
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	var/duration = 5 MINUTES //dunno
	var/until_end_timer = null
	var/started_at = 0

/obj/effect/fishing_score_display/proc/start_fish_tournament()
	//Could reset current scores just to be sure
	for(var/datum/tournament_team/T in GLOB.tournament_teams)
		T.team_fishing_score = 0
	GLOB.fish_scoring_active = TRUE
	if(duration > 1)
		until_end_timer = addtimer(CALLBACK(src, .proc/end_fish_tournament), duration, TIMER_STOPPABLE)
		started_at = world.time


/obj/effect/fishing_score_display/proc/end_fish_tournament()
	GLOB.fish_scoring_active = FALSE
	if(until_end_timer != null)
		deltimer(until_end_timer)
		until_end_timer = null
		started_at = 0

/obj/effect/fishing_score_display/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/fishing_score_display/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/fishing_score_display/process(delta_time)
	update_maptext()

/obj/effect/fishing_score_display/proc/update_maptext()
	var/list/lines = list("Time remaining: [DisplayTimeText(world.time - started_at)]")
	var/list/teams = sortTim(GLOB.tournament_teams.Copy(), /proc/cmp_fishing_score_asc, associative = TRUE)
	var/ord = 1
	for(var/team_name in teams)
		if(length(lines) >= 3)
			break
		var/datum/tournament_team/team = teams[team_name]
		var/truncated_team_name = truncate(team.name, 48)
		lines += "#[ord]: [truncated_team_name] : [team.team_fishing_score] points"
		ord += 1
	var/full_text = lines.Join("<br><br>")

	maptext = MAPTEXT(full_text)

/obj/effect/fishing_score_display/interact(mob/user)
	if(!user?.client?.holder)
		return
	. = ..()
	ui_interact(user)

/obj/effect/fishing_score_display/ui_interact(mob/user, datum/tgui/ui)
	if(!user?.client?.holder)
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishingTournamentDisplay", name)
		ui.open()

/obj/effect/fishing_score_display/ui_data(mob/user)
	var/list/data = list()
	data["tournament_going_on"] = GLOB.fish_scoring_active
	data["duration"] = duration
	data["timeleft"] = timeleft(until_end_timer)
	return data

/obj/effect/fishing_score_display/ui_state(mob/user)
	return GLOB.admin_state

/obj/effect/fishing_score_display/ui_status(mob/user)
	return GLOB.admin_state.can_use_topic(src, user)

/obj/effect/fishing_score_display/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	if(!user?.client?.holder)
		return

	switch(action)
		if("start")
			start_fish_tournament()
			return TRUE
		if("end")
			end_fish_tournament()
			return TRUE
		if("set_duration")
			duration = params["duration"]
			return TRUE
	return TRUE

/proc/cmp_fishing_score_asc(datum/tournament_team/A, datum/tournament_team/B)
	return B.team_fishing_score - A.team_fishing_score
