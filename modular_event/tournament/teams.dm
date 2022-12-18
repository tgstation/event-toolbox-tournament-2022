GLOBAL_LIST_INIT_TYPED(tournament_teams, /datum/tournament_team, get_tournament_teams())

/// References a team in string/teams
/datum/tournament_team
	var/name
	var/toolbox_color
	var/list/roster = list()
	var/datum/ntnet_conversation/team_chat
	var/datum/outfit/outfit
	var/team_fishing_score = 0

/datum/tournament_team/proc/get_clients()
	var/list/clients = list()

	for (var/ckey in roster)
		var/client/client = GLOB.directory[ckey]
		if (istype(client))
			clients += client

	return clients

/proc/load_tournament_team(list/data)
	var/datum/tournament_team/tournament_team = new

	//var/list/data = json_decode(contents)
	if (!islist(data))
		return "Contents didn't return a list."

	var/name = data["name"]
	if (!istext(name))
		return "No name."
	tournament_team.name = name

	var/datum/ntnet_conversation/team_chan/team_chat = new
	team_chat.title = name
	team_chat.team_ref = tournament_team
	team_chat.password = random_string(32, GLOB.alphabet + GLOB.alphabet_upper + GLOB.numerals)
	tournament_team.team_chat = team_chat

	var/toolbox_color = data["toolbox_color"]
	if (!findtext(toolbox_color, GLOB.is_color))
		return "No toolbox_color provided."
	tournament_team.toolbox_color = toolbox_color

	var/list/roster = data["roster"]
	if (!islist(roster))
		return "No roster provided."

	for (var/key in roster)
		if (!istext(key))
			return "Invalid key in roster: [key]"

		tournament_team.roster += ckey(key)

	var/list/outfit_data = data["outfit"]
	if (!islist(outfit_data))
		return "No outfit provided."

	var/datum/outfit/outfit = new
	outfit.name = name
	outfit.belt = text2path(outfit_data["belt"])
	outfit.back = text2path(outfit_data["back"])
	outfit.ears = text2path(outfit_data["ears"])
	outfit.glasses = text2path(outfit_data["glasses"])
	outfit.gloves = text2path(outfit_data["gloves"])
	outfit.head = text2path(outfit_data["head"])
	outfit.mask = text2path(outfit_data["mask"])
	outfit.neck = text2path(outfit_data["neck"])
	outfit.shoes = text2path(outfit_data["shoes"])
	outfit.suit = text2path(outfit_data["suit"])
	outfit.uniform = text2path(outfit_data["uniform"])

	tournament_team.outfit = outfit

	return tournament_team

/proc/get_tournament_teams()
	var/list/tournament_teams = list()

	var/directory = "modular_event/tournament/teams/"
	for (var/team_filename in flist(directory))
		var/list/team_array = json_decode(file2text("[directory]/[team_filename]"))
		for (var/team_data in team_array)
			var/datum/tournament_team/tournament_team_result = load_tournament_team(team_data)
			if (istype(tournament_team_result))
				tournament_teams[tournament_team_result.name] = tournament_team_result
			else
				log_game("FAILURE: Couldn't load [team_filename]: [tournament_team_result]")

	return tournament_teams

/proc/export_tournament_teams()
	var/list/tournament_teams = list()
	for(var/team_key in GLOB.tournament_teams)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_key]
		var/list/data = list()
		data["name"] = team.name
		data["toolbox_color"] = team.toolbox_color
		data["roster"] = team.roster
		var/list/outfit_parts = list()
		if (team.outfit.belt)
			outfit_parts["belt"] = team.outfit.belt
		if (team.outfit.back)
			outfit_parts["back"] = team.outfit.back
		if (team.outfit.ears)
			outfit_parts["ears"] = team.outfit.ears
		if (team.outfit.glasses)
			outfit_parts["glasses"] = team.outfit.glasses
		if (team.outfit.gloves)
			outfit_parts["gloves"] = team.outfit.gloves
		if (team.outfit.head)
			outfit_parts["head"] = team.outfit.head
		if (team.outfit.mask)
			outfit_parts["mask"] = team.outfit.mask
		if (team.outfit.neck)
			outfit_parts["neck"] = team.outfit.neck
		if (team.outfit.shoes)
			outfit_parts["shoes"] = team.outfit.shoes
		if (team.outfit.suit)
			outfit_parts["suit"] = team.outfit.suit
		if (team.outfit.uniform)
			outfit_parts["uniform"] = team.outfit.uniform
		data["outfit"] = outfit_parts
		tournament_teams.Add(list(data))
	fdel("modular_event/tournament/teams/export.json")
	text2file(json_encode(tournament_teams), "modular_event/tournament/teams/export.json")
	usr << ftp(file("modular_event/tournament/teams/export.json"))

	var/message = "exported team data."
	message_admins("[key_name_admin(usr)] [message]")
	log_admin("[key_name(usr)] [message]")

/proc/get_team_for_ckey(ckey)
	for(var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/team = GLOB.tournament_teams[team_name]
		if(ckey in team.roster)
			return team
	return null
