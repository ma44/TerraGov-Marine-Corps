//Really just exists to be given a target and dist to maintain to get moving

/datum/behavior_module/movement
	var/dist_to_maintain //How much distance we want to maintain from something
	var/atom/target //Thing we're walking towards
	var/sidestep_prob //Chance of sidestepping when distance is maintained and ready to move again

	//Wait for a signal to get us to move
/datum/behavior_module/movement/inital_register_signals()
	RegisterSignal(source_holder.parent, list(COMSIG_SET_AI_MOVE_TARGET), .proc/set_new_move_target)

/datum/behavior_module/movement/proc/set_new_move_target(datum/source, atom/new_target)
	target = new_target
	source_holder.parent.AddElement(/datum/element/pathfinder, new_target, dist_to_maintain, sidestep_prob)

/*
From first to last index of params
dist_to_maintain
sidestep_prob
*/
/datum/behavior_module/movement/apply_parameters(list/values)
	dist_to_maintain = values[1]
	sidestep_prob = values[2]

