//Behavior modules and their typepth to be initialized
#define BEHAVE_MODULE_MOVEMENT /datum/element/behavior_module/movement
#define BEHAVE_MODULE_PATROL /datum/element/behavior_module/patrol
#define BEHAVE_MODULE_SEARCH /datum/element/behavior_module/search
#define BEHAVE_MODULE_COMBAT /datum/element/behavior_module/combat
#define BEHAVE_MODULE_ACTION_TRIGGER /datum/element/behavior_module/action_trigger

#define PREFERRED_WEIGHTS "preferred_weights"

//Stances for determining signals to be ultilized for AI
#define AI_ROAMING "ai_is_roaming"
#define AI_ATTACKING "ai_is_attacking"

/*
Index order for variables passed to behavior modules

BEHAVE_MODULE_MOVEMENT,	distance to maintain in tiles,
						sidestep probability when dist maintained

BEHAVE_MODULE_PATROL, list(preferred weights defines),
					  list(multipliers/dividers for the preferred weights)

BEHAVE_MODULE_SEARCH,	search_distance radius in tiles,
						foreach GLOB list TRUE/FALSE,
						sigtype = typepaths_to_find

BEHAVE_MODULE_ACTION_TRIGGER, signal to send = typepath to look for

BEHAVE_MODULE_COMBAT,	what signal types make the AI decide to attack (based on param),
						if we allow designating new targets when we already have a target

*/

//Template for an AI to just roam around
GLOBAL_LIST_INIT(ai_roamer, list(
								list(BEHAVE_MODULE_MOVEMENT, 1, 0),
								list(BEHAVE_MODULE_PATROL, list(NODE_LAST_VISITED = 1))
								))

GLOBAL_LIST_INIT(ai_human_hunter, list(
								list(BEHAVE_MODULE_MOVEMENT, 1, 25),
								list(BEHAVE_MODULE_PATROL, list(NODE_LAST_VISITED = 1)),
								//list(BEHAVE_MODULE_ACTION_TRIGGER, list(/mob/living/carbon/human = COMSIG_SEARCH_DETECTED_SOMETHING)),
								list(BEHAVE_MODULE_COMBAT, list(COMSIG_SEARCH_DETECTED_SOMETHING), TRUE),
								//list(BEHAVE_MODULE_SEARCH, 9, TRUE, list(list(/mob/living/carbon/human) = COMSIG_SEARCH_DETECTED_SOMETHING))
								list(BEHAVE_MODULE_SEARCH, 9, TRUE, list(COMSIG_SEARCH_DETECTED_SOMETHING = list(/mob/living/carbon/human)))
								))

GLOBAL_LIST_INIT(ai_xeno_hunter, list(
								list(BEHAVE_MODULE_MOVEMENT, 1, 25),
								list(BEHAVE_MODULE_PATROL, list(NODE_LAST_VISITED = 1)),
								//list(BEHAVE_MODULE_ACTION_TRIGGER, list(/mob/living/carbon/xenomorph = COMSIG_SEARCH_DETECTED_SOMETHING)),
								list(BEHAVE_MODULE_COMBAT, list(COMSIG_SEARCH_DETECTED_SOMETHING), TRUE),
								list(BEHAVE_MODULE_SEARCH, 9, TRUE, list(COMSIG_SEARCH_DETECTED_SOMETHING = list(/mob/living/carbon/xenomorph)))
								))
