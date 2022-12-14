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

/obj/effect/fishing_score_display/proc/start_fish_tournament()
	//Could reset current scores just to be sure
	for(var/datum/tournament_team/T in GLOB.tournament_teams)
		T.team_fishing_score = 0
	if(duration > 1)
		until_end_timer = addtimer(CALLBACK(src, .proc/end_fish_tournament), duration, TIMER_STOPPABLE)

/obj/effect/fishing_score_display/proc/end_fish_tournament()
	if(until_end_timer != null)
		deltimer(until_end_timer)
		until_end_timer = null

/obj/effect/fishing_score_display/Initialize(mapload)
	if(GLOB?.fishing_panel?.fishing_tournament)
		qdel(src)
		return
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/effect/fishing_score_display/Destroy(force)
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/effect/fishing_score_display/process(delta_time)
	update_maptext()

/obj/effect/fishing_score_display/proc/time_left()
	return timeleft(until_end_timer)

/obj/effect/fishing_score_display/proc/update_maptext()
	var/list/lines = list("Time remaining: [DisplayTimeText(time_left())]")
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
	. = ..()
	ui_interact(user)

/obj/effect/fishing_score_display/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "FishingTournamentDisplay", name)
		ui.open()

/obj/effect/fishing_score_display/ui_data(mob/user)
	var/list/data = list()
	data["tournament_going_on"] = isnull(until_end_timer)
	data["duration"] = duration
	data["timeleft"] = time_left()
	return data

/obj/effect/fishing_score_display/ui_state(mob/user)
	return GLOB.admin_state

/obj/effect/fishing_score_display/ui_status(mob/user)
	return GLOB.admin_state.can_use_topic(src, user)

/obj/effect/fishing_score_display/ui_act(action, list/params)
	. = ..()
	if(.)
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
