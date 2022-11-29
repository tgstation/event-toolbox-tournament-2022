/area/event
	name = "Event Area"
	requires_power = FALSE
	has_gravity = TRUE

	// Fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255

/area/event/oceanarium
	name = "Oceanarium"
	static_lighting = TRUE
	base_lighting_alpha = 0

/area/event/cavern
	name = "Cavern"
	static_lighting = TRUE
	base_lighting_alpha = 0

/area/event/nightclub
	name = "Club"
	static_lighting = TRUE
	base_lighting_alpha = 0

// Make arrivals area fullbright, since this is where latejoins go
/area/shuttle/arrival
	requires_power = FALSE
	has_gravity = TRUE

	// Fullbright
	static_lighting = FALSE
	base_lighting_alpha = 255
