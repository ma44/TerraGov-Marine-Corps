/mob/living/carbon/xenomorph/spitter/ai
	ai_type = /datum/component/ai_behavior/xeno/spitter

/mob/living/carbon/xenomorph/spitter/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/spitter
	distance_to_maintain = 5 //Far enough to be 'fair'
	var/datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/component/ai_behavior/xeno/spitter/Init()
	..()
	var/mob/living/carbon/xenomorph/parent2 = parent
	spit.owner = parent2
	parent2.ammo = new/datum/ammo/xeno/acid(src)

/datum/component/ai_behavior/xeno/spitter/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(spit.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			spit.use_ability(action_state2.atomtowalkto)
