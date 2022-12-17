/datum/smite/blindness
	name = "Blindness"

/datum/smite/blindness/effect(client/user, mob/living/target)
	. = ..()

	to_chat(target, span_userdanger("You scream in terror as you suddenly go blind!"))
	target.emote("scream")

	if(!iscarbon(target))
		target.set_blindness(200)
		return

	var/obj/item/organ/internal/eyes/eyes = target.getorganslot(ORGAN_SLOT_EYES)
	eyes.applyOrganDamage(eyes.maxHealth)

/datum/smite/reverse_controls
	name = "Reverse controls"

/datum/smite/reverse_controls/effect(client/user, mob/target)
	. = ..()

	if(!target.client)
		to_chat(user, span_warning("Target has no client!"), confidential = TRUE)
		return

	target.transform = target.transform.Turn(180)
	var/client/target_client = target.client
	var/list/keys = target_client.movement_keys.Copy()
	target_client.movement_keys["W"] = keys["S"]
	target_client.movement_keys["S"] = keys["W"]
	target_client.movement_keys["A"] = keys["D"]
	target_client.movement_keys["D"] = keys["A"]
	target_client.movement_keys["North"] = keys["South"]
	target_client.movement_keys["South"] = keys["North"]
	target_client.movement_keys["West"] = keys["East"]
	target_client.movement_keys["East"] = keys["West"]
	to_chat(target, span_userdanger("Hey why is the world turning upside down?"))

/datum/smite/chicken_hat
	name = "Cursed chicken head"

/datum/smite/chicken_hat/effect(client/user, mob/living/target)
	. = ..()

	var/obj/item/clothing/head/costume/chicken/head = new
	head.name = "Cursed chicken head"
	ADD_TRAIT(head, TRAIT_NODROP, "tournament")
	target.equip_to_slot_if_possible(head, ITEM_SLOT_HEAD)
	target.say("BWAK!!", forced = TRUE)
	to_chat(target, span_userdanger("BWAK!!"))

/datum/smite/purrbate
	name = "Purrbation"

/datum/smite/purrbate/effect(client/user, mob/living/target)
	. = ..()

	if(!ishuman(target))
		to_chat(user, span_warning("Target must be human!"), confidential = TRUE)
		return

	purrbation_toggle(target)
