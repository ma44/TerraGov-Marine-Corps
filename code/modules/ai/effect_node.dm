//The actual node; really only to hold the ai_node datum that stores all the information

/obj/effect/AINode //A effect that has a ai_node datum in it, used by AIs to pathfind over long distances as well as knowing what's happening at it
	name = "AI Node"
	icon = 'icons/effects/landmarks_static.dmi'
	icon_state = "x6" //Pure white 'X' with black borders
	var/datum/ai_node/datumnode = new/datum/ai_node() //Stores things about the AI node
	var/turf/srcturf //The turf this is on
	anchored = TRUE //No pulling those nodes yo
	alpha = 255

/obj/effect/AINode/Initialize() //Add ourselve to the global list of nodes
	. = ..()
	srcturf = loc
	datumnode.parentnode = src
	//for(var/diagonal in GLOB.diagonals)
	//	datumnode.add_construction(new/datum/construction_marker/xeno/weed_node(get_step(loc, diagonal), datumnode))
	//for(var/cardinal in GLOB.cardinals)
	//	datumnode.add_construction(new/datum/construction_marker/xeno/sticky_resin(get_step(loc, cardinal), datumnode))
	//datumnode.add_construction(new/datum/construction_marker/xeno/weed_node(loc, datumnode))
	GLOB.allnodes += src

/obj/effect/AINode/proc/MakeAdjacents()
	datumnode.adjacent_nodes = list()
	for(var/obj/effect/AINode/node in GLOB.allnodes)
		if(node && (node != src) && (get_dist(src, node) < 16) && (get_dir(src, node) in CARDINAL_DIRS))
			/*
			var/list/turf/turfs = getline(src, node)
			var/IsDense = FALSE
			for(var/turf/turf in turfs)
				if(istype(turf, /turf/closed))
					IsDense = TRUE
			if(!IsDense)
			*/
			datumnode.adjacent_nodes += node

/obj/effect/AINode/proc/add_to_notable_nodes(weight)

/obj/effect/AINode/proc/remove_from_notable_nodes(weight)

/obj/effect/AINode/debug //A debug version of the AINode; makes it visible to allow for easy var editing

/obj/effect/AINode/debug/Initialize()
	..()
	alpha = 127
	color = "#ffffff" //Color coding yo; white is 'unkonwn', green is 'safe' and red is 'danger'
