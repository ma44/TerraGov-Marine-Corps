// A behavior module that intercepts a list of typepaths then looks through them to determine if it should trigger additional modules or not
// For example it can look for any instances of human typepaths and if so, trigger the combat mode to start a search and destroy operation

/datum/element/behavior_module/action_trigger
	var/list/typepath_triggers = list()

	element_flags = ELEMENT_DETACH | ELEMENT_BESPOKE
	id_arg_index = 2

/datum/element/behavior_module/action_trigger/Attach(atom/thing_being_attached, list/typepath_triggers)
	. = ..()
	src.typepath_triggers[thing_being_attached] = typepath_triggers

/datum/element/behavior_module/action_trigger/Detach(datum/source)
	UnregisterSignal(source, COMSIG_AI_SEARCH_DETECTED)
	typepath_triggers.Remove(source)
	return ..()

/datum/element/behavior_module/action_trigger/initial_signal_registration(atom/thing_being_attached)
	RegisterSignal(thing_being_attached, COMSIG_AI_SEARCH_DETECTED, .proc/filter_through_list)

// Filter through the list to see if we should trigger some other behavior modules or not
/datum/element/behavior_module/action_trigger/proc/filter_through_list(datum/source, list/things)
	var/associative_layer_one //Temp var for accessing a layered associative list
	for(var/atom/thing in things)
		for(var/type_to_find in typepath_triggers[source]) //The signal to send being the key while the type is a value is intended
			if(!istype(thing, type_to_find))
				continue
			associative_layer_one = typepath_triggers[source]
			SEND_SIGNAL(source, associative_layer_one[type_to_find], thing)
			return
