/obj/effect/proc_holder/zombie/tank
	name = "Tank"
	desc = "Gives you a moderate armor boost for a few seconds. Heals 75% of your brute and fire damage."
	action_icon = 'icons/mob/actions/actions_changeling.dmi'
	action_icon_state = "fake_death"
	cooldown_time = 7.5 MINUTES
	var/duration = 30 SECONDS
	var/armor_boost = 15
	var/heal = 0.75


/obj/effect/proc_holder/zombie/tank/proc/run_ability(mob/living/carbon/human/user)
	addtimer(CALLBACK(src, .proc/stop, user), duration)
	user.dna.species.armor += armor_boost
	user.adjustBruteLoss(-(heal * user.getBruteLoss()))
	user.adjustFireLoss(-(heal * user.getFireLoss()))
	return TRUE

/obj/effect/proc_holder/zombie/tank/proc/stop(mob/living/carbon/human/user)

	user.dna.species.armor -= armor_boost
	to_chat(user, "<span class='userdanger'>Your armor boost has ended!</span>")

/obj/effect/proc_holder/zombie/tank/fire(mob/living/carbon/user)
	if(user.incapacitated())
		return FALSE

	if(run_ability(user))
		return ..()