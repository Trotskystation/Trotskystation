//The ammo/gun is stored in a back slot item

/obj/item/minigunbackpack
	name = "The back stash"
	desc = "The massive back stash can hold alot of ammo on your back."
	icon = 'yogstation/icons/obj/guns/minigunosprey.dmi'
	icon_state = "holstered"
	item_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_HUGE
	resistance_flags = INDESTRUCTIBLE
	var/obj/item/gun/ballistic/minigunosprey/gun
	var/armed = FALSE //whether the gun is attached, FALSE is attached, TRUE is the gun is wielded.
	var/overheat = 0
	var/overheat_max = 30
	var/heat_diffusion = 2

/obj/item/minigunbackpack/Initialize()
	. = ..()
	gun = new(src)
	START_PROCESSING(SSobj, src)

/obj/item/minigunbackpack/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/minigunbackpack/process()
	overheat = max(0, overheat - heat_diffusion)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/minigunbackpack/attack_hand(var/mob/living/carbon/user)
	if(loc == user)
		if(!armed)
			if(user.get_item_by_slot(SLOT_BACK) == src)
				armed = TRUE
				if(!user.put_in_hands(gun))
					armed = FALSE
					to_chat(user, "<span class='warning'>You need a free hand to hold the gun!</span>")
					return
				update_icon()
				user.update_inv_back()
		else
			to_chat(user, "<span class='warning'>You are already holding the gun!</span>")
	else
		..()

/obj/item/minigunbackpack/attackby(obj/item/W, mob/user, params)
	if(W == gun) //Don't need armed check, because if you have the gun assume its armed.
		user.dropItemToGround(gun, TRUE)
	else
		..()

/obj/item/minigunbackpack/dropped(mob/user)
	. = ..()
	if(armed)
		user.dropItemToGround(gun, TRUE)

/obj/item/minigunbackpack/MouseDrop(atom/over_object)
	. = ..()
	if(armed)
		return
	if(iscarbon(usr))
		var/mob/M = usr

		if(!over_object)
			return

		if(!M.incapacitated())

			if(istype(over_object, /obj/screen/inventory/hand))
				var/obj/screen/inventory/hand/H = over_object
				M.putItemFromInventoryInHandIfPossible(src, H.held_index)


/obj/item/minigunbackpack/update_icon()
	if(armed)
		icon_state = "notholstered"
	else
		icon_state = "holstered"

/obj/item/minigunbackpack/proc/attach_gun(var/mob/user)
	if(!gun)
		gun = new(src)
	gun.forceMove(src)
	armed = FALSE
	if(user)
		to_chat(user, "<span class='notice'>You attach the [gun.name] to the [name].</span>")
	else
		visible_message("<span class='warning'>The [gun.name] snaps back onto the [name]!</span>")
	update_icon()
	user.update_inv_back()


/obj/item/gun/ballistic/minigunosprey
	name = "M-546 Osprey"
	desc = "An advanced minigun with an incredible rate of fire. Requires a bulky backpack to store all that ammo."
	icon = 'yogstation/icons/obj/guns/minigunosprey.dmi'
	icon_state = "minigun_spin"
	item_state = "minigunosprey"
	lefthand_file = 'yogstation/icons/mob/inhands/weapons/minigun_inhand_left.dmi'
	righthand_file = 'yogstation/icons/mob/inhands/weapons/minigun_inhand_right.dmi'
	flags_1 = CONDUCT_1
	slowdown = 2
	slot_flags = null
	w_class = WEIGHT_CLASS_HUGE
	materials = list()
	burst_size = 3
	automatic = FALSE
	fire_delay = 1
	recoil = 0.5
	spread = 34
	fire_sound_volume = 60
	weapon_weight = WEAPON_HEAVY
	fire_sound = 'sound/weapons/gunshot.ogg'
	mag_type = /obj/item/ammo_box/magazine/internal/minigunosprey
	tac_reloads = FALSE
	casing_ejector = FALSE
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	var/obj/item/minigunbackpack/ammo_pack

/obj/item/gun/ballistic/minigunosprey/Initialize()
	if(istype(loc, /obj/item/minigunbackpack)) //We should spawn inside an ammo pack so let's use that one.
		ammo_pack = loc
		START_PROCESSING(SSfastprocess, src)
	else
		return INITIALIZE_HINT_QDEL //No pack, no gun

	return ..()

/obj/item/gun/ballistic/minigunosprey/attack_self(mob/living/user)
	return

/obj/item/gun/ballistic/minigunosprey/dropped(mob/user)
	. = ..()
	if(ammo_pack)
		ammo_pack.attach_gun(user)
	else
		qdel(src)

/obj/item/gun/ballistic/minigunosprey/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(ammo_pack)
		if(ammo_pack.overheat < ammo_pack.overheat_max)
			ammo_pack.overheat += burst_size
			..()
		else
			to_chat(user, "The gun's heat sensor locked the trigger to prevent heat damage.")

/obj/item/gun/ballistic/minigunosprey/afterattack(atom/target, mob/living/user, flag, params)
	if(!ammo_pack || ammo_pack.loc != user)
		to_chat(user, "You need more ammo to fire the gun!")
	. = ..()

/obj/item/gun/ballistic/minigunosprey/dropped(mob/living/user)
	. = ..()
	ammo_pack.attach_gun(user)
