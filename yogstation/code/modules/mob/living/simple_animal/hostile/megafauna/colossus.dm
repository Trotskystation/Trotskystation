#define COLOSSUS_SLEEP(X) sleep(X); if(QDELETED(src)) return;
/obj/item/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 20 //Yogs - Down from 25
	armour_penetration = 100
	speed = 4 // Yogs - Slowed from 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	ranged_cooldown = world.time + 120

	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message("<span class='colossus'>\"<b>You can't dodge.</b>\"</span>")
		ranged_cooldown = world.time + 30
		telegraph()
		dir_shots(GLOB.alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	if(prob(20+anger_modifier)) //Major attack
		telegraph()

		if(health < maxHealth/3)
			INVOKE_ASYNC(src, .proc/double_spiral)
		else
			visible_message("<span class='colossus'>\"<b>Judgement.</b>\"</span>")
			INVOKE_ASYNC(src, .proc/spiral_shoot, pick(TRUE, FALSE))
	//Yogs begin - Added health gate and telegraph
	else if(prob(20) && health < maxHealth/2)
		telegraph()
		COLOSSUS_SLEEP(3)
		visible_message("<span class='colossus'>\"<b>Bow.</b>\"</span>")
	//Yogs end
		ranged_cooldown = world.time + 30
		random_shots()
	else
		if(prob(70))
			//Yogs begin - Colossus changes color immediately before shotgunning.
			var/oldcolor = color
			animate(src, color = "#C80000", time = 5)
			COLOSSUS_SLEEP(5)
			ranged_cooldown = world.time + 20
			blast()
			animate(src, color = oldcolor, time = 2)
			COLOSSUS_SLEEP(2)
			//Yogs end
		else
			ranged_cooldown = world.time + 40
			INVOKE_ASYNC(src, .proc/alternating_dir_shots)
