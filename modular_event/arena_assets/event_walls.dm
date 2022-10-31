/turf/closed/indestructible/event/
    name = "wall"
    desc = "Effectively impervious to conventional methods of destruction."

/turf/closed/indestructible/event/pod_orange
    icon = 'icons/turf/walls/survival_pod_walls.dmi'
    base_icon_state = "survival_pod_walls"
    icon_state = "survival_pod_walls-0"
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TITANIUM_WALLS)
    canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/indestructible/event/pod_blue
    icon = 'modular_event/arena_assets/survival_pod_walls_blue.dmi'
    base_icon_state = "survival_pod_walls"
    icon_state = "survival_pod_walls-0"
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TITANIUM_WALLS)
    canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/indestructible/event/pod_purple
    icon = 'modular_event/arena_assets/survival_pod_walls_purple.dmi'
    base_icon_state = "survival_pod_walls"
    icon_state = "survival_pod_walls-0"
    smoothing_flags = SMOOTH_BITMASK
    smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TITANIUM_WALLS)
    canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_SHUTTLE_PARTS)

/turf/closed/indestructible/event/rock
	name = "rock"
	icon = 'icons/turf/walls/rock_wall.dmi'
	icon_state = "rock_wall-0"
	base_icon_state = "rock_wall"
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_BORDER
	canSmoothWith = list(SMOOTH_GROUP_CLOSED_TURFS)

/turf/closed/indestructible/event/rock/Initialize(mapload)
	. = ..()
	var/matrix/M = new
	M.Translate(-4, -4)
	transform = M
