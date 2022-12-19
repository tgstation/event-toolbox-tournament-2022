/**
 * This datum defines an action that can be used by any mob/living that is a part of
 * a team to save their current cham gear's look for use in the arena
 */
/datum/action/save_team_outfit
	name = "Save Team Outfit"
	desc = "Set your current chameleon disguise as your team's outfit."
	button_icon_state = "vote"
	var/datum/tournament_team/team_datum

/datum/action/save_team_outfit/Trigger(trigger_flags)
	if(!team_datum)
		return FALSE

	var/mob/living/user = usr
	var/area/user_area = get_area(user)
	var/static/arena_areas = typecacheof(/area/centcom/tdome)
	if(is_type_in_typecache(user_area.type, arena_areas))
		to_chat(user, span_boldwarning("You cannot use this ability inside [user_area]!"))
		return FALSE

	if(tgui_alert(user, "Are you sure you want to overwrite your team's outfit with your currnet chameleon disguise?", "Confirm", list("Yes", "No")) != "Yes")
		return FALSE

	for(var/datum/action/item_action/chameleon/change/change_action as anything in user.chameleon_item_actions)
		if(!change_action.last_pick)
			continue

		switch(change_action.chameleon_type)
			if(/obj/item/storage/belt)
				team_datum.outfit.belt = change_action.last_pick
			if(/obj/item/storage/backpack)
				team_datum.outfit.back = change_action.last_pick
			if(/obj/item/radio/headset)
				team_datum.outfit.ears = change_action.last_pick
			if(/obj/item/clothing/glasses)
				team_datum.outfit.glasses = change_action.last_pick
			if(/obj/item/clothing/gloves)
				team_datum.outfit.gloves = change_action.last_pick
			if(/obj/item/clothing/head)
				team_datum.outfit.head = change_action.last_pick
			if(/obj/item/clothing/mask)
				team_datum.outfit.mask = change_action.last_pick
			if(/obj/item/clothing/neck)
				team_datum.outfit.neck = change_action.last_pick
			if(/obj/item/clothing/shoes)
				team_datum.outfit.shoes = change_action.last_pick
			if(/obj/item/clothing/suit)
				team_datum.outfit.suit = change_action.last_pick
			if(/obj/item/clothing/under)
				team_datum.outfit.uniform = change_action.last_pick

	var/list/clients = team_datum.get_clients()
	for(var/client/client as anything in clients)
		to_chat(client, span_big(span_boldnotice("[key_name(usr)] set the team outfit to their current disguise.")))

	return TRUE
