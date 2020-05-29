
/datum/behavior_module
	var/datum/component/ai_holder/source_holder //Cached over here to read variables easily, this entire thing could actually just be global datum element

//Provides a list of values to make variables into
/datum/behavior_module/proc/apply_parameters(list/values)

/datum/behavior_module/New()
	..()
	inital_register_signals()

//Register signals when initialized
/datum/behavior_module/proc/inital_register_signals()

//Register signals related to the stance of the AI holder
/datum/behavior_module/proc/register_stance_signals(stance)

/datum/behavior_module/proc/unregister_stance_signals(stance)
