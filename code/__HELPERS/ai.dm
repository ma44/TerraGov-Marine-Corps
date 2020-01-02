//Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/ai_node/proc/GetNodeInDirInAdj(dir)

	if(!length(datumnode.adjacent_nodes))
		return

	for(var/i in datumnode.adjacent_nodes)
		var/obj/effect/ai_node/node = i
		if(get_dir(src, node) == dir)
			return node
	return //There were adjacent nodes but none in the direction we wanted to go to

//The equivalent of get_step_towards but now for nodes; will NOT intelligently pathfind based on node weights or anything else
//Returns nothing if a suitable node in a direction isn't found, otherwise returns a node
/proc/get_node_towards(obj/effect/ai_node/startnode, obj/effect/ai_node/destination)
    if(startnode == destination)
        return startnode
    //Null value returned means no node in that direction
    return startnode.GetNodeInDirInAdj(get_dir(startnode, destination))

//Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(atom/source, distance)
	var/list/listofhuman = list() //All humans in range
	for(var/atom/human in GLOB.alive_human_list)
		if(source.z == human.z && get_dist(source, human) <= distance)
			listofhuman += human
	return listofhuman
