GLOBAL_VAR_INIT(fish_scoring_active, FALSE)

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

	// How many score points per unit of size
	var/size_points_coeff = 1
	// How many score points per unit of weight
	var/weight_points_coeff = 1

/turf/open/water/event
	name = "shallow water"
	initial_gas_mix = OPENTURF_DEFAULT_ATMOS
	color = "#0FFFFF"

/turf/open/water/event/deep
	name = "deep water"
	desc = "Too bad you suck at swimming!"
	color = "#0ce1f0"
	slowdown = 12

/turf/open/water/event/deep/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/event)

/turf/open/water/event/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/lazy_fishing_spot, /datum/fish_source/event)

//fishing boat

/obj/vehicle/ridden/fishingboat
	name = "fishing boat"
	desc = "A boat used for traversing water. Has a lantern attached to it."
	icon_state = "goliath_boat"
	icon = 'icons/obj/lavaland/dragonboat.dmi'
	light_range = 3
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

// Every fish caught adds to teams fishing score
/datum/fish_source/event/proc/handle_event_points(obj/item/reward, mob/fisherman)
	if(!GLOB.fish_scoring_active)
		return
	if(!fisherman || !fisherman.ckey)
		return
	var/points = 0
	var/obj/item/fish/fish = reward
	if(istype(fish))
		points = size_points_coeff * fish.size + weight_points_coeff * fish.weight

	for(var/datum/tournament_team/T in GLOB.tournament_teams)
		if(fisherman.ckey in T.roster)
			T.team_fishing_score += points
			break
	message_admins("Couldn't find team for [fisherman.ckey], fish_score : [points]")
	fisherman.balloon_alert_to_viewers("+[points] points!")

/datum/fish_source/event/dispense_reward(reward_path, mob/fisherman)
	// THIS IS EVENT ONLY COPYPASTA REALLY SHOULD ADD SIGNAL/PROC ON MASTER
	if((reward_path in fish_counts)) // This is limited count result
		if(fish_counts[reward_path] > 0)
			fish_counts[reward_path] -= 1
		else
			reward_path = FISHING_DUD //Ran out of these since rolling (multiple fishermen on same source most likely)
	if(ispath(reward_path))
		if(ispath(reward_path,/obj/item))
			var/obj/item/reward = new reward_path(get_turf(fisherman))
			if(ispath(reward_path,/obj/item/fish))
				var/obj/item/fish/caught_fish = reward
				caught_fish.randomize_weight_and_size()
			handle_event_points(reward, fisherman)
				//fish caught signal if needed goes here and/or fishing achievements
			//Try to put it in hand
			fisherman.put_in_hands(reward)
			fisherman.balloon_alert(fisherman, "caught [reward]!")
		else //If someone adds fishing out carp/chests/singularities or whatever just plop it down on the fisher's turf
			fisherman.balloon_alert(fisherman, "caught something!")
			new reward_path(get_turf(fisherman))
	else if (reward_path == FISHING_DUD)
		//baloon alert instead
		fisherman.balloon_alert(fisherman,pick(duds))

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
