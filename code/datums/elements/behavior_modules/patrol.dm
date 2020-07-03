#define NODE_LAST_VISITED "last_visit_scale"

//A behavior module that picks out the best node to go towards based on some parameters

/datum/element/behavior_module/patrol
	var/list/preferred_weights = list() //What weights does this want to go towards? see /obj/effect/ai_node/proc/GetBestAdjNode()
	var/list/current_nodes = list() //Rather than constantly asking the component for what node this thing is "at", cache it here
	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2

/datum/element/behavior_module/patrol/Attach(atom/thing_being_attached, list/preferred_weights = list())
	if(!ismovableatom(thing_being_attached))
		return ELEMENT_INCOMPATIBLE
	var/datum/component/ai_holder/ai_holder = thing_being_attached.GetComponent(/datum/component/ai_holder)
	if(QDELETED(ai_holder) || !ai_holder.current_node)
		for(var/obj/effect/ai_node/node in range(9))
			current_nodes[thing_being_attached] = node
			break
		if(!current_nodes[thing_being_attached])
			return ELEMENT_INCOMPATIBLE
	else
		current_nodes[thing_being_attached] = ai_holder.current_node
	. = ..()
	src.preferred_weights[thing_being_attached] = preferred_weights
	/*
	var/assoc_list //Can't have a #define key = value at compile, thanks byond
	for(var/weight in preferred_weights)
		assoc_list = list(weight)
		assoc_list[weight] = preferred_weights_multipliers[1]
		preferred_weights_multipliers.Cut(1)
	src.preferred_weights[thing_being_attached] = assoc_list
	*/

/datum/element/behavior_module/patrol/Detach(datum/source)
	preferred_weights.Remove(source)
	current_nodes.Remove(source)
	..()

/datum/element/behavior_module/patrol/register_stance_signals(atom/the_ai_thing, stance)
	switch(stance)
		if(AI_ROAMING)
			RegisterSignal(the_ai_thing, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/node_reached)
			SEND_SIGNAL(the_ai_thing, COMSIG_SET_AI_MOVE_TARGET, current_nodes[the_ai_thing].GetBestAdjNode(preferred_weights[the_ai_thing]))

/datum/element/behavior_module/patrol/unregister_stance_signals(the_ai_thing, stance)
	switch(stance)
		if(AI_ROAMING)
			UnregisterSignal(the_ai_thing, COMSIG_STATE_MAINTAINED_DISTANCE)

/datum/element/behavior_module/patrol/proc/node_reached(datum/source, obj/effect/ai_node/the_node)
	the_node.weights[NODE_LAST_VISITED] = 0
	current_nodes[source] = the_node
	SEND_SIGNAL(source, COMSIG_MADE_IT_TO_NODE, the_node)
	SEND_SIGNAL(source, COMSIG_SET_AI_MOVE_TARGET, the_node.GetBestAdjNode(preferred_weights[source]))
