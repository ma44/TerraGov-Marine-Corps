// A behavior module that intercepts a list of typepaths then looks through them to determine if it should trigger additional modules or not
// For example it can look for any instances of human typepaths and if so, trigger the combat mode to start a search and destroy operation

/datum/behavior_module/action_trigger
	var/list/typepath_triggers

/datum/behavior_module/action_trigger/apply_parameters(list/values)
	typepath_triggers = values[1]

/datum/behavior_module/action_trigger/initial_signal_registration()
	RegisterSignal(source_holder.parent, COMSIG_AI_SEARCH_DETECTED, .proc/filter_through_list)

// Filter through the list to see if we should trigger some other behavior modules or not
/datum/behavior_module/action_trigger/proc/filter_through_list(datum/source, things)
	for(var/atom/thing in things)
		for(var/type_to_find in typepath_triggers) //The signal to send being the key while the type is a value is intended
			if(istype(thing, typepath_triggers[type_to_find]))
				SEND_SIGNAL(source_holder.parent, type_to_find, thing)
				return
