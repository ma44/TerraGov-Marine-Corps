/mob/living/carbon/xenomorph/ravager/ai
	ai_type = /datum/component/ai_behavior/xeno/ravager

/mob/living/carbon/xenomorph/ravager/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/ravager
	var/datum/action/xeno_action/activable/charge/charge = new
	var/datum/action/xeno_action/activable/ravage/ravage = new

/datum/component/ai_behavior/xeno/ravager/Init()
	..()
	var/mob/living/carbon/xenomorph/ravager/parent2 = parent
	charge.owner = parent2
	ravage.owner = parent2

/datum/component/ai_behavior/xeno/ravager/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/ravager/parent2 = parent

	//Using abilities only when at low rage is preferable as we can then click everyone else to death
	if(parent2.rage < 15 && istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(get_dist(parent, action_state2.atomtowalkto) <= 5)
			if(charge.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				charge.use_ability(action_state2.atomtowalkto)

		if(get_dist(parent, action_state2.atomtowalkto) <= 1)
			if(ravage.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				ravage.use_ability(action_state2.atomtowalkto)
