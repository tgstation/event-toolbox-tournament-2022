GLOBAL_DATUM_INIT(fishing_panel, /datum/fishing_tournament_manager, new)
/// The fishing tournament manager singleton that manages the fishing tournament
/datum/fishing_tournament_manager
	/// The tournament
	var/obj/effect/fishing_score_display/fishing_tournament = null

/datum/fishing_tournament_manager/Destroy(force, ...)
	QDEL_NULL(fishing_tournament)
	return ..()

/datum/fishing_tournament_manager/ui_state(mob/user)
	return GLOB.admin_state

/datum/fishing_tournament_manager/ui_status(mob/user)
	return GLOB.admin_state.can_use_topic(src, user)

/datum/fishing_tournament_manager/ui_interact(mob/user, datum/tgui/ui = null)
	ui = SStgui.try_update_ui(user, src, ui)
	if (!ui)
		ui = new(user, src, "FishingTournamentManager")
		ui.open()

/datum/fishing_tournament_manager/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	if (!check_rights(R_ADMIN))
		to_chat(usr, "You do not have permission to do this, you require +ADMIN", confidential = TRUE)
		return

	switch(action)
		if("open_or_create")
			if(fishing_tournament)
				fishing_tournament.ui_interact(usr, ui)
				return TRUE
			fishing_tournament = new
			log_admin("[key_name(usr)] created a new fishing tournament")
			message_admins(span_notice("[key_name(usr)] created a new fishing tournament"))
			return TRUE
		if("delete")
			if(tgui_alert(usr, "Are you SURE you want to delete the tournament?",,list("Yes","No")) != "Yes")
				log_admin("[key_name(usr)] deleted the current fishing tournament")
				message_admins(span_notice("[key_name(usr)] deleted the current fishing tournament"))
				return TRUE
			QDEL_NULL(fishing_tournament)
			return TRUE
		if("get")
			if(isnull(fishing_tournament))
				to_chat(usr, "The fishing tournament is no more!", confidential = TRUE)
				return TRUE
			fishing_tournament.loc = get_step(usr, 0)
			log_admin("[key_name(usr)] teleported the fishing display to [COORD(fishing_tournament)]")
			message_admins(span_notice("[key_name(usr)] teleported the fishing display to [COORD(fishing_tournament)]"))
			return TRUE
		if("set_duration")
			if(isnull(fishing_tournament))
				to_chat(usr, "The fishing tournament is no more!", confidential = TRUE)
				return TRUE
			fishing_tournament.duration = params["duration"]
			return TRUE
		if("open_VV")
			if(isnull(fishing_tournament))
				to_chat(usr, "The fishing tournament is no more!", confidential = TRUE)
				return TRUE
			usr.client.debug_variables(fishing_tournament)
			return TRUE
		if("start")
			fishing_tournament?.ui_start_tournament()
			return TRUE
		if("stop")
			fishing_tournament?.ui_stop_tournament()
			return TRUE
	return TRUE

/datum/fishing_tournament_manager/ui_data(mob/user)
	var/list/data = list()
	data["tournament"] = "[fishing_tournament]"
	data["tournament_going_on"] = is_tournament_active()
	data["time_left"] = fishing_tournament?.time_left()
	data["duration"] = fishing_tournament?.duration
	return data

/datum/fishing_tournament_manager/proc/is_tournament_active()
	return !isnull(fishing_tournament?.until_end_timer)

/client/proc/open_fishing_tournament_panel()
	set category = "Admin"
	set name = "Open Fishing Tournament Panel"

	if(!holder)
		return

	GLOB.fishing_panel.ui_interact(usr)
