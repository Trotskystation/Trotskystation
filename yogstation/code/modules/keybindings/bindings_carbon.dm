/mob/living/carbon/key_down(datum/keyinfo/I, client/user)
	switch(I.action)
		if(ACTION_TOGGLETHROW)
			toggle_throw_mode()
			return
		if(ACTION_INTENTHELP)
			a_intent_change(INTENT_HELP)
			return
		if(ACTION_INTENTDISARM)
			a_intent_change(INTENT_DISARM)
			return
		if(ACTION_INTENTGRAB)
			a_intent_change(INTENT_GRAB)
			return
		if(ACTION_INTENTHARM)
			a_intent_change(INTENT_HARM)
			return

	return ..()
