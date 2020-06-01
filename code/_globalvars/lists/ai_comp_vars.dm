//Behavior modules and their typepth to be initialized
#define BEHAVE_MODULE_MOVEMENT /datum/behavior_module/movement
#define BEHAVE_MODULE_PATROL /datum/behavior_module/patrol
#define BEHAVE_MODULE_SEARCH /datum/behavior_module/search
#define BEHAVE_MODULE_COMBAT /datum/behavior_module/combat

#define PREFERRED_WEIGHTS "preferred_weights"

//AI component stances
#define AI_ROAMING "ai_is_roaming"
#define AI_ATTACKING "ai_is_attacking"

/*
Index order for variables passed to behavior modules
BEHAVE_MODULE_MOVEMENT, distance to maintain, sidestep probability when dist maintained

BEHAVE_MODULE_PATROL, list(preferred weights)
*/

//Template for an AI to just roam around
GLOBAL_LIST_INIT(ai_roamer, list(BEHAVE_MODULE_MOVEMENT = list(1, 0), BEHAVE_MODULE_PATROL = list(list())))
