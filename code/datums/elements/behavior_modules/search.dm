//A behavior module that occasionally looks for things nearby and creates a list of stuff it found that matched a criteria

/datum/element/behavior_module/search
	var/list/search_distance = list() //Search distance away from center of mob
	var/list/glob_list_only = list() //If TRUE, assume that the list to filter through all are the type we're looking for and may or may not be in range of the AI
	var/list/typepaths_to_find = list() //Typepaths to look for and bundle up in a list and send it as a param with the associated signal type

	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 4

/datum/element/behavior_module/search/Attach(atom/thing_being_attached, search_distance, glob_list_only, typepaths_to_find)
	. = ..()
	src.search_distance[thing_being_attached] = search_distance
	src.glob_list_only[thing_being_attached] = glob_list_only
	src.typepaths_to_find[thing_being_attached] = typepaths_to_find
	RegisterSignal(thing_being_attached, COMSIG_TRIGGER_SEARCH_MODULE, .proc/execute_search)

/datum/element/behavior_module/search/Detach(datum/source)
	search_distance.Remove(source)
	glob_list_only.Remove(source)
	typepaths_to_find.Remove(source)
	UnregisterSignal(source, COMSIG_TRIGGER_SEARCH_MODULE)
	return ..()

/datum/element/behavior_module/search/New()
	..()
	START_PROCESSING(SSprocessing, src)

/datum/element/behavior_module/search/process()
	execute_search(send_signal = TRUE)

//Execute a search right now instead of waiting on process(); send_signal means it will send a signal with the list to the AI when set to true
//This will also always return a list of what it found

/datum/element/behavior_module/search/proc/execute_search(send_signal = FALSE)
	var/list/list_to_send = list() //List of things we wanna send VIA as a parameter of a paired sigtype
	for(var/atom/ai_controlled in things_attached)
		var/list/filter_through //Things we gotta filter through like GLOB lists or range() if we use them
		var/list/layered_list = typepaths_to_find[ai_controlled] //Should be = list(SIGTYPE_TO_SEND = list(typepaths_to_find))
		for(var/sigtype in layered_list) 					//Foreach in list   ^^^
			for(var/typepath in layered_list[sigtype]) //And this should be the typepaths
				//This setup would be nicer if GLOB lists could be set up like associative lists so I don't need to switch()
				switch(typepath) //However if there's a certan type, we'll ultilize the GLOB list of it rather than range()
					if(/mob/living/carbon/human) //There should be a better way of doing this
						filter_through += GLOB.human_mob_list
					if(/mob/living/carbon/xenomorph)
						filter_through += GLOB.xeno_mob_list
					if(/obj/machinery/marine_turret)
						filter_through += GLOB.marine_turrets
		if(!glob_list_only[ai_controlled])
			filter_through += range(search_distance[ai_controlled], ai_controlled)

		if(glob_list_only[ai_controlled])
			for(var/atom/movable/thing in filter_through)
				var/atom/movable/movable_parent = ai_controlled
				if((movable_parent.z != thing.z) || (get_dist(ai_controlled, thing) >= search_distance[ai_controlled]) || thing == ai_controlled)
					continue
				if(ismob(thing))
					var/mob/thing2 = thing
					if(thing2.stat == DEAD)
						continue
				list_to_send += thing

		else //We're assuming that everything in the list is in range, so all we need are some type comparisons and maybe other checks
			var/is_type //Is the thing a type present in the parameters or nah
			filter_through += range(search_distance[ai_controlled], ai_controlled)
			for(var/atom/movable/thing in filter_through)
				if(thing == ai_controlled)
					return
				is_type = FALSE
				for(var/list/sigtype in layered_list)
					for(var/typepath in layered_list[sigtype]) //And this should be the typepaths
						if(istype(thing, type))
							is_type = TRUE
							break //If it matches one of the types it's good to go
						continue

					if(!is_type)
						continue

					list_to_send += thing

		if(length(list_to_send))
			if(send_signal)
				SEND_SIGNAL(ai_controlled, layered_list[1], list_to_send)
	return list_to_send
