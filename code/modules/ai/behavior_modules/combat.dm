//A behavior module that moves to a thing and does something with it

/datum/behavior_module/combat
	var/list/typepaths_to_fight
	var/prioritize_noncrit //If it's a mob, give a lower priority of killing to mobs in critical condition
	var/attack_type //Identifier to determine how we attack; specifically whenever it's a human, xenomorph etc.

/datum/behavior_module/combat/apply_parameters(list/values)
	//typepaths_to_fight = values[1]
	//prioritize_noncrit = values[1]
	attack_type = values[1]

/datum/behavior_module/combat/initial_signal_registration()
	RegisterSignal(source_holder.parent, COMSIG_AI_DETECT_HUMAN, .proc/designate_target)

/datum/behavior_module/combat/register_stance_signals(stance)
	switch(stance)
		if(AI_ATTACKING)
			UnregisterSignal(source_holder.parent, COMSIG_AI_DETECT_HUMAN)
			RegisterSignal(source_holder.parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attempt_attack_target)

/datum/behavior_module/combat/unregister_stance_signals(stance)
	switch(stance)
		if(AI_ATTACKING)
			RegisterSignal(source_holder.parent, COMSIG_AI_DETECT_HUMAN, .proc/designate_target)
			UnregisterSignal(source_holder.parent, COMSIG_STATE_MAINTAINED_DISTANCE)

/datum/behavior_module/combat/proc/designate_target(datum/source, atom/the_target)
	SEND_SIGNAL(source_holder.parent, COMSIG_AI_ATTEMPT_CHANGE_STANCE, AI_ATTACKING, 2)
	SEND_SIGNAL(source_holder.parent, COMSIG_SET_AI_MOVE_TARGET, the_target)

/datum/behavior_module/combat/proc/attempt_attack_target(datum/source, atom/the_target)
	if(ismob(source_holder.parent))
		var/mob/source_mob = source_holder.parent
		switch(attack_type)
			if(HUMAN_ATTACKS)
				source_mob.ClickOn(the_target, src)
