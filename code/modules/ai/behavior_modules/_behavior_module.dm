
/datum/behavior_module
	var/datum/component/ai_holder/source_holder //Cached over here to read variables easily, this entire thing could actually just be global datum element

//Initial signals to register after setting the proper source holder
/datum/behavior_module/proc/initial_signal_registration()

//Provides a list of values to make variables into
/datum/behavior_module/proc/apply_parameters(list/values)

//Register signals related to the stance of the AI holder
/datum/behavior_module/proc/register_stance_signals(stance)

/datum/behavior_module/proc/unregister_stance_signals(stance)
