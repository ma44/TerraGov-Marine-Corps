/mob/living/carbon/xenomorph/queen/ai
	ai_type = /datum/component/ai_behavior/xeno/queen

/mob/living/carbon/xenomorph/queen/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

/datum/component/ai_behavior/xeno/queen
	var/datum/action/xeno_action/activable/screech/screech = new
	var/datum/action/xeno_action/plant_weeds/plantweeds = new
	var/datum/action/xeno_action/activable/xeno_spit/spit = new

/datum/component/ai_behavior/xeno/queen/Init()
	..()
	var/mob/living/carbon/xenomorph/parent2 = parent
	screech.owner = parent2
	plantweeds.owner = parent2
	spit.owner = parent2
	parent2.ammo = new/datum/ammo/xeno/acid/heavy(src)
	if(SSai.init_pheromones)
		parent2.current_aura = pick(list("recovery", "warding", "frenzy"))

/datum/component/ai_behavior/xeno/queen/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/parent2 = parent

	if(ability_tick_threshold % 2 == 0)
		for(var/obj/effect/alien/weeds/node/node in range(1, parent))
			if(node)
				return FALSE
		plantweeds.action_activate()

	if(istype(action_state, /datum/action_state/hunt_and_destroy))
		var/datum/action_state/hunt_and_destroy/action_state2 = action_state
		if(get_dist(parent2, action_state2.atomtowalkto) < 3 && screech.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			screech.use_ability()

		if(spit.can_use_ability(action_state2.atomtowalkto, FALSE, XACT_IGNORE_SELECTED_ABILITY))
			spit.use_ability(action_state2.atomtowalkto)

