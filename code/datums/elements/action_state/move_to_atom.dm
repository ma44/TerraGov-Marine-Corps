//Moves to an atom, sends signals if a distance is maintained

/datum/element/action_state/move_to_atom
	var/list/distances_to_maintain = list() //Distance we want to maintain from atom and send signals once distance has been maintained
	var/list/atoms_to_walk_to = list() //All the targets some mobs gotta move to
	var/list/stutter_step_prob = list() //The prob() chance of a mob going left or right when distance is maintained with the target
	var/list/safe_turfs = list() //Turfs not in a path of a moving bullet's trajectory; move to these turfs closer or away from the target depending on parameters

/datum/element/action_state/move_to_atom/process()
	for(var/mob in distances_to_maintain)
		var/mob/mob_to_process = mob
		if(!mob_to_process.canmove || mob_to_process.stat == DEAD)
			continue

		//Okay it can actually physically move, but has it moved too recently?
		if(world.time <= mob_to_process.last_move_time + mob_to_process.cached_multiplicative_slowdown || mob_to_process.action_busy)
			continue

		//Neo dodge time; if there's a bullet nearby in currently moving projectiles, get a list of turfs that would be intercepting it's path and not move into turfs if possible
		for(var/proj in GLOB.projectiles_in_motion)
			var/obj/projectile/bullet = proj
			to_chat(world, "Bullet to mob to process loc's direction: [get_dir(bullet, mob_to_process)]")
			to_chat(world, "Bullet dir: [bullet.dir]")
			to_chat(world, "Bullet angle dir: [bullet.dir_angle]")
			to_chat(world, "Bullet angle to dir: [angle_to_dir(bullet.dir_angle)]")
			//to_chat(world, "Bullet dir angle to dir: [angle_to_dir(bullet.dir_angle)]")
			if((get_dist(mob_to_process, bullet) <= 7) && (mob_to_process.z == bullet.z) && (get_dir(bullet, mob_to_process) == angle_to_dir(bullet.dir_angle)))
				for(var/turf/turf in shuffle(range(1, mob_to_process)))
					if(get_dir(bullet, turf) == angle_to_dir(bullet.dir_angle) || !turf.CanPass(mob_to_process, turf)) //The bullet is currently traveling to this turf; don't go to it
						safe_turfs -= turf
						continue
					safe_turfs |= turf

		//Now lets find a turf nearby that we can walk to without getting stuck and preferably closer to the ideal distance to target
		if(length(safe_turfs))
			var/turf/best_turf
			var/dist_to_atom = get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) //Cached
			for(var/turf in safe_turfs)
				var/turf/t = turf
				if((dist_to_atom - (get_dist(t, atoms_to_walk_to[mob_to_process]))) == ((dist_to_atom - (distances_to_maintain[mob_to_process]))))
					best_turf = t

			//If there's a best turf it means we can dodge the path of a bullet while also moving towards the target
			//Otherwise if there isn't let's just move in a direction away from the target while avoiding the bullet
			if(best_turf)
				step(mob_to_process, get_dir(mob_to_process, best_turf))
				safe_turfs = list()
				mob_to_process.last_move_time = world.time
				to_chat(world, "moved to best turf")
				continue

			safe_turfs = list()
			to_chat(world, "no best turf found")

		if(get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) == distances_to_maintain[mob_to_process])
			SEND_SIGNAL(mob_to_process, COMSIG_STATE_MAINTAINED_DISTANCE)
			if(!(get_dir(mob_to_process, atoms_to_walk_to[mob_to_process]))) //We're right on top, move out of it
				if(!step(mob_to_process, pick(CARDINAL_ALL_DIRS)))
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			if(prob(stutter_step_prob[mob_to_process]))
				if(!step(mob_to_process, pick(LeftAndRightOfDir(get_dir(mob_to_process, atoms_to_walk_to[mob_to_process]), diagonal_check = TRUE)))) //Couldn't move, something in the way
					SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			continue

		if(get_dist(mob_to_process, atoms_to_walk_to[mob_to_process]) < distances_to_maintain[mob_to_process]) //We're too close, back it up
			if(!step(mob_to_process, get_dir(mob, get_step_away(mob_to_process, atoms_to_walk_to[mob_to_process], distances_to_maintain[mob_to_process]))))
				SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
			mob_to_process.last_move_time = world.time
			continue
		if(!step(mob_to_process, get_dir(mob_to_process, get_step_to(mob_to_process, atoms_to_walk_to[mob_to_process], distances_to_maintain[mob_to_process])))) //Couldn't move, something in the way
			SEND_SIGNAL(mob_to_process, COMSIG_OBSTRUCTED_MOVE)
		mob_to_process.last_move_time = world.time

//mob: the mob that's getting the action state
//atom_to_walk_to: target to move to
//distance to maintain: mob will try to be at this distance away from the atom to walk to
//stutter_step: a prob() chance to go left or right of the mob's direction towards the target when distance has been maintained
/datum/element/action_state/move_to_atom/Attach(mob/mob, atom/atom_to_walk_to, distance_to_maintain = 0, stutter_step = 0)
	. = ..()
	if(QDELETED(mob))
		return ELEMENT_INCOMPATIBLE
	if(!ismob(mob))
		return ELEMENT_INCOMPATIBLE
	if(!atom_to_walk_to)
		return ELEMENT_INCOMPATIBLE
	distances_to_maintain[mob] = distance_to_maintain
	atoms_to_walk_to[mob] = atom_to_walk_to
	stutter_step_prob[mob] = stutter_step

/datum/element/action_state/move_to_atom/Detach(mob/mob)
	distances_to_maintain.Remove(mob)
	atoms_to_walk_to.Remove(mob)
	stutter_step_prob.Remove(mob)
	return ..()
