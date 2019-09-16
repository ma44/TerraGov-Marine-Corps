/mob/living/carbon/xenomorph/warrior/ai
	ai_type = /datum/component/ai_behavior/xeno/warrior

/mob/living/carbon/xenomorph/warrior/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/warrior
	var/datum/action/xeno_action/activable/fling/fling = new
	var/datum/action/xeno_action/activable/punch/punch = new

/datum/component/ai_behavior/xeno/warrior/Init()
	..()
	var/mob/living/carbon/xenomorph/warrior/parent2 = parent
	fling.owner = parent2
	punch.owner = parent2

/datum/component/ai_behavior/xeno/warrior/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/parent2 = parent

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(get_dist(parent2, action_state2.atomtowalkto) <= 1)
			if(fling.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				fling.use_ability(action_state2.atomtowalkto)

			if(punch.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				punch.use_ability(action_state2.atomtowalkto)
