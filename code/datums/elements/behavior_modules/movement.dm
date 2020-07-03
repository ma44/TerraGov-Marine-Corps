//Intercepts a certain signal to then plot a move course according to parameters

/datum/element/behavior_module/movement
	var/list/distances_to_maintain = list() //How much distance we want to maintain from something
	var/list/sidestep_probs = list() //Chance of sidestepping when distance is maintained and ready to move again
	id_arg_index = 3

/datum/element/behavior_module/movement/Attach(atom/thing_being_attached, distance_to_maintain = 0, side_step_prob = 0)
	if(!ismovableatom(thing_being_attached))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	distances_to_maintain[thing_being_attached] = distance_to_maintain
	sidestep_probs[thing_being_attached] = side_step_prob

/datum/element/behavior_module/movement/Detach(datum/source)
	UnregisterSignal(source, COMSIG_SET_AI_MOVE_TARGET)
	distances_to_maintain.Remove(source)
	sidestep_probs.Remove(source)
	return ..()

/datum/element/behavior_module/movement/initial_signal_registration(atom/thing_being_attached)
	RegisterSignal(thing_being_attached, COMSIG_SET_AI_MOVE_TARGET, .proc/set_new_move_target)

/datum/element/behavior_module/movement/proc/set_new_move_target(datum/source, atom/new_target)
	source.RemoveElement(/datum/element/pathfinder) //Source SHOULD be a mob attached to this element because of signl interception and such
	source.AddElement(/datum/element/pathfinder, new_target, distances_to_maintain[source], sidestep_probs[source])
