//Behavior modules and their typepth to be initialized
#define BEHAVE_MODULE_MOVEMENT /datum/behavior_module/movement
#define BEHAVE_MODULE_PATROL /datum/behavior_module/patrol
#define BEHAVE_MODULE_SEARCH /datum/behavior_module/search
#define BEHAVE_MODULE_COMBAT /datum/behavior_module/combat
#define BEHAVE_MODULE_ACTION_TRIGGER /datum/behavior_module/action_trigger

#define PREFERRED_WEIGHTS "preferred_weights"

//AI component stances
#define AI_ROAMING "ai_is_roaming"
#define AI_ATTACKING "ai_is_attacking"

//Attack identifier types
#define ANIMAL_ATTACKS "animal_attacks"
#define HUMAN_ATTACKS "human_attacks"
#define XENO_ATTACKS "xeno_attacks"

//Signals related to specific typepaths found in a list
#define COMSIG_AI_DETECT_HUMAN "list_filter_detect_human_type"

/*
Index order for variables passed to behavior modules
BEHAVE_MODULE_MOVEMENT, distance to maintain, sidestep probability when dist maintained

BEHAVE_MODULE_PATROL, list(preferred weights)
*/

//Template for an AI to just roam around
GLOBAL_LIST_INIT(ai_roamer, list(BEHAVE_MODULE_MOVEMENT = list(1, 0),
								BEHAVE_MODULE_PATROL = list(list())
								))

/*
GLOBAL_LIST_INIT(ai_aggro, list(BEHAVE_MODULE_MOVEMENT = list(1, 25),
								BEHAVE_MODULE_PATROL = list(list()),
								BEHAVE_MODULE_SEARCH = list(list(/mob/living/carbon/human), 9, TRUE, TRUE),
								BEHAVE_MODULE_COMBAT = list(list(/mob/living/carbon/human), FALSE, HUMAN_ATTACKS)
								))
*/

GLOBAL_LIST_INIT(ai_aggro, list(BEHAVE_MODULE_MOVEMENT = list(1, 25),
								BEHAVE_MODULE_PATROL = list(list()),
								BEHAVE_MODULE_SEARCH = list(list(/mob/living/carbon/human = COMSIG_AI_DETECT_HUMAN), 9, TRUE, TRUE),
								BEHAVE_MODULE_ACTION_TRIGGER = list(list(COMSIG_AI_DETECT_HUMAN = /mob/living/carbon/human)),
								BEHAVE_MODULE_COMBAT = list(FALSE, HUMAN_ATTACKS)
								))
