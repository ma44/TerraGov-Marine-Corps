//Asks for paths to a certain target and handles movement to said target

/datum/element/behavior_module/movement
	var/list/distances_to_maintain = list() //How much distance we want to maintain from something
	var/list/sidestep_probs = list() //Chance of sidestepping when distance is maintained and ready to move again
	var/list/targets = list() //List of targets to move towards

/datum/element/behavior_module/movement/Attach(atom/thing_being_attached, distance_to_maintain = 0, side_step_prob = 0)
	if(!ismob(thing_being_attached))
		return ELEMENT_INCOMPATIBLE
	. = ..()
	distances_to_maintain[thing_being_attached] = distance_to_maintain
	sidestep_probs[thing_being_attached] = side_step_prob

/datum/element/behavior_module/movement/Detach(datum/source)
	//UnregisterSignal(source, COMSIG_SET_AI_MOVE_TARGET)
	distances_to_maintain.Remove(source)
	sidestep_probs.Remove(source)
	STOP_PROCESSING(SSpathfinding, src)
	return ..()

/*
/datum/element/behavior_module/movement/process()
	for(var/mob in distances_to_maintain)
		var/mob/mob_to_process = mob
		if(!targets[mob_to_process]) //No targets to move towards
*/
///datum/element/behavior_module/movement/initial_signal_registration(atom/thing_being_attached)
	//RegisterSignal(thing_being_attached, COMSIG_SET_AI_MOVE_TARGET, .proc/set_new_move_target)

/*
///Sets a new move target and starts processing when needed
/datum/element/behavior_module/movement/proc/set_new_move_target(datum/source, atom/new_target)
	SIGNAL_HANDLER
	source.RemoveElement(/datum/element/pathfinder) //Source SHOULD be a mob attached to this element because of the way signal interception got set up
	source.AddElement(/datum/element/pathfinder, new_target, distances_to_maintain[source], sidestep_probs[source])
*/