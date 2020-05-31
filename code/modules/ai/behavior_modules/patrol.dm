//A behavior module that picks out the best node to go towards based on some parameters


/datum/behavior_module/patrol
	var/list/preferred_weights //What weights does this want to go towards? see /obj/effect/ai_node/proc/GetBestAdjNode()

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

/datum/behavior_module/patrol/proc/node_reached(datum/source, atom/target)
	source_holder.current_node = target
	SEND_SIGNAL(source_holder.parent, COMSIG_MADE_IT_TO_NODE, source_holder.current_node)
	SEND_SIGNAL(source_holder.parent, COMSIG_SET_AI_MOVE_TARGET, source_holder.current_node.GetBestAdjNode(preferred_weights))
