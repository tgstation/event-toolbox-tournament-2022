/// Automatically equips the VIP outfit for donators (as well as the trait), and those in tournament teams
SUBSYSTEM_DEF(auto_equip)
	name = "Event - Auto-equipment"
	flags = SS_NO_FIRE

	var/list/vips = list()

/datum/controller/subsystem/auto_equip/Initialize(start_timeofday)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, .proc/on_job_after_spawn)
	return SS_INIT_SUCCESS

/datum/controller/subsystem/auto_equip/proc/on_job_after_spawn(datum/source, mob/living/spawned, client/client)
	SIGNAL_HANDLER

	if (!(client?.ckey in vips))
		return

/datum/controller/subsystem/auto_equip/OnConfigLoad()
	vips.Cut()

	var/vip_file = "[config.directory]/vips.txt"
	if (!fexists(vip_file))
		log_config("Couldn't load vips.txt")
		message_admins("Couldn't load vips.txt")

		return

	log_config("Loading vips.txt")
	for (var/vip in world.file2list(vip_file))
		vips += ckey(vip)

/mob/living/carbon/human/dress_up_as_job(datum/job/equipping, visual_only)
	dna.species.pre_equip_species_outfit(equipping, src, visual_only)

	if (!istype(equipping, SSjob.overflow_role))
		equipOutfit(equipping.outfit, visual_only)
		return

	var/ckey = ckey(mind?.key)
	var/team_outfit

	for (var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/tournament_team = GLOB.tournament_teams[team_name]

		if (ckey in tournament_team.roster)
			team_outfit = tournament_team.outfit
			break

	if (team_outfit)
		// Equip everything else *after* team stuff, so they have their backpacks still.
		equip_inert_outfit(team_outfit)

	if (ckey in SSauto_equip.vips)
		equipOutfit(/datum/outfit/job/vip, visual_only)
	else
		equipOutfit(equipping.outfit, visual_only)

/mob/living/carbon/human/proc/equip_inert_outfit(datum/outfit/model_outfit)
	var/datum/outfit/camo_placeholder = new
	if (model_outfit.belt)
		camo_placeholder.belt = /obj/item/storage/belt/chameleon
	if (model_outfit.back)
		camo_placeholder.back = /obj/item/storage/backpack/chameleon
	if (model_outfit.ears)
		camo_placeholder.ears = /obj/item/radio/headset/chameleon
	if (model_outfit.glasses)
		camo_placeholder.glasses = /obj/item/clothing/glasses/chameleon
	if (model_outfit.gloves)
		camo_placeholder.gloves = /obj/item/clothing/gloves/chameleon
	if (model_outfit.head)
		camo_placeholder.head = /obj/item/clothing/head/chameleon
	if (model_outfit.mask)
		camo_placeholder.mask = /obj/item/clothing/mask/chameleon
	if (model_outfit.neck)
		camo_placeholder.neck = /obj/item/clothing/neck/chameleon
	if (model_outfit.shoes)
		camo_placeholder.shoes = /obj/item/clothing/shoes/chameleon
	if (model_outfit.suit)
		camo_placeholder.suit = /obj/item/clothing/suit/chameleon
	if (model_outfit.uniform)
		camo_placeholder.uniform = /obj/item/clothing/under/chameleon

	camo_placeholder.equip(src)
	qdel(camo_placeholder)

	// mostly copy pasta from chameleon_outfit/proc/select_outfit but a lot less restrictive
	var/list/outfit_parts = model_outfit.get_chameleon_disguise_info()
	for(var/datum/action/item_action/chameleon/change/change_action as anything in chameleon_item_actions)
		for(var/outfit_part in outfit_parts)
			if(ispath(outfit_part, change_action.chameleon_type))
				change_action.update_look(src, outfit_part)
				break
		var/atom/target = change_action.target
		// make the gear fully combat inert
		target.armor = new

	//suit hoods
	//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
	if(istype(wear_suit, /obj/item/clothing/suit/chameleon) && istype(head, /obj/item/clothing/head/chameleon))
		var/helmet_type
		if(ispath(model_outfit.suit, /obj/item/clothing/suit/hooded))
			var/obj/item/clothing/suit/hooded/hooded = model_outfit.suit
			helmet_type = initial(hooded.hoodtype)
		if(helmet_type)
			var/obj/item/clothing/head/chameleon/hat = head
			hat.chameleon_action.update_look(src, helmet_type)

	// lock cham appearance
	for(var/action in chameleon_item_actions)
		qdel(action) // we can't just QDEL_LIST instead because the Cut() will fail

/datum/outfit/job/vip
	name = "Donator"
	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/centcom/vip

	box = /obj/item/storage/box/survival/tournament/vip
	backpack_contents = list(/obj/item/storage/box/syndie_kit/chameleon = 1)

	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/hats/bowler
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/suit/black_really
	gloves = /obj/item/clothing/gloves/color/white

/datum/outfit/job/assistant
	box = /obj/item/storage/box/survival/tournament

// Override cham kit to omit gun
/obj/item/storage/box/syndie_kit/chameleon/PopulateContents()
	new /obj/item/clothing/under/chameleon(src)
	new /obj/item/clothing/suit/chameleon(src)
	new /obj/item/clothing/gloves/chameleon(src)
	new /obj/item/clothing/shoes/chameleon(src)
	new /obj/item/clothing/glasses/chameleon(src)
	new /obj/item/clothing/head/chameleon(src)
	new /obj/item/clothing/mask/chameleon(src)
	new /obj/item/clothing/neck/chameleon(src)
	new /obj/item/storage/backpack/chameleon(src)
	new /obj/item/storage/belt/chameleon(src)
	new /obj/item/radio/headset/chameleon(src)
	new /obj/item/modular_computer/tablet/pda/chameleon(src)

// Tournament box
/obj/item/storage/box/survival/tournament/
	name = "tournament survival box"

/obj/item/storage/box/survival/tournament/PopulateContents()
	..()

	new /obj/item/binoculars(src)
	new /obj/item/teleportation_scroll(src)
	//new /obj/item/cowbell(src)
	new /obj/item/toy/foamfinger/toolbox(src)

/obj/item/storage/box/survival/tournament/vip/PopulateContents()
	..()

	new /obj/item/clothing/accessory/medal/bronze_heart/donator(src)
	new /obj/item/clothing/glasses/hud/health(src)

/obj/item/clothing/accessory/medal/bronze_heart/donator
	name = "Donator medal"
	desc = "A medal for those who gave back to help a good cause."

/obj/item/toy/foamfinger/toolbox
	name = "tournament foam finger"
	desc = "root for your favorite toolbox team!"
