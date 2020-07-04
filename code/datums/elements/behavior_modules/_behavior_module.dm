/*
A collection of behavior modules for AI related behavior
These modules allow for mix and matching of various behaviors together
*/

/datum/element/behavior_module
	var/list/things_attached = list() //A list of things attached to this behavior module, cached for stance signals and such

/datum/element/behavior_module/Attach(atom/thing_being_attached)
	. = ..()
	if(type == /datum/element/behavior_module)
		return ELEMENT_INCOMPATIBLE
	if(QDELETED(thing_being_attached))
		return ELEMENT_INCOMPATIBLE
	things_attached += thing_being_attached
	RegisterSignal(thing_being_attached, COMSIG_AI_CHANGE_STANCE, .proc/change_stance)
	RegisterSignal(thing_being_attached, list(COMSIG_MOB_DEATH), .proc/Detach)
	initial_signal_registration(thing_being_attached)

/datum/element/behavior_module/Detach(datum/source)
	//Let's try and get the stance to correctly unregister some signals
	var/datum/component/ai_holder/ai_holder = source.GetComponent(/datum/component/ai_holder)
	if(ai_holder)
		unregister_stance_signals(source, ai_holder.cur_stance)
	UnregisterSignal(source, COMSIG_AI_CHANGE_STANCE, .proc/change_stance)
	UnregisterSignal(source, list(COMSIG_MOB_DEATH), .proc/Detach)
	things_attached.Remove(source)
	return ..()

//Change the stance of a ai controlled thing to another
/datum/element/behavior_module/proc/change_stance(datum/source, new_stance)
	unregister_stance_signals(source, new_stance)
	register_stance_signals(source, new_stance)

//After attaching to something, do some signal registrations for the start
/datum/element/behavior_module/proc/initial_signal_registration(thing_being_attached)

//Register signal related to a certain stance
/datum/element/behavior_module/proc/register_stance_signals(the_ai_thing, stance)

//Above but unregisters
/datum/element/behavior_module/proc/unregister_stance_signals(the_ai_thing, stance)
