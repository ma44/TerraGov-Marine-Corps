/mob/living/carbon/xenomorph/defender/ai
	ai_type = /datum/component/ai_behavior/xeno/defender

/mob/living/carbon/xenomorph/defender/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/defender
	var/datum/action/xeno_action/activable/forward_charge/charge = new
	var/datum/action/xeno_action/activable/tail_sweep/sweep = new

/datum/component/ai_behavior/xeno/defender/Init()
	..()
	var/mob/living/carbon/xenomorph/defender/parentmob2 = parent
	charge.owner = parentmob2
	sweep.owner = parentmob2
	parentmob2.set_crest_defense(TRUE)

/datum/component/ai_behavior/xeno/defender/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state

		if(get_dist(parent, action_state2.atomtowalkto) <= 1)
			if(sweep.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				sweep.use_ability()
