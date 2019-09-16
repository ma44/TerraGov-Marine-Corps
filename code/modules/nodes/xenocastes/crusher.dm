/mob/living/carbon/xenomorph/crusher/ai
	ai_type = /datum/component/ai_behavior/xeno/crusher

/mob/living/carbon/xenomorph/crusher/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

//Melee crusher electric boogaloo; the bane of ai testers
/datum/component/ai_behavior/xeno/crusher
	distance_to_maintain = 0 //We want to be as close to them as possible, mainly for stomping
	var/datum/action/xeno_action/activable/stomp/stomp = new
	var/datum/action/xeno_action/activable/cresttoss/toss = new

/datum/component/ai_behavior/xeno/crusher/Init()
	..()
	var/mob/living/carbon/xenomorph/crusher/parentmob2 = parent
	parentmob2.is_charging = TRUE
	parentmob2.a_intent = INTENT_DISARM //Disarm those enemies, trust me it works
	stomp.owner = parentmob2
	toss.owner = parentmob2

/datum/component/ai_behavior/xeno/crusher/HandleAbility()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/crusher/parent2 = parent
	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state
		//Crusher is close to the target, that target is DEAD
		if((get_dist(parent2, action_state2.atomtowalkto) <= 1) && istype(action_state2.atomtowalkto, /mob/living/carbon))

			if(stomp.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				stomp.use_ability(action_state2.atomtowalkto)

			if(toss.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
				toss.use_ability(action_state2.atomtowalkto)
