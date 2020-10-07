/**
  *
  * CQC martial art
  *
  * Martial art that focuses on stamina damage and movement impairing effects
  * Combos:
  * [Slam][/datum/martial_art/cqc/proc/Slam]
  * [Kick][/datum/martial_art/cqc/proc/Kick]
  * [Restrain][/datum/martial_art/cqc/proc/Restrain]
  * [Pressure][/datum/martial_art/cqc/proc/Pressure]
  * [Consecutive][/datum/martial_art/cqc/proc/Consecutive]
  */

///slam combo string
#define SLAM_COMBO "GH"
///kick combo string
#define KICK_COMBO "DH"
///restrain combo string
#define RESTRAIN_COMBO "GG"
///pressure combo string
#define PRESSURE_COMBO "DDG"
///consecutive combo string
#define CONSECUTIVE_COMBO "HHHHH"

/datum/martial_art/cqc
	name = "CQC"
	id = MARTIALART_CQC
	help_verb = /mob/living/carbon/human/proc/CQC_help
	block_chance = 75
	nonlethal = TRUE //all attacks deal solely stamina damage or knock out before dealing lethal amounts of damage
	///whether the art checks for being inside the kitchen for use
	var/just_a_cook = FALSE
	///used to stop a chokehold attack from stacking
	var/chokehold_active = FALSE

/datum/martial_art/cqc/under_siege
	name = "Close Quarters Cooking"
	just_a_cook = TRUE

/datum/martial_art/cqc/can_use(mob/living/carbon/human/H) //this is used to make chef CQC only work in kitchen
	var/area/A = get_area(H)
	if(just_a_cook && !(istype(A, /area/crew_quarters/kitchen)))
		return FALSE
	return ..()

/**
  * check_streak proc
  *
  * checks a martial arts' current combo string against combo defines
  * activates a combo and returns true if it succeeds and the user can use the art
  * otherwise returns false
  */
/datum/martial_art/cqc/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(findtext(streak,SLAM_COMBO))
		streak = ""
		Slam(A,D)
		return TRUE
	if(findtext(streak,KICK_COMBO))
		streak = ""
		Kick(A,D)
		return TRUE
	if(findtext(streak,RESTRAIN_COMBO))
		streak = ""
		Restrain(A,D)
		return TRUE
	if(findtext(streak,PRESSURE_COMBO))
		streak = ""
		Pressure(A,D)
		return TRUE
	if(findtext(streak,CONSECUTIVE_COMBO))
		streak = ""
		Consecutive(A,D)
		return TRUE
	return FALSE

/**
  * CQC slam combo attack
  *
  * Basic counter that causes 15 stamina damage with a 2 second paralyze and 8 second knockdown
  */
/datum/martial_art/cqc/proc/Slam(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	if(D.mobility_flags & MOBILITY_STAND)
		D.visible_message("<span class='warning'>[A] slams [D] into the ground!</span>", \
						  	"<span class='userdanger'>[A] slams you into the ground!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1) //using hit_kick because for some stupid reason slam.ogg is delayed
		A.do_attack_animation(D, ATTACK_EFFECT_SMASH)
		D.apply_damage(15, STAMINA)
		D.Paralyze(20)
		D.Knockdown(80)
		log_combat(A, D, "slammed (CQC)")
	return TRUE

/**
  * CQC kick combo attack
  *
  * attack that deals 10 stamina and pushes the target away if they are standing
  * or 35 stamina damage with a ~8 second mute if they aren't
  */
/datum/martial_art/cqc/proc/Kick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_KICK)
	if(!D.stat && (D.mobility_flags & MOBILITY_STAND))
		D.visible_message("<span class='warning'>[A] kicks [D] back!</span>", \
							"<span class='userdanger'>[A] kicks you back!</span>")
		playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
		step(D, A.dir)
		D.apply_damage(10, STAMINA)
		log_combat(A, D, "kicked (CQC)")
		D.add_movespeed_modifier(MOVESPEED_ID_SHOVE, multiplicative_slowdown = SHOVE_SLOWDOWN_STRENGTH)
		addtimer(CALLBACK(D, /mob/living/carbon/human/proc/clear_shove_slowdown), SHOVE_SLOWDOWN_LENGTH)
	if(!(D.mobility_flags & MOBILITY_STAND) && !D.stat)
		log_combat(A, D, "prone-kicked(CQC)")
		D.visible_message("<span class='warning'>[A] firmly kicks [D] in the abdomen!</span>", \
					  		"<span class='userdanger'>[A] kicks you in the abdomen!</span>")
		playsound(get_turf(A), 'sound/weapons/genhit1.ogg', 50, 1, -1)
		D.Paralyze(5)
		D.apply_damage(35, STAMINA)
		D.silent += 4
	return TRUE

/**
  * CQC pressure attack
  *
  * Attack that disables a limb if an arm/leg is selected, randomly selects a limb if one is not selected
  * also forces them to drop anything they are holding
  */
/datum/martial_art/cqc/proc/Pressure(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	log_combat(A, D, "pressured (CQC)")
	var/list/viable_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
	var/selected_zone = A.zone_selected
	if(!viable_zones.Find(selected_zone))
		selected_zone = pick(viable_zones)
	var/hit_limb = D.get_bodypart(selected_zone)
	if(!hit_limb)
		return FALSE
	D.visible_message("<span class='warning'>[A] dislocates [D]'s [hit_limb]!</span>", \
						"<span class = 'userdanger'>[A] dislocates your [hit_limb]!</span>")
	D.drop_all_held_items()
	D.apply_damage(50, STAMINA, selected_zone) //damage dealt from 3 harm intent hits would be roughly 45
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	return TRUE

/**
  * CQC restrain attack
  *
  * attack that puts the target into a restraining position, stunning them for a short period
  * used to set up a chokehold attack
  */
/datum/martial_art/cqc/proc/Restrain(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(restraining)
		return
	if(!can_use(A))
		return FALSE
	if(!D.stat)
		log_combat(A, D, "restrained (CQC)")
		D.visible_message("<span class='warning'>[A] locks [D] into a restraining position!</span>", \
							"<span class='userdanger'>[A] locks you into a restraining position!</span>")
		D.Stun(20)
		if(!(A.pulling == D))
			D.grabbedby(A, 1)
		if(A.grab_state < GRAB_AGGRESSIVE)
			A.grab_state = GRAB_AGGRESSIVE
		restraining = TRUE
	return TRUE

/**
  * CQC consecutive attack
  *
  * Attack that causes 2 seconds paralyze and 10 seconds knockdown as well as 25 stamina damage
  */
/datum/martial_art/cqc/proc/Consecutive(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	if(D.mobility_flags & MOBILITY_STAND)
		log_combat(A, D, "consecutive CQC'd (CQC)")
		D.visible_message("<span class='warning'>[A] delivers a firm blow to [D]'s head, knocking them down!</span>", \
							"<span class='userdanger'>[A] delivers a firm blow to your head, causing you to fall over!</span>")
		playsound(get_turf(D), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
		D.Paralyze(20)
		D.Knockdown(100)
		D.apply_damage(25, STAMINA)
	return TRUE

///CQC grab, stuns for 1.5 seconds on use
/datum/martial_art/cqc/grab_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(A.a_intent == INTENT_GRAB && A!=D && can_use(A)) // A!=D prevents grabbing yourself
		add_to_streak("G",D)
		if(check_streak(A,D)) //if a combo is made no grab upgrade is done
			return TRUE
		if(D.grabbedby(A))
			D.Stun(15)
		if(A.grab_state < 1)
			restraining = FALSE
		return TRUE
	else
		return FALSE

///CQC harm intent, deals 15 stamina damage and immobilizes for 1.5 seconds, if the attacker is prone, they knock the defender down and stand up
/datum/martial_art/cqc/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("H",D)
	if(check_streak(A,D))
		return TRUE
	log_combat(A, D, "attacked (CQC)")
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/picked_hit_type = pick("CQC'd", "Big Bossed")
	var/bonus_damage = 15
	D.apply_damage(bonus_damage, STAMINA)
	playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	D.visible_message("<span class='danger'>[A] [picked_hit_type] [D]!</span>", \
					  "<span class='userdanger'>[A] [picked_hit_type] you!</span>")
	D.Immobilize(15)
	log_combat(A, D, "[picked_hit_type] (CQC)")
	if(!(A.mobility_flags & MOBILITY_STAND) && (D.mobility_flags & MOBILITY_STAND))
		D.visible_message("<span class='warning'>[A] leg sweeps [D]!", \
							"<span class='userdanger'>[A] leg sweeps you!</span>")
		playsound(get_turf(A), 'sound/effects/hit_kick.ogg', 50, 1, -1)
		D.Paralyze(10)
		D.Knockdown(30)
		A.set_resting(FALSE)
		A.SetKnockdown(0)
		log_combat(A, D, "sweeped (CQC)")
	return TRUE

///CQC disarm, 65% chance to instantly pick up the opponent's weapon and deal 5 stamina damage, also used for choke attack
/datum/martial_art/cqc/disarm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	add_to_streak("D",D)
	var/obj/item/I = null
	if(check_streak(A,D))
		return TRUE
	A.do_attack_animation(D, ATTACK_EFFECT_DISARM)
	if(!D.stat && !D.IsParalyzed() && !restraining)
		if(prob(65))
			I = D.get_active_held_item()
			D.visible_message("<span class='warning'>[A] quickly grabs [D]'s arm and and chops it, disarming them!</span>", \
								"<span class='userdanger'>[A] grabs your arm and chops it, disarming you!</span>")
			playsound(get_turf(D), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
			if(I && D.temporarilyRemoveItemFromInventory(I))
				A.put_in_hands(I)
			D.Jitter(2)
			D.apply_damage(5, STAMINA)
		else
			D.visible_message("<span class='danger'>[A] grabs at [D]'s arm, but misses!</span>", \
								"<span class='userdanger'>[A] grabs at your arm, but misses!</span>")
			playsound(D, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		log_combat(A, D, "disarmed (CQC)", "[I ? " grabbing \the [I]" : ""]")
	if(restraining && A.pulling == D)
		if(chokehold_active)
			return TRUE
		log_combat(A, D, "began to chokehold(CQC)")
		D.visible_message("<span class='danger'>[A] puts [D] into a chokehold!</span>", \
							"<span class='userdanger'>[A] puts you into a chokehold!</span>")
		if(handle_chokehold(A, D))
			D.Unconscious(400)
			if(A.grab_state < GRAB_NECK)
				A.grab_state = GRAB_NECK
			A.visible_message("<span class='danger'>[A] relaxes their grip on [D].</span>", \
								"<span class='danger'>You relax your grip on [D].</span>") //visible message comes from attacker since defender is unconscious and therefore can't see
		else
			if(A.grab_state)
				A.grab_state = min(1, A.grab_state - 1) //immediately lose grab power...
				if(!A.grab_state || prob(BASE_GRAB_RESIST_CHANCE/A.grab_state)) //...and have a chance to lose the entire grab
					A.visible_message("<span class='danger'>[A] is put off balance, losing their grip on [D]!</span>", \
										"<span class='danger'>You are put off balance, and you lose your grip on [D]!</span>")
					A.stop_pulling()
				else
					A.visible_message("<span class='danger'>[A] is put off balance, and struggles to maintain their grip on [D]!</span>", \
										"<span class='danger>You are put off balance, and struggle to maintain your grip on [D]!</span>")
	chokehold_active = FALSE
	restraining = FALSE
	return TRUE

/**
  * CQC chokehold handle
  *
  * handles chokehold attack, dealing 10 oxygen damage with stamina damage multiplied as a % bonus every 1.5 seconds
  * returns true if total damage reaches 80 or oxygen damage reaches 50
  * returns false if the attack is interrupted
  */
/datum/martial_art/cqc/proc/handle_chokehold(mob/living/carbon/human/A, mob/living/carbon/human/D) //handles the chokehold attack, dealing oxygen damage until the target is unconscious or would have less than 20 health before knocking out
	chokehold_active = TRUE
	var/damage2deal = 10 * (1+D.getStaminaLoss()/100) //stamina damage boosts the effectiveness of an attack, making using other attacks to prepare important
	while(do_mob(A, D, 15))
		if(!A.grab_state)
			return FALSE
		if(D.health - damage2deal < 20 || D.stat)
			return TRUE
		D.adjustOxyLoss(damage2deal)
		if(D.getOxyLoss() >= 50)
			return TRUE

///CQC counter: attacker's weapon is placed in the defender's offhand and they are knocked down
/datum/martial_art/cqc/handle_counter(mob/living/carbon/human/user, mob/living/carbon/human/attacker) //I am going to fucking gut whoever did the old counter system also whoever made martial arts
	if(!can_use(user))
		return
	user.do_attack_animation(attacker, ATTACK_EFFECT_DISARM)
	attacker.visible_message("<span class='warning'>[user] grabs [attacker]'s arm as they attack and throws them to the ground!</span>", \
						"<span class='userdanger'>[user] grabs your arm as you attack and throws you to the ground!</span>")
	playsound(get_turf(attacker), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	var/obj/item/I = attacker.get_active_held_item()
	if(I && attacker.temporarilyRemoveItemFromInventory(I))
		var/hand = user.get_inactive_hand_index()
		if(!user.put_in_hand(I, hand))
			I.forceMove(get_turf(attacker))
	attacker.Paralyze(20)
	attacker.Knockdown(60)

/**
  * CQC help proc
  *
  * Tells the user how CQC attacks work
  */
/mob/living/carbon/human/proc/CQC_help()
	set name = "Remember The Basics"
	set desc = "You try to remember some of the basics of CQC."
	set category = "CQC"
	to_chat(usr, "<b><i>You try to remember some of the basics of CQC.</i></b>")

	to_chat(usr, "<span class='notice'><b>All of your unarmed attacks deal stamina damage instead of your normal physical damage type</b></span>")

	to_chat(usr, "<span class='notice'><b>Disarm Intent</b> Has a chance to disarm the opponent's main hand, and immediately pick up the item if successful</span>")
	to_chat(usr, "<span class='notice'><b>Grab Intent</b> Will stun opponents for a short second, allowing you to quickly increase the strength of your grabs</span>")
	to_chat(usr, "<span class='notice'><b>Harm Intent</b> Will deal a competitive amount of stamina damage, and hitting a standing opponent while you are prone will both knock them down and stand you up</span>")

	to_chat(usr, "<span class='notice'>Slam</span>: Grab Harm. Slam opponent into the ground, knocking them down and dealing decent stamina damage.")
	to_chat(usr, "<span class='notice'>CQC Kick</span>: Disarm Harm. Knocks opponent away and slows them. Deals heavy stamina damage to prone opponents.")
	to_chat(usr, "<span class='notice'>Restrain</span>: Grab Grab. Locks opponents into a restraining position, making your grab harder to break out of, disarm to begin a chokehold which deal gradual oxygen damage until the opponent is unconscious, with the damage increasing based on their stamina damage. Failing to complete the chokehold will weaken and possibly break your grab.")
	to_chat(usr, "<span class='notice'>Pressure</span>: Disarm, Disarm, Grab. Disables the targetted limb or a random limb if the head or chest are targetted, as well as forcing the target to drop anything they are holding.")
	to_chat(usr, "<span class='notice'>Consecutive CQC</span>: Harm Harm Harm Harm Harm. Offensive move, deals bonus stamina damage and knocking down on the last hit.")

	to_chat(usr, "<b><i>In addition, by having your throw mode on when being attacked, you enter an active defense mode where you have a chance to block and sometimes even counter attacks done to you.</i></b>")
