/mob/living
	var/datum/action/save_team_outfit/save_outfit = new

/mob/living/Destroy()
	save_outfit.Remove(src)
	QDEL_NULL(save_outfit)
	return ..()

/mob/living/Login()
	. = ..()
	for(var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		if(ckey in team.roster)
			save_outfit.team_datum = team
			save_outfit.Grant(src)
			break

/mob/living/Logout()
	. = ..()
	if(save_outfit)
		save_outfit.Remove(src)
