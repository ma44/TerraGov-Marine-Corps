///Asks for paths to a certain target and handles movement to said target
/datum/element/behavior_module/movement
	var/list/distances_to_maintain = list() ///All controlled things as the key with the # of tiles to maintain as the value
	var/list/sidestep_probs = list() ///All controlled things as the key with the prob(#) chance to do a "sidestep" as the value; moving left or right of the original direction to move in
	var/list/destinations = list() ///A list of all controlled things as the key with the thing to move towards being the value

/datum/element/behavior_module/movement/Attach(atom/thing_being_attached, distance_to_maintain = 0, side_step_prob = 0, atom/target = null)
	. = ..()
	if(!ismob(thing_being_attached))
		return ELEMENT_INCOMPATIBLE
	distances_to_maintain[thing_being_attached] = distance_to_maintain
	sidestep_probs[thing_being_attached] = side_step_prob
	if(istype(target))
		destinations[thing_being_attached] = target

/datum/element/behavior_module/movement/Detach(datum/source)
	UnregisterSignal(source, COMSIG_SET_AI_MOVE_TARGET)
	distances_to_maintain.Remove(source)
	sidestep_probs.Remove(source)
	destinations.Remove(source)
	return ..()


//TODO: see pathfinder element
/datum/element/behavior_module/movement/process()
	for(var/mob in distances_to_maintain)
		var/mob/mob_to_process = mob
		if(!targets[mob_to_process]) //No targets to move towards
			continue

		

/datum/element/behavior_module/movement/initial_signal_registration(atom/thing_being_attached)
	RegisterSignal(thing_being_attached, COMSIG_SET_AI_MOVE_TARGET, .proc/set_new_move_target)

///Modifies the targets variable to associate source with new_target
/datum/element/behavior_module/movement/proc/set_new_move_target(datum/source, atom/new_target)
	SIGNAL_HANDLER
	targets[source] = new_target

