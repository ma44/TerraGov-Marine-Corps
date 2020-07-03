//A behavior module that occasionally looks for things nearby and creates a list of stuff it found that matched a criteria

/datum/element/behavior_module/search
	var/list/typepaths_to_find = list()
	var/list/search_distance = list() //Search distance away from center of mob
	var/list/glob_list_only = list() //If TRUE, assume that the list to filter through all are the type we're looking for and may or may not be in range of the AI
	var/list/require_alive = list() //If TRUE, requires that the thing must be "alive" (if it's a mob), otherwise will be alright if dead/alive

/datum/element/behavior_module/search/Attach(atom/thing_being_attached, typepaths_to_find, search_distance, glob_list_only, require_alive)
	. = ..()
	src.typepaths_to_find[thing_being_attached] = typepaths_to_find
	src.search_distance[thing_being_attached] = search_distance
	src.glob_list_only[thing_being_attached] = glob_list_only
	src.require_alive[thing_being_attached] = require_alive

/datum/element/behavior_module/search/Detach(datum/source)
	typepaths_to_find.Remove(source)
	search_distance.Remove(source)
	glob_list_only.Remove(source)
	require_alive.Remove(source)
	return ..()

/datum/element/behavior_module/search/New()
	..()
	START_PROCESSING(SSprocessing, src)

/datum/element/behavior_module/search/process()
	for(var/atom/ai_controlled in things_attached)
		var/list/filter_through //Things we gotta filter through
		for(var/typepath in typepaths_to_find[ai_controlled])
			switch(typepath) //However if there's a certan type, we'll ultilize the GLOB list of it rather than range()
				if(/mob/living/carbon/human) //There should be a better way of doing this
					filter_through += GLOB.human_mob_list
				if(/mob/living/carbon/xenomorph)
					filter_through += GLOB.xeno_mob_list
				if(/obj/machinery/marine_turret)
					filter_through += GLOB.marine_turrets
		if(!glob_list_only[ai_controlled])
			filter_through += range(search_distance[ai_controlled], ai_controlled)

		var/list/list_to_send = list() //Send this list as a signal if it has stuff that passed our criterias
		if(glob_list_only[ai_controlled])
			for(var/atom/movable/thing in filter_through)
				var/atom/movable/movable_parent = ai_controlled
				if((movable_parent.z != thing.z) || (get_dist(ai_controlled, thing) >= search_distance[ai_controlled]) || thing == ai_controlled)
					continue
				list_to_send += thing

		else //We're assuming that everything in the list is in range, so all we need are some type comparisons and maybe other checks
			var/is_type //Is the thing a type present in the parameters or nah
			filter_through += range(search_distance[ai_controlled], ai_controlled)
			for(var/atom/movable/thing in filter_through)
				if(thing == ai_controlled)
					return
				is_type = FALSE
				for(var/type in typepaths_to_find[ai_controlled])
					if(istype(thing, type))
						is_type = TRUE
						break //If it matches one of the types it's good to go
					continue

				if(!is_type)
					continue

				list_to_send += thing

		if(require_alive[ai_controlled])
			for(var/mob/mob_thing in list_to_send)
				if(!mob_thing) //It's not a mob so it gets a pass
					continue
				if(mob_thing.stat == DEAD)
					list_to_send -= mob_thing

		if(length(list_to_send))
			SEND_SIGNAL(ai_controlled, COMSIG_AI_SEARCH_DETECTED, list_to_send)
