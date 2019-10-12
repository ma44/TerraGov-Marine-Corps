//Basic datum AI for a xeno; ability to use acid on obstacles if valid as well as attack obstacles
/datum/component/ai_behavior/xeno
	var/last_health //For purposes of sensing overall danger at this node
	var/ability_tick_threshold = 0 //Want to do something every X Process()? here ya go
	var/can_construct = FALSE //If this xeno can construct stuff
	faction = XENOMORPH //Used for construction markers

/datum/component/ai_behavior/xeno/Init()
	..()
	var/mob/living/carbon/xenomorph/parent2 = parent
	parent2.xeno_caste.caste_flags += CASTE_INNATE_HEALING
	parent2.xeno_caste.caste_flags += CASTE_QUICK_HEAL_STANDING
	parent2.xeno_caste.caste_flags += CASTE_CAN_HEAL_WIHOUT_QUEEN
	last_health = parent2.health
	parent2.afk_timer_id = addtimer(CALLBACK(GLOBAL_PROC, /proc/afk_message, src), 999 HOURS, TIMER_STOPPABLE)
	if(SSai.randomized_xeno_tiers) //Equal chances of being young, mature, elder or ancient
		parent2.upgrade_xeno(pick(list(0, XENO_UPGRADE_ONE, XENO_UPGRADE_TWO, XENO_UPGRADE_THREE)))
	/*
	if(can_construct)
		action_state.OnComplete() //Removes random_move
		action_state = new/datum/action_state/construction(src)
	else
	*/
	parent2.a_intent = INTENT_HARM //Kill em all
	action_state = new/datum/action_state/random_move/scout(src)

/datum/component/ai_behavior/xeno/proc/AttemptGetTarget()
	for(var/mob/living/carbon/human/human in cheap_get_humans_near(parent, 10))
		if(human.stat != DEAD)
			return human
	return FALSE

/datum/component/ai_behavior/xeno/remove_everything() //Removes parent from processing AI and own component

	SSai.aidatums -= src
	SSai_movement.RemoveFromProcess(src)
	qdel(src)

//Below proc happens every 1/2 second
/datum/component/ai_behavior/xeno/Process()
	. = ..()
	if(!.) //Deleted due to no parent mob or other errors
		return FALSE

	var/mob/living/carbon/xenomorph/parent2 = parent

	//If we aren't on a stack of fire and not already resting, we'll go and try to put out the fire, very effective fire!
	if(parent2.fire_stacks >= 3 && parent2.canmove && !locate(/obj/effect/particle_effect/fire) in get_turf(parent2) && prob(100 - ((parent2.health / parent2.maxHealth) * 100)))
		parent2.resist_fire()

	if(parent2.resting)
		parent2.set_resting(FALSE) //ARISE MY CHILDREN

	if(parent2.health < last_health)
		if(get_dist(parent2, current_node) > get_dist(parent2, destination_node)) //See what's closer
			destination_node.datumnode.increment_weight(DANGER_SCALE, last_health - parent2.health)
			current_node.color = "#ff0000" //Red, we got hurt
		else
			current_node.datumnode.increment_weight(DANGER_SCALE, last_health - parent2.health)
			current_node.color = "#ff0000" //Red, we got hurt
		//If we're retreating in the first place we ain't gonna try and kill the enemy unless we're suicidal
		if(!SSai.is_pacifist && !SSai.is_suicidal && (parent2.health < (parent2.maxHealth * SSai.retreat_health_threshold)))
			qdel(action_state)
			action_completed(ENEMY_CONTACT) //Look for enemies, we got hurt

	last_health = parent2.health
	HandleAbility()

/datum/component/ai_behavior/xeno/proc/attack_target(atom/target) //Attempts a attack on a target with cooldown restrictions
	var/mob/living/carbon/xenomorph/parent2 = parent

	if(parent2.next_move < world.time) //If we can attack again or not

		if(istype(target, /obj/structure) || istype(target, /obj/machinery)) //We don't miss these targets from prob_melee_slash_multiplier
			target.attack_alien(parent2)
			parent2.next_move = world.time + parent2.xeno_caste.attack_delay
			return

		if(istype(target, /mob/living/carbon) && parent2.canmove)
			var/mob/living/carbon/target2 = target
			if(target2.stat) //Always hit laying down targets
				target2.attack_alien(parent2)
				parent2.next_move = world.time + parent2.xeno_caste.attack_delay
			else //The less the target moves, the easier to hit. Every second of not moving increases chance to hit by 75%, 30% chance to hit base
				if(prob(((world.time - target2.last_move_intent) * 75) + 40) * SSai.prob_melee_slash_multiplier)
					target.attack_alien(parent2)
					parent2.next_move = world.time + parent2.xeno_caste.attack_delay
					return

/datum/component/ai_behavior/xeno/action_completed(reason) //Action state was completed, let's replace it with something else
	var/mob/living/carbon/xenomorph/parent2 = parent
	switch(reason)
		if(FINISHED_MOVE)
			//If we prioritize nodes with enemies, let's go find some to kill
			if(SSai.prioritize_nodes_with_enemies && GLOB.nodes_with_enemies.len && !(current_node in GLOB.nodes_with_enemies) && (!SSai.is_suicidal && (parent2.health < (parent2.maxHealth * SSai.retreat_health_threshold)))) //There's no enemies at this node but if they're somewhere else we moving to that
				action_state = new/datum/action_state/move_to_node(src)
				var/datum/action_state/move_to_node/the_state = action_state
				the_state.destination_node = pick(shuffle(GLOB.nodes_with_enemies))
			else
				//No prioritized node, let's look for humans nearby to kill
				var/list/humans_nearby = cheap_get_humans_near(parent2, 10)
				if(!humans_nearby.len)
					//No humans nearby, if we can construct let's look for construction to do
					var/list/stuff_to_make = current_node.datumnode.get_marker_faction(faction)
					if(can_construct && length(stuff_to_make))
						action_state = new/datum/action_state/construction(src)
					else //Nothing to construct here, let's do some scouting
						action_state = new/datum/action_state/random_move/scout(src)
				else //Enemies found kill em if not pacifist
					current_node.add_to_notable_nodes(ENEMY_PRESENCE)
					current_node.datumnode.set_weight(ENEMY_PRESENCE, humans_nearby.len)
					if(SSai.is_pacifist)
						action_state = new/datum/action_state/random_move/scout(src)
					else
						action_state = new/datum/action_state/hunt_and_destroy(src)

		if(ENEMY_CONTACT)
			action_state = new/datum/action_state/hunt_and_destroy(src)

		if(NO_ENEMIES_FOUND)
			current_node.remove_from_notable_nodes(ENEMY_PRESENCE)
			action_state = new/datum/action_state/random_move/scout(src)

		if(DISENGAGE) //We were on hunt and destroy but now low health, let's get moving and avoid enemies
			action_state = new/datum/action_state/random_move/scout(src)

	action_state.Process()

/datum/component/ai_behavior/xeno/proc/HandleAbility()
	var/mob/living/carbon/xenomorph/parent2 = parent
	ability_tick_threshold++
	if(!parent || !parent2)
		qdel(src)
		return FALSE
	if(parent2.stat || !parent2.canmove) //Crit or dead
		return FALSE
	return TRUE

/datum/component/ai_behavior/xeno/HandleObstruction()

	for(var/obj/machinery/door/airlock/door in range(1, parent))
		if(door.density && !door.welded)
			door.open()

	for(var/turf/closed/probawall in range(1, parent))
		if(!probawall.can_be_dissolved())
			return
		if(probawall.current_acid)
			return
		if(!probawall.acid_check(/obj/effect/xenomorph/acid/strong))
			var/obj/effect/xenomorph/acid/strong/newacid = new /obj/effect/xenomorph/acid/strong(get_turf(probawall), probawall)
			newacid.icon_state += "_wall"
			newacid.acid_strength = 0.1 //Very fast acid
			probawall.current_acid = newacid

	for(var/obj/machinery/machin in range(1, parent))
		attack_target(machin)
		return

	for(var/obj/structure/struct in range(1, parent))
		attack_target(struct)
		return

//Like the old one but now will do left and right movements upon being in melee range
/datum/component/ai_behavior/xeno/ProcessMove()
	if(QDELETED(src))
		return
	var/mob/living/carbon/parent2 = parent
	if(!parent2.canmove)
		return 4
	var/totalmovedelay = 0
	switch(parent2.m_intent)
		if(MOVE_INTENT_RUN)
			totalmovedelay += 2 + CONFIG_GET(number/movedelay/run_delay)
		if(MOVE_INTENT_WALK)
			totalmovedelay += 7 + CONFIG_GET(number/movedelay/walk_delay)
	totalmovedelay += parent2.movement_delay()

	var/doubledelay = FALSE //If we add on additional delay due to it being a diagonal move
	//var/turf/directiontomove = get_dir(parentmob, get_step_towards(parentmob, atomtowalkto)) //We cache the direction so we can adjust move delay on things like diagonal move alongside other things

	var/smarterdirection = action_state.GetTargetDir(TRUE)

	if(!step(parent2, smarterdirection)) //If this doesn't work, we're stuck
		HandleObstruction()
		return 2

	if(smarterdirection in GLOB.diagonals)
		doubledelay = TRUE

	if(doubledelay)
		move_delay = world.time + (totalmovedelay * SQRTWO)
		return totalmovedelay * SQRTWO
	else
		move_delay = world.time + totalmovedelay
		return totalmovedelay
