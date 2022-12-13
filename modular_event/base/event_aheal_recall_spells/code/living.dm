/mob/living
	/// The holder for this mob living's admin heal action. It should never be set to null or modified except on qdel
	var/datum/action/cooldown/aheal/aheal_action = new
	var/datum/action/cooldown/spell/summonitem/recall_action = new

/mob/living/Destroy()
	aheal_action.Remove(src)
	QDEL_NULL(aheal_action)
	recall_action.Remove(src)
	QDEL_NULL(recall_action)
	return ..()

/mob/living/Login()
	. = ..()
	aheal_action.Grant(src)
	recall_action.Grant(src)

/mob/living/Logout()
	. = ..()
	if(aheal_action)
		aheal_action.Remove(src)
	if(recall_action)
		recall_action.Remove(src)
