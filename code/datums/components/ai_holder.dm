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

/datum/component/ai_holder/Initialize(behavior_type)
	. = ..()
	if(!ismob(parent)) //Requires a mob as the element action states needed to be apply depend on several mob defines like cached_multiplicative_slowdown or action_busy
		stack_trace("An AI controller was initialized on a parent that isn't compatible with the ai component. Parent type: [parent.type]")
		return COMPONENT_INCOMPATIBLE
	if(isnull(behavior_type))
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

	//ai_behavior = new behavior_type(src, parent)
	//ai_behavior.current_node = node_to_spawn_at
	//ai_behavior.late_initialize() //We gotta give the ai behavior things like what node to spawn at before it wants to start an action
	RegisterSignal(parent, list(COMSIG_PARENT_PREQDELETED, COMSIG_MOB_DEATH), .proc/clean_up)
	RegisterSignal(parent, COMSIG_AI_ATTEMPT_CHANGE_STANCE, .proc/attempt_change_stance)
	apply_behavior_template(behavior_type)
	cur_stance = list(AI_ROAMING = 1)
	register_signals_for(AI_ROAMING) //Let's get moving

//Attempts to override the current stance
/datum/component/ai_holder/proc/attempt_change_stance(datum/source, new_stance, priority)
/*
	to_chat(world, "begin of change stance attempt")
	to_chat(world, "new stance [new_stance]")
	to_chat(world, "priority level given [priority]")
	to_chat(world, "current stance [cur_stance[1]]")
	to_chat(world, "current stance priority [cur_stance[cur_stance[1]]]")
	to_chat(world, "end of change stance attempt")
*/
	if(cur_stance[1] == new_stance) //Already the stance, no need to refresh it
		return
	if(priority <= cur_stance[cur_stance[1]]) //Gotta have a higher priority to override it
		return
	unregister_signals_for(cur_stance)
	parent.RemoveElement(/datum/element/pathfinder)
	cur_stance = list(new_stance)
	cur_stance[new_stance] = priority
	register_signals_for(cur_stance)

//Initializes behavior modules to ultilize and giving them vars for further finetuning
/datum/component/ai_holder/proc/apply_behavior_template(list/behaviors)
	for(var/module_path in behaviors)
		var/datum/behavior_module/module = new module_path
		module.source_holder = src
		behavior_modules += module
		module.apply_parameters(behaviors[module_path])
		module.initial_signal_registration()

//Removes registered signals and action states, useful for scenarios like when the parent is destroyed or a client is taking over
/datum/component/ai_holder/proc/clean_up()
	STOP_PROCESSING(SSprocessing, ai_behavior)
	for(var/datum/behavior in behavior_modules)
		unregister_signals_for(cur_stance)
		STOP_PROCESSING(SSprocessing, behavior)
		qdel(behavior)
	//ai_behavior.unregister_action_signals(ai_behavior.cur_action)
	//parent.RemoveElement(/datum/element/pathfinder)

//Tell behavior modules to register for signals related to this stance
/datum/component/ai_holder/proc/register_signals_for(stance)
	for(var/datum/behavior_module/behavior in behavior_modules)
		behavior.register_stance_signals(stance)

//Tell behavior modules to unregister signals related to this stance
/datum/component/ai_holder/proc/unregister_signals_for(stance)
	for(var/datum/behavior_module/behavior in behavior_modules)
		behavior.unregister_stance_signals(stance)

/datum/component/ai_holder/Destroy()
	clean_up()
	return ..()
