//A file containing helpers for nodes and direction related things

GLOBAL_LIST_EMPTY(allnodes)
GLOBAL_LIST_EMPTY(nodes_with_enemies)
GLOBAL_LIST_EMPTY(nodes_with_construction)

//Converts input direction to a list of either two same directions if the input is cardinal
//Otherwise will return the two directions that make up the diagonal
/proc/DiagonalToCardinal(direct)
	if(direct in GLOB.cardinals)
		return list(direct, direct)
	return list(NSCOMPONENT(direct), EWCOMPONENT(direct))

	switch(direct)
		if(NORTHEAST)
			return shuffle(list(NORTH, EAST))
		if(NORTHWEST)
			return shuffle(list(NORTH, WEST))
		if(SOUTHEAST)
			return shuffle(list(SOUTH, EAST))
		if(SOUTHWEST)
			return shuffle(list(SOUTH, WEST))

//Returns a node that is in the direction of this node; must be in the src's adjacent node list
/obj/effect/AINode/proc/GetNodeInDirInAdj(dir)

	if(!datumnode.adjacent_nodes || !datumnode.adjacent_nodes.len)
		return null

	for(var/obj/effect/AINode/node in datumnode.adjacent_nodes)
		if(get_dir(src, node) == dir)
			return node
	return null

//The equivalent of get_step_towards but now for nodes; will NOT intelligently pathfind based on node weights or anything else
//Returns nothing if a suitable node in a direction isn't found, otherwise returns a node
/proc/get_node_towards(obj/effect/AINode/startnode, obj/effect/AINode/destination)
	if(startnode == destination)
		return startnode
	var/list/possibledir = DiagonalToCardinal(get_dir(startnode, destination))
	var/list/possiblenodes = list(startnode.GetNodeInDirInAdj(possibledir[1]), startnode.GetNodeInDirInAdj(possibledir[2]))
	if(possiblenodes[1]) //See if the first index will give us a node
		return possiblenodes[1]
	if(possiblenodes[2]) //Try the other index; return FALSE if neither direction produces a node
		return possiblenodes[2]
	return null

//Returns a list of humans via get_dist and same z level method, very cheap compared to range()
/proc/cheap_get_humans_near(source, distance)
	var/list/listofhuman = list() //All humans in range
	for(var/human in GLOB.alive_human_list)
		if(get_dist(source, human) <= distance)
			listofhuman += human
	return listofhuman

/proc/GetRandomNode() //Gets a new random destination, probably doesn't need this
	return pick(GLOB.allnodes)

/proc/LeftAndRightOfDir(direction) //Returns the left and right dir of the input dir, used for AI stutter step and cade movement
	var/list/somedirs = list()
	switch(direction)
		if(NORTH)
			somedirs = list(WEST, EAST)
		if(SOUTH)
			somedirs = list(EAST, WEST)
		if(WEST)
			somedirs = list(SOUTH, NORTH)
		if(EAST)
			somedirs = list(NORTH, SOUTH)
		if(NORTHEAST)
			somedirs = list(NORTH, EAST)
		if(NORTHWEST)
			somedirs = list(NORTH, WEST)
		if(SOUTHEAST)
			somedirs = list(SOUTH, EAST)
		if(SOUTHWEST)
			somedirs = list(SOUTH, WEST)

	return(somedirs)
