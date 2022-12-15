/obj/item/fish/coinfish
	name = "coin fish"
	desc = "A widely used piece of currency, though depreciated in value."
	icon = 'modular_event/fishing/eventfish.dmi'
	icon_state = "coin_fish"
	average_size = 10
	average_weight = 2500
	fish_ai_type = FISH_AI_ZIPPY
	fishing_difficulty_modifier = 5

/obj/item/fish/toolboxfish
	name = "toolbox fish"
	desc = "A solitary fish, known to swim vertically, refusing to go horizontal. Looks quite robust."
	icon = 'modular_event/fishing/eventfish.dmi'
	icon_state = "toolbox_fish"
	average_size = 80
	average_weight = 3000
	fish_ai_type = FISH_AI_ZIPPY
	force = 12
	throwforce = 12
	throw_speed = 2
	throw_range = 4
	wound_bonus = 4
	attack_verb_continuous = list("fishily robusts", "robustly slaps")
	attack_verb_simple = list("fishily robust", "robustly slap")
	hitsound = 'modular_event/fishing/fishslap.ogg'
	fishing_difficulty_modifier = 10

/obj/item/fish/gunner_jellyfish
	average_size = 40
	average_weight = 800
