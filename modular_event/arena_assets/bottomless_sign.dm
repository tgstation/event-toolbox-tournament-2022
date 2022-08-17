/obj/structure/sign/bottomless
	name = "bottomless pit"
	desc = "I sure hope nobody puts a bottom in the pit."
	icon_state = "bottomlesspit1"
	icon = 'modular_event/arena_assets/sign2.dmi'
	custom_materials = list(/datum/material/wood = 2000)

/obj/structure/sign/bottomless/examine(mob/user)
	. = ..()
	. += span_nicegreen(">be me")
	. += span_nicegreen(">bottomless pit supervisor")
	. += span_nicegreen(">in charge of making sure the bottomless pit is, in fact, bottomless")
	. += span_nicegreen(">occasionally have to go down there and check if the bottomless pit is still bottomless")
	. += span_nicegreen(">one day i go down there and the bottomless pit is no longer bottomless")
	. += span_nicegreen(">the bottom of the bottomless pit is now just a regular pit")
	. += span_nicegreen(">distress.png")
