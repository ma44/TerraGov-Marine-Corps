//A behavior module that moves to a thing and does something with it

/datum/element/behavior_module/combat
	var/list/typepaths_to_trigger = list() //Tyeppaths that trigger this module to designate it as a target
	var/list/targets = list() //Cached list of targets for signal registration and removal

/datum/element/behavior_module/combat/Attach(atom/thing_being_attached, list/typepaths_to_trigger)
	. = ..()
	src.typepaths_to_trigger[thing_being_attached] = typepaths_to_trigger

/datum/element/behavior_module/combat/Detach(datum/source)
	//for(var/signal in typepaths_to_trigger[source])
	//	UnregisterSignal(source, signal)
	UnregisterSignal(source, COMSIG_SEARCH_DETECTED_SOMETHING, .proc/designate_target)
	typepaths_to_trigger.Remove(source)
	undesignate_target(source, targets[source])
	return ..()

/datum/element/behavior_module/combat/initial_signal_registration(atom/thing_being_attached)
	//for(var/signal in typepaths_to_trigger[thing_being_attached])
	//	to_chat(world, "[signal] signal output register")
	RegisterSignal(thing_being_attached, COMSIG_SEARCH_DETECTED_SOMETHING, .proc/designate_target)

/datum/element/behavior_module/combat/register_stance_signals(datum/source, stance)
	switch(stance)
		if(AI_ATTACKING)
			//for(var/signal in typepaths_to_trigger[source]) ALLOW REFRESHING OF TARGET FOR NOW
			//	UnregisterSignal(source, signal)
			RegisterSignal(source, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attempt_attack_target)

/datum/element/behavior_module/combat/unregister_stance_signals(datum/source, stance)
	switch(stance)
		if(AI_ATTACKING)
			//for(var/signal in typepaths_to_trigger[source])
			//	RegisterSignal(source, signal, .proc/designate_target)
			UnregisterSignal(source, COMSIG_STATE_MAINTAINED_DISTANCE)

/datum/element/behavior_module/combat/proc/designate_target(datum/source, the_target)
	var/atom/actual_target //Here for now until target prioritization is made
	if(islist(the_target))
		actual_target = pick(the_target)
	else
		actual_target = the_target
	SEND_SIGNAL(source, COMSIG_AI_ATTEMPT_CHANGE_STANCE, AI_ATTACKING, 2)
	targets[source] = actual_target
	RegisterSignal(actual_target, list(COMSIG_MOB_DEATH), .proc/undesignate_target, actual_target)
	SEND_SIGNAL(source, COMSIG_SET_AI_MOVE_TARGET, actual_target)

/datum/element/behavior_module/combat/proc/undesignate_target(datum/source, atom/the_target)
	if(!QDELETED(the_target))
		UnregisterSignal(the_target, list(COMSIG_MOB_DEATH))
		targets.Remove(the_target)
	SEND_SIGNAL(source, COMSIG_AI_ATTEMPT_CHANGE_STANCE, AI_ROAMING, 1, forced_change = TRUE)

/datum/element/behavior_module/combat/proc/attempt_attack_target(datum/source, atom/the_target)
	if(ismob(source))
		var/mob/source_mob = source
		source_mob.ClickOn(the_target)
