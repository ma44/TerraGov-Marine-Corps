//Attack identifier types
#define HUMAN_ATTACKS "human_attacks"
#define XENO_ATTACKS "xeno_attacks"

//Picks out targets it wants to harms when given appropriate input

/datum/behavior_module/combat
	var/list/typepaths_to_fight
	var/prioritize_noncrit //If it's a mob, give a lower priority of killing to mobs in critical condition
	var/attack_type //Identifier to determine how we attack; specifically whenever it's a human, xenomorph etc.

/datum/behavior_module/combat/apply_parameters(list/values)
	typepaths_to_fight = values[1]
	prioritize_noncrit = values[2]
	attack_type = values[3]

/datum/behavior_module/combat/initial_signal_registration()
	RegisterSignal(source_holder.parent, COMSIG_AI_SEARCH_DETECTED, .proc/designate_target)

/datum/behavior_module/combat/register_stance_signals(stance)
	switch(stance)
		if(AI_ATTACKING)
			START_PROCESSING(SSprocessing, src)
			RegisterSignal(source_holder.parent, COMSIG_STATE_MAINTAINED_DISTANCE, .proc/attempt_attack_target)
			SEND_SIGNAL(source_holder.parent, COMSIG_SET_AI_MOVE_TARGET)

/datum/behavior_module/combat/unregister_stance_signals(stance)
	switch(stance)
		if(AI_ATTACKING)
			STOP_PROCESSING(SSprocessing, src)
			UnregisterSignal(source_holder.parent, COMSIG_STATE_MAINTAINED_DISTANCE)

//Search behavior module picked up on something, let's see if we wanna kill it
/datum/behavior_module/combat/proc/designate_target(datum/source, list/potential_targets)
	var/is_type
	for(var/thing in potential_targets)
		is_type = FALSE
		for(var/type in typepaths_to_fight)
			if(istype(thing, type))
				is_type = TRUE
				break //If it matches one of the types it's good to go
			continue

		if(!is_type)
			potential_targets -= thing

//Attempt to attack the target, if it doesn't exist see if we wanna attac nearby things
//Because this is called when the source maintained distance with the target, we'll just have to figure out if we want a melee or ranged attack
/datum/behavior_module/combat/proc/attempt_attack_target(datum/source, atom/target)
