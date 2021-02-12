//Various macros
#define NODE_GET_VALUE_OF_WEIGHT(IDENTIFIER, NODE, WEIGHT_NAME) NODE.weights[IDENTIFIER][WEIGHT_NAME]

//The equivalent of get_step_towards but now for nodes; will NOT intelligently pathfind based on node weights or anything else
//Returns nothing if a suitable node in a direction isn't found, otherwise returns a node
/proc/get_node_towards(obj/effect/ai_node/startnode, obj/effect/ai_node/destination)
	if(startnode == destination)
		return startnode
	//Null value returned means no node in that direction
	return startnode.get_node_in_dir_in_adj(get_dir(startnode, destination))

///Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/movable/source, distance)
	. = list()
	for(var/human in GLOB.humans_by_zlevel["[source.z]"])
		var/mob/living/carbon/human/nearby_human = human
		if(get_dist(source, nearby_human) > distance)
			continue
		. += nearby_human

//Returns a list of xenos via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_xenos_near(atom/movable/source, distance)
	. = list()
	for(var/xeno in GLOB.alive_xeno_list)
		var/mob/living/carbon/xenomorph/nearby_xeno = xeno
		if(source.z != nearby_xeno.z)
			continue
		if(get_dist(source, nearby_xeno) > distance)
			continue
		. += nearby_xeno

/*
Returns the closest thing to the source_mob out of the input list
*/

/proc/get_closest_thing_in_list(atom/source_mob, list/input_list)
	var/atom/likely_target //What we currently wanna kill
	var/likely_target_dist = INFINITY //Distance from source mob to the likely target

	for(var/atom/thing in input_list)
		if(get_dist(source_mob, thing) < likely_target_dist)
			likely_target_dist = get_dist(source_mob, thing)
			likely_target = thing

	return likely_target







