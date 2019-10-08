//Defines for nodes, ai_behaviors, action_states etc.
#define ENEMY_PRESENCE 1
#define DANGER_SCALE 2
#define FINISHED_MOVE "finished moving to node"
#define ENEMY_CONTACT "enemy contact"
#define NO_ENEMIES_FOUND "no enemies found"
#define DISENGAGE "retreating"
#define CONSTRUCTION_DONE "construction finished"

//Generic seperation of xeno and marines if there ever will be ai humans/marines

#define XENOMORPH "xenomorph"
#define MARINE "marine"
#define NOTHING "nothing" //Someone would probably look at this and think 'why isn't this null?'

//Construction type, determines what gotta be built

#define RESIN_WALL /turf/closed/wall/resin
#define RESIN_DOOR /obj/structure/mineral_door/resin
#define STICKY_RESIN /obj/effect/alien/resin/sticky
#define WEED_NODE /obj/effect/alien/weeds/node
