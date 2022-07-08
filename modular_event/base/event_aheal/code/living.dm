/mob/living
	/// The holder for this mob living's admin heal action. It should never be set to null or modified except on qdel
	var/datum/action/cooldown/aheal/aheal_action = new

/mob/living/Destroy()
	aheal_action.Remove(src)
	QDEL_NULL(aheal_action)
	return ..()

/mob/living/Login()
	. = ..()
	aheal_action.Grant(src)

/mob/living/Logout()
	. = ..()
	if(!aheal_action)
		return
	aheal_action.Remove(src)
