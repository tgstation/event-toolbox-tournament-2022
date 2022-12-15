/datum/fish_source/event
	fish_table = list(
		/obj/item/skub = 5,
		/obj/item/fish/clownfish = 15,
		/obj/item/fish/greenchromis = 15,
		/obj/item/fish/needlefish = 15,
		/obj/item/fish/cardinal = 14,
		/obj/item/fish/gunner_jellyfish = 12,
		/obj/item/fish/pufferfish = 10,
		/obj/item/fish/lanternfish = 8,
		/obj/item/fish/catfish = 7,
		/obj/item/fish/coinfish = 6,
		/obj/item/fish/toolboxfish = 6,
	)
	fishing_difficulty = 30

	// How many score points per unit of size
	var/size_points_coeff = 1
	// How many score points per unit of weight
	var/weight_points_coeff = 1

// Every fish caught adds to teams fishing score
/datum/fish_source/event/proc/handle_event_points(obj/item/reward, mob/fisherman)
	if(!GLOB.fishing_panel.is_tournament_active())
		return
	if(!fisherman || !fisherman.ckey)
		return
	var/points = 1
	var/obj/item/fish/fish = reward
	if(istype(fish))
		points = size_points_coeff * fish.size + weight_points_coeff * fish.weight
	else if(ispath(reward, /obj/item/skub))
		points = 10

	var/datum/tournament_team/team = get_team_for_ckey(fisherman.ckey)
	if(isnull(team))
		message_admins("Couldn't find team for [fisherman.ckey], fish_score: [points]")
		return
	team.team_fishing_score += points
	fisherman.balloon_alert_to_viewers("caught [reward] for [points] points!")

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
				//fish caught signal if needed goes here and/or fishing achievements
			//Try to put it in hand
			fisherman.put_in_hands(reward)
			handle_event_points(reward, fisherman)
		else //If someone adds fishing out carp/chests/singularities or whatever just plop it down on the fisher's turf
			fisherman.balloon_alert(fisherman, "caught something!")
			new reward_path(get_turf(fisherman))
	else if (reward_path == FISHING_DUD)
		//baloon alert instead
		fisherman.balloon_alert(fisherman,pick(duds))
