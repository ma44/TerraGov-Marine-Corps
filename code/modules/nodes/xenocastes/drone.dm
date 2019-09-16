/mob/living/carbon/xenomorph/drone/ai
	ai_type = /datum/component/ai_behavior/xeno/drone

/mob/living/carbon/xenomorph/drone/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

//An AI datum for drones; it makes weeds and pheromones
/datum/component/ai_behavior/xeno/drone
	var/datum/action/xeno_action/plant_weeds/plantweeds = new

/datum/component/ai_behavior/xeno/drone/Init()
	..()
	var/mob/living/carbon/xenomorph/drone/parent2 = parent
	if(SSai.init_pheromones)
		parent2.current_aura = pick(list("recovery", "warding", "frenzy"))
	plantweeds.owner = parent2

//We make magic weeds
/datum/component/ai_behavior/xeno/drone/HandleAbility()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/xenomorph/drone/parent2 = parent
	if(ability_tick_threshold % 2 == 0)
		for(var/obj/effect/alien/weeds/node/node in range(1, parent2))
			if(node)
				return FALSE
		plantweeds.action_activate()
