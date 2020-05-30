//A behavior module that picks out the best node to go towards based on some parameters


/datum/behavior_module/patrol
	var/list/preferred_weights //What weights does this want to go towards? see /obj/effect/ai_node/proc/GetBestAdjNode()

/*
From first to last index of params
preferred_weights
*/
/datum/behavior_module/patrol/apply_parameters(list/values)
	preferred_weights = values[1]

/datum/behavior_module/patrol/register_stance_signals(stance)
	switch(stance)
		if(AI_ROAMING)
			RegisterSignal(source_holder.parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/node_reached)
			SEND_SIGNAL(source_holder.parent, COMSIG_SET_AI_MOVE_TARGET, source_holder.current_node.GetBestAdjNode(preferred_weights))

/datum/behavior_module/patrol/unregister_stance_signals(stance)
	switch(stance)
		if(AI_ROAMING)
			UnregisterSignal(source_holder.parent, COMSIG_STATE_MAINTAINED_DISTANCE)

//We reached a node yay
/datum/behavior_module/patrol/proc/node_reached(datum/source, atom/target)
	to_chat(world, "we made it bois")
	to_chat(world, "[source]")
	to_chat(world, "target next")
	to_chat(world, "[target]")
	source_holder.current_node = target
