/mob/living/carbon/xenomorph/sentinel/ai
	ai_type = /datum/component/ai_behavior/xeno/sentinel

/mob/living/carbon/xenomorph/sentinel/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/sentinel
	distance_to_maintain = 5 //Far enough to be 'fair'
	var/datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/component/ai_behavior/xeno/sentinel/Init()
	..()
	var/mob/living/carbon/xenomorph/parent2 = parent
	spit.owner = parent2
	parent2.ammo = new/datum/ammo/xeno/toxin(src)

/datum/component/ai_behavior/xeno/sentinel/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(spit.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			spit.use_ability(action_state2.atomtowalkto)
