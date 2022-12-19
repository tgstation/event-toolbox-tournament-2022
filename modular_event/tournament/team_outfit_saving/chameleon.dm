/datum/action/item_action/chameleon/change
	/// Track the last selected item so we can use it for team outfit "models" if needed
	var/obj/item/last_pick

/datum/action/item_action/chameleon/change/update_item(obj/item/picked_item)
	last_pick = picked_item
	return ..()
