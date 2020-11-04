//A behavior module that moves to a thing and does something with it

/datum/element/behavior_module/combat
	var/list/typepaths_to_trigger = list() //Tyeppaths that trigger this module to designate it as a target
	var/list/targets = list() //Cached list of targets for signal registration and removal
	var/list/allow_overriding_target = list() //If we want to allow designating a new target to override the old one

/datum/element/behavior_module/combat/Attach(atom/thing_being_attached, list/typepaths_to_trigger, allow_overriding_target = FALSE)
	. = ..()
	src.typepaths_to_trigger[thing_being_attached] = typepaths_to_trigger
	src.allow_overriding_target[thing_being_attached] = allow_overriding_target

/datum/element/behavior_module/combat/Detach(datum/source)
	UnregisterSignal(source, COMSIG_SEARCH_DETECTED_SOMETHING, .proc/designate_target)
	typepaths_to_trigger.Remove(source)
	allow_overriding_target.Remove(source)
	undesignate_target(source, targets[source])
	return ..()

/datum/element/behavior_module/combat/New()
	..()
	START_PROCESSING(SSprocessing, src)

/datum/element/behavior_module/combat/initial_signal_registration(atom/thing_being_attached)
	RegisterSignal(thing_being_attached, COMSIG_SEARCH_DETECTED_SOMETHING, .proc/designate_target)

/datum/element/behavior_module/combat/register_stance_signals(datum/source, stance)
	switch(stance)
		if(AI_ATTACKING)
			RegisterSignal(source, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attempt_attack_target)

/datum/element/behavior_module/combat/unregister_stance_signals(datum/source, stance)
	switch(stance)
		if(AI_ATTACKING)
			UnregisterSignal(source, COMSIG_STATE_MAINTAINED_DISTANCE)

/datum/element/behavior_module/combat/proc/designate_target(datum/source, the_target)
	if(!allow_overriding_target[source] && targets[source]) //Can we override targets if we already got one or nah?
		return

	var/atom/actual_target
	if(islist(the_target))
		actual_target = get_closest_thing_in_list(source, the_target)
	else
		actual_target = the_target
	SEND_SIGNAL(source, COMSIG_AI_ATTEMPT_CHANGE_STANCE, AI_ATTACKING, 2)
	if(targets[source]) //If overriding a target, clear the old signals
		UnregisterSignal(targets[source], COMSIG_MOB_DEATH)
	targets[source] = actual_target
	RegisterSignal(actual_target, list(COMSIG_MOB_DEATH), .proc/undesignate_target, actual_target)
	SEND_SIGNAL(source, COMSIG_SET_AI_MOVE_TARGET, actual_target)

/datum/element/behavior_module/combat/proc/undesignate_target(datum/source, atom/the_target)
	to_chat(world, "undesignating target: [the_target]")
	if(!QDELETED(the_target))
		UnregisterSignal(the_target, COMSIG_MOB_DEATH)
		targets.Remove(the_target)
	SEND_SIGNAL(source, COMSIG_TRIGGER_SEARCH_MODULE, send_signal = TRUE) //If this search succeeds, then we have another target to kill and should continue being in our combat stance
	if(!targets[source])
		SEND_SIGNAL(source, COMSIG_AI_ATTEMPT_CHANGE_STANCE, AI_ROAMING, 1, forced_change = TRUE)

/datum/element/behavior_module/combat/proc/attempt_attack_target(datum/source, atom/the_target)
	if(ismob(source))
		var/mob/source_mob = source
		source_mob.ClickOn(the_target)
