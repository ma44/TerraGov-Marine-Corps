/mob/living/carbon/xenomorph/runner/ai
	ai_type = /datum/component/ai_behavior/xeno/runner

/mob/living/carbon/xenomorph/runner/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

//Uses runner abilities
/datum/component/ai_behavior/xeno/runner
	var/datum/action/xeno_action/activable/pounce/pounce = new

/datum/component/ai_behavior/xeno/runner/Init()
	..()
	var/mob/living/carbon/xenomorph/runner/parent2 = parent
	pounce.owner = parent2

/datum/component/ai_behavior/xeno/runner/HandleAbility()
	. = ..()
	if(!.)
		return FALSE
	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state
		if((get_dist(parent, action_state2.atomtowalkto) > 1) && istype(action_state2.atomtowalkto, /mob/living/carbon))
			var/mob/living/carbon/target = action_state2.atomtowalkto
			if(!target.canmove) //If it's a carbon target (xeno/human) and it can move, we'll pounce to be able to chainstun effectively
				return FALSE
		if(pounce.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			pounce.use_ability(action_state2.atomtowalkto)
s