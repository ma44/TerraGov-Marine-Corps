/*
AI CONTROLLER COMPONENT

Really just here to exist as a way to hold the ai behavior while being an easy way of applying ai to atom/movables
The main purpose of this is to handle cleanup and setting up the initial ai behavior
*/

//The most basic of AI; can pathfind to a turf and path around objects in it's path if needed to
/datum/component/ai_holder
	var/datum/ai_behavior/ai_behavior //Calculates the action states to take and the parameters it gets; literally the brain
	var/list/behavior_modules = list() //A list of behavior modules we loop through when processing
	var/obj/effect/ai_node/current_node //The current node we're at

	//Variables related to stance and movement determination
	var/atom/move_target //Cached variable of the atom we're currently moving to VIA pathfinder element

	var/cur_stance //Current action we're doing; makes behavior modules determine what signals to intercept and such
	//Assoc list with the key being the "action"/stance, value being the priority level

/datum/component/ai_holder/Initialize(behavior_types)
	. = ..()
	if(!ismob(parent)) //Requires a mob as the element action states needed to be apply depend on several mob defines like cached_multiplicative_slowdown or action_busy
		stack_trace("An AI controller was initialized on a parent that isn't compatible with the ai component. Parent type: [parent.type]")
		return COMPONENT_INCOMPATIBLE
	if(isnull(behavior_types))
		stack_trace("An AI controller was initialized without behavior modules to add onto itself; component removed")
		return COMPONENT_INCOMPATIBLE

	for(var/obj/effect/ai_node/node in range(9))
		current_node = node
		//movable_parent.forceMove(node.loc)
		break
	if(isnull(current_node))
		stack_trace("An AI controller was being attached to a parent however it was unable to locate a node nearby to attach itself to; component removed.")
		message_admins("Notice: An AI controller was initialized but wasn't close enough to a node; if you were spawning AI component users, then do it closer to a node.")
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_AI_ATTEMPT_CHANGE_STANCE, .proc/attempt_change_stance)
	RegisterSignal(parent, COMSIG_MADE_IT_TO_NODE, .proc/change_current_node)
	apply_behavior_template(behavior_types)
	cur_stance = list(AI_ROAMING = 1)
	SEND_SIGNAL(parent, COMSIG_AI_CHANGE_STANCE, AI_ROAMING)
	var/mob/mob_parent = parent
	mob_parent.a_intent = INTENT_HARM //TODO: behavior module that changes intents of a thing based on signals

//Changes the current ai node
/datum/component/ai_holder/proc/change_current_node(datum/source, new_node)
	current_node = new_node

//Attempts to override the current stance
/datum/component/ai_holder/proc/attempt_change_stance(datum/source, new_stance, priority, forced_change = FALSE)
	if(cur_stance[1] == new_stance) //Already the stance, no need to refresh it
		return
	if((priority <= cur_stance[cur_stance[1]]) && !forced_change) //Gotta have a higher priority or specific parameter to override it
		return
	//parent.RemoveElement(/datum/element/pathfinder)
	SEND_SIGNAL(parent, COMSIG_AI_CHANGE_STANCE, new_stance, cur_stance[1])
	cur_stance = list(new_stance)
	cur_stance[new_stance] = priority //Thanks associative list

//Initializes behavior modules to ultilize and giving them vars for further finetuning
/datum/component/ai_holder/proc/apply_behavior_template(list/behavior_types)
	var/list/copied_behaviors = behavior_types.Copy() //_AddElement modifies the list, we don't want to have a ref to the list we were provided (like GLOBs)
	for(var/I = 1 to behavior_types.len)
		copied_behaviors[I] = behavior_types[I].Copy()
	for(var/parameters in copied_behaviors)
		parent._AddElement(parameters)
