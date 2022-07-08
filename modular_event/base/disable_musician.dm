// Instruments cause terrible lag.
// This disables the musician quirk, and lets players know.
/datum/quirk/item_quirk/musician
	desc = "This quirk is disabled for performance problems, sorry!"
	gain_text = "<span class='boldnotice'>The musician quirk is disabled for performance problems, sorry!</span>"

/datum/quirk/item_quirk/musician/add_unique()
	return
