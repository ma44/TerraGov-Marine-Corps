/mob/living/carbon/xenomorph/spitter/ai

/mob/living/carbon/xenomorph/spitter/ai/Initialize()
	. = ..()
	AddComponent(/datum/component/ai_behavior, /datum/ai_mind/carbon/xeno/spitter)
	a_intent = INTENT_HARM
	//Cheat codes
	xeno_caste.caste_flags += CASTE_INNATE_HEALING
	xeno_caste.caste_flags += CASTE_QUICK_HEAL_STANDING
	xeno_caste.caste_flags += CASTE_CAN_HEAL_WIHOUT_QUEEN
