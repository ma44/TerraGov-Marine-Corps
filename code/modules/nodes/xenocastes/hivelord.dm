/mob/living/carbon/xenomorph/hivelord/ai
	ai_type = /datum/component/ai_behavior/xeno/hivelord

/mob/living/carbon/xenomorph/hivelord/ai/Initialize()
	. = ..()
	AddComponent(ai_type)

//Build that wall
/datum/component/ai_behavior/xeno/hivelord
	var/datum/action/xeno_action/plant_weeds/plantweeds = new
	var/datum/action/xeno_action/activable/secrete_resin/hivelord/secrete = new

/datum/component/ai_behavior/xeno/hivelord/Init()
	..()
	var/mob/living/carbon/xenomorph/hivelord/parent2 = parent
	if(SSai.init_pheromones)
		parent2.current_aura = pick(list("recovery", "warding", "frenzy"))
	plantweeds.owner = parent2
	secrete.owner = parent2

//We make magic weeds, walls and sticky resin
/datum/component/ai_behavior/xeno/hivelord/HandleAbility()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/carbon/xenomorph/hivelord/parent2 = parent

	if(ability_tick_threshold % 2 == 0)

		if(!parent2.speed_activated && (!locate(/obj/effect/alien/weeds/node) in range(0, parent2)))
			parent2.speed_activated = TRUE //Vroom vroom

		if(!locate(/obj/effect/alien/weeds/node) in range(1, parent2))
			plantweeds.action_activate()
		/*
		else

			var/got_wall = FALSE
			for(var/turf/closed/wall/resin/wall in range(1, parentmob2))
				if(wall)
					got_wall = TRUE
					break
			if(!got_wall)
				var/turf/T = get_turf(parentmob2)
				T.ChangeTurf(/turf/closed/wall/resin)
				return //We plopped a thicc wall, can't build anything else here
		*/
	var/turf/T2 = get_turf(parent2)
	if(T2.check_alien_construction(parent2))
		var/turf/T = get_turf(parent2)
		new/obj/effect/alien/resin/sticky(T)
		//parentmob2.selected_resin = /obj/effect/alien/resin/sticky
		//secrete.use_ability()
