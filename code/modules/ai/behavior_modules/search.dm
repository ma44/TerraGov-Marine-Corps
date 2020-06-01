//A behavior module that occasionally looks for things nearby and creates a list of stuff it found that matched a criteria

/datum/behavior_module/search
	var/list/typepaths_to_find
	var/search_distance //Search distance away from center of mob
	var/glob_list_only //If TRUE, assume that the list to filter through all are the type we're looking for and may or may not be in range of the AI
	var/require_alive //If TRUE, requires that the thing must be "alive" (if it's a mob), otherwise will be alright if dead/alive

/datum/behavior_module/search/New()
	..()
	START_PROCESSING(SSprocessing, src)

/datum/behavior_module/search/apply_parameters(list/values)
	typepaths_to_find = values[1]
	search_distance = values[2]
	glob_list_only = values[3]
	require_alive = values[4]

/datum/behavior_module/search/process()
	var/list/filter_through //Things we gotta filter through
	for(var/typepath in typepaths_to_find)
		switch(typepath) //However if there's a certan type, we'll ultilize the GLOB list of it rather than range()
			if(/mob/living/carbon/human)
				filter_through += GLOB.human_mob_list
			if(/mob/living/carbon/xenomorph)
				filter_through += GLOB.xeno_mob_list
			if(/obj/machinery/marine_turret)
				filter_through += GLOB.marine_turrets
	if(!glob_list_only)
		filter_through += range(search_distance, source_holder.parent)

	var/list/list_to_send = list() //Send this list as a signal if it has stuff that passed our criterias
	if(glob_list_only)
		for(var/atom/movable/thing in filter_through)
			var/atom/movable/movable_parent = source_holder.parent
			if((movable_parent.z == thing.z) && (get_dist(source_holder.parent, thing) <= search_distance))
				continue
			list_to_send += thing

	else //We're assuming that everything in the list is in range, so all we need are some type comparisons and maybe other checks
		var/is_type //Is the thing a type present in the parameters or nah
		filter_through += range(search_distance, source_holder.parent)
		for(var/atom/movable/thing in filter_through)
			is_type = FALSE
			for(var/type in typepaths_to_find)
				if(istype(thing, type))
					is_type = TRUE
					break //If it matches one of the types it's good to go
				continue

			if(!is_type)
				continue

			list_to_send += thing


	if(require_alive)
		for(var/mob/mob_thing in list_to_send)
			if(!mob_thing) //It's not a mob so it gets a pass
				continue
			if(mob_thing.stat == DEAD)
				list_to_send -= mob_thing

	if(length(list_to_send))
		SEND_SIGNAL(source_holder.parent, COMSIG_AI_SEARCH_DETECTED, list_to_send)
