/mob/living/carbon/xenomorph/praetorian/ai
	ai_type = /datum/component/ai_behavior/xeno/praetorian

/mob/living/carbon/xenomorph/praetorian/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/praetorian
	var/datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/component/ai_behavior/xeno/praetorian/Init()
	..()
	var/mob/living/carbon/xenomorph/parent2 = parent
	spit.owner = parent2
	parent2.ammo = new/datum/ammo/xeno/acid/heavy(src)
	if(SSai.init_pheromones)
		parent2.current_aura = pick(list("recovery", "warding", "frenzy"))

/datum/component/ai_behavior/xeno/praetorian/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state
		if(spit.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			spit.use_ability(action_state2.atomtowalkto)
