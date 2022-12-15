/obj/effect/fishing_score_display
	anchored = TRUE
	icon = 'modular_event/fishing/eventfish.dmi'
	icon_state = "score_display"
	maptext_width = 256
	maptext_height = 4*2*32
	maptext_x = -32
	maptext_y = 32
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	var/duration = 10 MINUTES //dunno
	var/until_end_timer = null
	var/status_text = "Not yet started"
	var/given_rods = FALSE
	var/countdown_started = FALSE

/obj/effect/fishing_score_display/proc/start_fish_tournament()
	// Reset current scores just to be sure
	for(var/datum/tournament_team/T in GLOB.tournament_teams)
		T.team_fishing_score = 0
	if(duration < 1)
		message_admins("The fishing tournament could not be started, the duration ([duration]) was invalid")
		return
	status_text = "Starting..."
	until_end_timer = addtimer(CALLBACK(src, .proc/end_fish_tournament), duration, TIMER_STOPPABLE)
	status_text = "Running"

/obj/effect/fishing_score_display/proc/end_fish_tournament()
	if(until_end_timer != null)
		deltimer(until_end_timer)
		until_end_timer = null
	status_text = "Finished"

/datum/fishing_tournament_manager/proc/is_tournament_active()
	return !isnull(until_end_timer)

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

/obj/effect/fishing_score_display/proc/give_rods()
	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN", confidential = TRUE)
		return
	if(given_rods && tgui_alert(usr, "Give every living user fishing toolbox?", "Rods?", list("Yes","No")) != "Yes")
		return

	given_rods = TRUE

	var/participants = list()
	for(var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		for(var/ckey in team.roster)
			var/client/client = GLOB.directory[ckey]
			if (!istype(client))
				continue
			var/mob/living/carbon = client?.mob
			if(!istype(player_mind))
				message_admins("[ckey] is not carbon! Make sure to account for that!")
				continue

			participants += client

	for(var/mob/living/carbon/player in participants)
		var/obj/item/storage/toolbox/fishing/to_give = new(get_turf(player))
		player.put_in_hands(to_give)

/obj/effect/fishing_score_display/proc/time_left()
	return timeleft(until_end_timer)

/obj/effect/fishing_score_display/proc/update_maptext()
	var/list/lines = list()
	if(!isnull(until_end_timer))
		lines += "Time remaining: [DisplayTimeText(time_left(), round_seconds_to = 1)]"
	else
		lines += status_text
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
	data["tournament_going_on"] = !isnull(until_end_timer)
	data["duration"] = duration
	data["timeleft"] = time_left()
	return data

/obj/effect/fishing_score_display/ui_state(mob/user)
	return GLOB.admin_state

/obj/effect/fishing_score_display/ui_status(mob/user)
	return GLOB.admin_state.can_use_topic(src, user)

/obj/effect/fishing_score_display/proc/ui_start_tournament()
	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN", confidential = TRUE)
		return

	if(tgui_alert(usr, "Are you sure you want to start the tournament?", "Start?", list("Yes","No")) != "Yes")
		return

	if(!given_rods && tgui_alert(usr, "Users have not received their rods yet, are you really sure?", "Know what you're doing?", list("Yes","No")) != "Yes")
		return

	log_admin("[key_name(usr)] started the fishing tournament")
	message_admins(span_notice("[key_name(usr)] started the fishing tournament"))

	if (countdown_started)
		to_chat(user, span_notice("The countdown has already started!"))
		return

	countdown_started = TRUE

	message_admins("[key_name_admin(user)] has started the countdown in the [arena_id] arena.")
	log_admin("[key_name(user)] has started the countdown in the [arena_id] arena.")

	var/list/countdown_timers = list()

	var/eye_dist
	var/obj/effect/landmark/arena_eye/selected_arena

	for (var/mob/player_mob as anything in GLOB.player_list)
		var/atom/movable/screen/tournament_countdown/tournament_countdown = new

		countdown_timers[player_mob.client] = tournament_countdown
		player_mob.client?.screen += tournament_countdown

	for (var/timer in 3 to 1 step -1)
		for (var/client in countdown_timers)
			var/atom/movable/screen/tournament_countdown/tournament_countdown = countdown_timers[client]
			tournament_countdown.set_text(timer)

	for (var/client in countdown_timers)
		var/atom/movable/screen/tournament_countdown/tournament_countdown = countdown_timers[client]
		tournament_countdown.set_text("Fish!")

	for (var/client/client as anything in countdown_timers)
		client?.screen -= countdown_timers[client]
		qdel(countdown_timers[client])

	start_fish_tournament()

/obj/effect/fishing_score_display/proc/ui_stop_tournament()
	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN", confidential = TRUE)
		return

	if(tgui_alert(usr, "Are you SURE you want to IMMEDIATELY END the tournament?", "WARNING!!", list("Yes","No")) != "Yes")
		return
	end_fish_tournament()
	log_admin("[key_name(usr)] forcefully ended the fishing tournament")
	message_admins(span_notice("[key_name(usr)] forcefully ended the fishing tournament"))
	status_text = "Stopped"

/obj/effect/fishing_score_display/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN", confidential = TRUE)
		return

	switch(action)
		if("start")
			ui_start_tournament()
			return TRUE
		if("end")
			ui_stop_tournament()
			return TRUE
		if("set_duration")
			duration = params["duration"]
			return TRUE
	return TRUE

/proc/cmp_fishing_score_asc(datum/tournament_team/A, datum/tournament_team/B)
	return B.team_fishing_score - A.team_fishing_score

/obj/item/fishing_tournament_timer
	name = "Fishing Timer"
	desc = "Use this to check your score and remaining time"
	icon = 'icons/obj/device.dmi'
	icon_state = "pinpointer_way"
	inhand_icon_state = "electronic"
	worn_icon_state = "pinpointer"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown_time = 15 SECONDS

/obj/item/fishing_tournament_timer/interact(mob/user)
	if(TIMER_COOLDOWN_CHECK(user, src))
		src.balloon_alert(usr, "on cooldown!")
		to_chat(usr, "The item is on cooldown!")

	TIMER_COOLDOWN_START(user, src, cooldown_time)
	var/datum/tournament_team/team = get_team_for_ckey(user.ckey)
	var/our_score = team.team_fishing_score
	var/list/teams = sortTim(GLOB.tournament_teams.Copy(), /proc/cmp_fishing_score_asc, associative = TRUE)
	var/place = teams.Find(team.name) + 1
	var/list/suffixes = list("th", "st", "nd", "rd", "th")
	var/msg = "Your team is [SPAN_BOLD("[place][suffixes[clamp(place % 10, 0, 4)]]")] with [SPAN_BOLD(our_score)] points"
	if(place == 1)
		var/team_behind = teams[place] // We added 1 earlier so no need to add one more
		msg += "! You are [our_score - team_behind.team_fishing_score] ahead of [team_behind.name]. "
	else
		var/team_ahead = teams[place - 2] // We added 1 earlier, account for that
		msg += ", just [team_ahead.team_fishing_score - our_score] points behind [team_ahead.name]! "
	var/obj/effect/fishing_score_display/tournament = GLOB?.fishing_panel?.fishing_tournament
	if(isnull(tournament))
		msg += "The tournament is not currently active."
	else
		if(tournament.is_tournament_active())
			msg += "There is [DisplayTimeText(tournament.time_left(), round_seconds_to = 1)] remaining."
		else
			var/verb_to_use = findtext(tournament.status_text, "ing") ? "is" : "has"
			msg += "The tournament [verb_to_use] [lowertext(tournament.status_text)]"
	to_chat(usr, msg)
