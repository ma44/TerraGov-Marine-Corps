/*
/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_controller, /datum/ai_behavior)
*/

/mob/living/carbon/human/node_pathing //A human using the basic random node traveling

/mob/living/carbon/human/node_pathing/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_holder, GLOB.ai_roamer)

/mob/living/carbon/human/killer_thing

/mob/living/carbon/human/killer_thing/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_holder, GLOB.ai_xeno_hunter)

/mob/living/carbon/xenomorph/drone/killer_thing

/mob/living/carbon/xenomorph/drone/killer_thing/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_holder, GLOB.ai_human_hunter)
