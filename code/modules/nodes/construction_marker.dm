//Designates a certain tile to have something constructed at it; mainly for ai

/datum/construction_marker
	var/turf/turf_reference
	var/construction_type //Type of thing we building
	var/datum/ai_node/source_node //The datum node we're attached to
	var/faction //What faction is suppose to build this, currently MARINE or XENOMORPH
	var/time //Time to wait for do_after

/datum/construction_marker/New(turf/turf_to_build_at, datum/ai_node/the_source_node)
	..()
	if(turf_to_build_at && the_source_node)
		turf_reference = turf_to_build_at
		source_node = the_source_node
	else
		stack_trace("Construction marker initialized without turf or source node attached.")
		Destroy(src)
		return

//When we finish putting something down
/datum/construction_marker/proc/finish_construction()
	Destroy(src)

/datum/construction_marker/Destroy()
	source_node.remove_from_construction(src)
	..()

//Xeno related constructions
/datum/construction_marker/xeno
	faction = XENOMORPH

/datum/construction_marker/xeno/resin_wall
	construction_type = RESIN_WALL
	time = 20

/datum/construction_marker/xeno/resin_door
	construction_type = RESIN_DOOR
	time = 10

/datum/construction_marker/xeno/weed_node
	construction_type = WEED_NODE
	time = 0

//Let's place nearby weed nodes
/datum/construction_marker/xeno/weed_node/finish_construction()
	for(var/diagonal in GLOB.diagonals)
		var/turf/turf = get_step(source_node.parentnode.loc, diagonal)
		if(construction_type in range(0, turf))
			continue
		if(get_dist(turf, source_node.parentnode.loc) < 10) //Don't build super far out
			source_node.add_construction(new/datum/construction_marker/xeno/weed_node(turf.loc, source_node))
	return ..()

/datum/construction_marker/xeno/sticky_resin
	construction_type = STICKY_RESIN
	time = 20
