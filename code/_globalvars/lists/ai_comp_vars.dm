//Behavior modules and their typepth to be initialized
#define BEHAVE_MODULE_MOVEMENT /datum/element/behavior_module/movement
#define BEHAVE_MODULE_PATROL /datum/element/behavior_module/patrol
#define BEHAVE_MODULE_SEARCH /datum/element/behavior_module/search
#define BEHAVE_MODULE_COMBAT /datum/element/behavior_module/combat
#define BEHAVE_MODULE_ACTION_TRIGGER /datum/element/behavior_module/action_trigger

#define PREFERRED_WEIGHTS "preferred_weights"

//AI component stances
#define AI_ROAMING "ai_is_roaming"
#define AI_ATTACKING "ai_is_attacking"

//Signals related to specific typepaths found in a list
#define COMSIG_AI_DETECT_HUMAN "list_filter_detect_human_type"
#define COMSIG_AI_DETECT_XENO "list_filter_detect_xeno_type"

#define NODE_LAST_VISITED "last_visit_scale"

/*
Index order for variables passed to behavior modules

BEHAVE_MODULE_MOVEMENT,	distance to maintain in tiles,
						sidestep probability when dist maintained

BEHAVE_MODULE_PATROL, list(preferred weights defines),
					  list(multipliers/dividers for the preferred weights)

BEHAVE_MODULE_SEARCH, 	list(typepaths_to_find),
						search_distance radius in tiles,
						foreach GLOB list TRUE/FALSE,
						requires thing that satisfies typepath check to be alive TRUE/FALSE

BEHAVE_MODULE_ACTION_TRIGGER, signal to send = typepath to look for

BEHAVE_MODULE_COMBAT,	what signal types make the AI decide to attack (based on param)

*/

//Template for an AI to just roam around
GLOBAL_LIST_INIT(ai_roamer, list(BEHAVE_MODULE_MOVEMENT = list(1, 0),
								BEHAVE_MODULE_PATROL = list(), //list(NODE_LAST_VISITED = 1))
								))

/*
GLOBAL_LIST_INIT(ai_aggro, list(BEHAVE_MODULE_MOVEMENT = list(1, 25),
								BEHAVE_MODULE_PATROL = list(list()),
								BEHAVE_MODULE_SEARCH = list(list(/mob/living/carbon/human), 9, TRUE, TRUE),
								BEHAVE_MODULE_COMBAT = list(list(/mob/living/carbon/human), FALSE, HUMAN_ATTACKS)
								))
*/

GLOBAL_LIST_INIT(ai_human_hunter, list(BEHAVE_MODULE_MOVEMENT = list(1, 25),
								BEHAVE_MODULE_SEARCH = list(list(/mob/living/carbon/human = COMSIG_AI_DETECT_HUMAN), 9, TRUE, TRUE),
								BEHAVE_MODULE_PATROL = list(), //list(NODE_LAST_VISITED = 1)),
								BEHAVE_MODULE_ACTION_TRIGGER = list(list(/mob/living/carbon/human = COMSIG_AI_DETECT_XENO)),
								BEHAVE_MODULE_COMBAT = list(list(COMSIG_AI_DETECT_HUMAN))
								))

GLOBAL_LIST_INIT(ai_xeno_hunter, list(BEHAVE_MODULE_MOVEMENT = list(1, 25),
								BEHAVE_MODULE_SEARCH = list(list(/mob/living/carbon/xenomorph = COMSIG_AI_DETECT_XENO), 9, TRUE, TRUE),
								BEHAVE_MODULE_PATROL = list(), //list(NODE_LAST_VISITED = 1)),
								BEHAVE_MODULE_ACTION_TRIGGER = list(list(/mob/living/carbon/xenomorph = COMSIG_AI_DETECT_XENO)),
								BEHAVE_MODULE_COMBAT = list(list(COMSIG_AI_DETECT_XENO))
								))
