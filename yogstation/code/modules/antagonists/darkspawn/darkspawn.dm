#define MUNDANE 0
#define DIVULGED 1
#define PROGENITOR 2

//aka Shadowlings/umbrages/whatever
/datum/antagonist/darkspawn
	name = "Darkspawn"
	roundend_category = "darkspawn"
	antagpanel_category = "Darkspawn"
	job_rank = ROLE_DARKSPAWN
	var/darkspawn_state = MUNDANE //0 for normal crew, 1 for divulged, and 2 for progenitor
	antag_moodlet = /datum/mood_event/sling

	//Psi variables
	var/psi = 100 //Psi is the resource used for darkspawn powers
	var/psi_cap = 100 //Max Psi by default
	var/psi_regen = 20 //How much Psi will regenerate after using an ability
	var/psi_regen_delay = 5 //How many ticks need to pass before Psi regenerates
	var/psi_regen_ticks = 0 //When this hits 0, regenerate Psi and return to psi_regen_delay
	var/psi_used_since_regen = 0 //How much Psi has been used since we last regenerated
	var/psi_regenerating = FALSE //Used to prevent duplicate regen proc calls

	//Lucidity variables
	var/lucidity = 3 //Lucidity is used to buy abilities and is gained by using Devour Will
	var/lucidity_drained = 0 //How much lucidity has been drained from unique players

	//Ability and upgrade variables
	var/list/abilities = list() //An associative list ("id" = ability datum) containing the abilities the darkspawn has
	var/list/upgrades = list() //An associative list ("id" = null or TRUE) containing the passive upgrades the darkspawn has


// Antagonist datum things like assignment //

/datum/antagonist/darkspawn/on_gain()
	SSticker.mode.darkspawn += owner
	owner.special_role = "darkspawn"
	owner.current.hud_used.psi_counter.invisibility = 0
	update_psi_hud()
	add_ability("divulge")
	addtimer(CALLBACK(src, .proc/begin_force_divulge), 13800) //this won't trigger if they've divulged when the proc runs
	START_PROCESSING(SSprocessing, src)
	var/datum/objective/darkspawn/O = new
	objectives += O
	O.update_explanation_text()
	owner.announce_objectives()
	return ..()

/datum/antagonist/darkspawn/on_removal()
	SSticker.mode.darkspawn -= owner
	owner.special_role = null
	adjust_darkspawn_hud(FALSE)
	owner.current.hud_used.psi_counter.invisibility = initial(owner.current.hud_used.psi_counter.invisibility)
	owner.current.hud_used.psi_counter.maptext = ""
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/datum/antagonist/darkspawn/apply_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			if(!silent)
				to_chat(traitor_mob, "Our powers allow us to overcome our clownish nature, allowing us to wield weapons with impunity.")
			traitor_mob.dna.remove_mutation(CLOWNMUT)
	adjust_darkspawn_hud(TRUE)
	owner.current.grant_language(/datum/language/darkspawn)

/datum/antagonist/darkspawn/remove_innate_effects()
	if(owner.assigned_role == "Clown")
		var/mob/living/carbon/human/traitor_mob = owner.current
		if(traitor_mob && istype(traitor_mob))
			traitor_mob.dna.add_mutation(CLOWNMUT)
	adjust_darkspawn_hud(FALSE)
	owner.current.remove_language(/datum/language/darkspawn)

//Round end stuff
/datum/antagonist/darkspawn/proc/check_darkspawn_death()
	for(var/DM in get_antag_minds(/datum/antagonist/darkspawn))
		var/datum/mind/dark_mind = DM
		if(istype(dark_mind))
			if((dark_mind) && (dark_mind.current.stat != DEAD) && ishuman(dark_mind.current))
				return FALSE
	return TRUE

/datum/antagonist/darkspawn/roundend_report()
	return "[owner ? printplayer(owner) : "Unnamed Darkspawn"]"

/datum/antagonist/darkspawn/roundend_report_header()
	if(SSticker.mode.sacrament_done)
		return "<span class='greentext big'>The darkspawn have completed the Sacrament!</span><br>"
	else if(!SSticker.mode.sacrament_done && check_darkspawn_death())
		return "<span class='redtext big'>The darkspawn have been killed by the crew!</span><br>"
	else if(!SSticker.mode.sacrament_done && SSshuttle.emergency.mode >= SHUTTLE_ESCAPE)
		return "<span class='redtext big'>The crew escaped the station before the darkspawn could complete the Sacrament!</span><br>"
	else
		return "<span class='redtext big'>The darkspawn have failed!</span><br>"

//Admin panel stuff

/datum/antagonist/darkspawn/antag_panel_data()
	. = "<b>Abilities:</b><br>"
	for(var/V in abilities)
		var/datum/action/innate/darkspawn/D = has_ability(V)
		if(D && istype(D))
			. += "[D.name] ([D.id])<br>"
	. += "<br><b>Upgrades:</b><br>"
	for(var/V in upgrades)
		. += "[V]<br>"

/datum/antagonist/darkspawn/get_admin_commands()
	. = ..()
	.["Give Ability"] = CALLBACK(src,.proc/admin_give_ability)
	.["Take Ability"] = CALLBACK(src,.proc/admin_take_ability)
	if(darkspawn_state == MUNDANE)
		.["Divulge"] = CALLBACK(src, .proc/divulge)
		.["Force-Divulge (Obvious)"] = CALLBACK(src, .proc/force_divulge)
	else if(darkspawn_state == DIVULGED)
		.["Give Upgrade"] = CALLBACK(src, .proc/admin_give_upgrade)
		.["[psi]/[psi_cap] Psi"] = CALLBACK(src, .proc/admin_edit_psi)
		.["[lucidity] Lucidity"] = CALLBACK(src, .proc/admin_edit_lucidity)
		.["[lucidity_drained] / [SSticker.mode.required_succs] Unique Lucidity"] = CALLBACK(src, .proc/admin_edit_lucidity_drained)
		.["Sacrament (ENDS THE ROUND)"] = CALLBACK(src, .proc/sacrament)

/datum/antagonist/darkspawn/proc/admin_give_ability(mob/admin)
	var/id = stripped_input(admin, "Enter an ability ID, for \"all\" to give all of them.", "Give Ability")
	if(!id)
		return
	if(has_ability(id))
		to_chat(admin, "<span class='warning'>[owner.current] already has this ability!</span>")
		return
	if(id != "all")
		add_ability(id)
		to_chat(admin, "<span class='notice'>Gave [owner.current] the ability \"[id]\".</span>")
	else
		for(var/V in subtypesof(/datum/action/innate/darkspawn))
			var/datum/action/innate/darkspawn/D = V
			if(!has_ability(initial(D.id)) && !initial(D.blacklisted))
				add_ability(initial(D.id))
		to_chat(admin, "<span class='notice'>Gave [owner.current] all abilities.</span>")

/datum/antagonist/darkspawn/proc/admin_take_ability(mob/admin)
	var/id = stripped_input(admin, "Enter an ability ID.", "Take Ability")
	if(!id)
		return
	if(!has_ability(id))
		to_chat(admin, "<span class='warning'>[owner.current] does not have this ability!</span>")
		return
	remove_ability(id)
	to_chat(admin, "<span class='danger'>Took from [owner.current] the ability \"[id]\".</span>")

/datum/antagonist/darkspawn/proc/admin_give_upgrade(mob/admin)
	var/id = stripped_input(admin, "Enter an upgrade ID, for \"all\" to give all of them.", "Give Upgrade")
	if(!id)
		return
	if(has_upgrade(id))
		to_chat(admin, "<span class='warning'>[owner.current] already has this upgrade!</span>")
		return
	if(id != "all")
		add_upgrade(id)
		to_chat(admin, "<span class='notice'>Gave [owner.current] the upgrade \"[id]\".</span>")
	else
		for(var/V in subtypesof(/datum/darkspawn_upgrade))
			var/datum/darkspawn_upgrade/D = V
			if(!has_upgrade(initial(D.id)))
				add_upgrade(initial(D.id))
		to_chat(admin, "<span class='notice'>Gave [owner.current] all upgrades.</span>")

/datum/antagonist/darkspawn/proc/admin_edit_psi(mob/admin)
	var/new_psi = input(admin, "Enter a new psi amount. (Current: [psi]/[psi_cap])", "Change Psi", psi) as null|num
	if(!new_psi)
		return
	new_psi = clamp(new_psi, 0, psi_cap)
	psi = new_psi

/datum/antagonist/darkspawn/proc/admin_edit_lucidity(mob/admin)
	var/newcidity = input(admin, "Enter a new lucidity amount. (Current: [lucidity])", "Change Lucidity", lucidity) as null|num
	if(!newcidity)
		return
	newcidity = max(0, newcidity)
	lucidity = newcidity

/datum/antagonist/darkspawn/proc/admin_edit_lucidity_drained(mob/admin)
	var/newcidity = input(admin, "Enter a new lucidity amount. (Current: [lucidity_drained])", "Change Lucidity Drained", lucidity_drained) as null|num
	if(!newcidity)
		return
	newcidity = max(0, newcidity)
	lucidity_drained = newcidity

/datum/antagonist/darkspawn/greet()
	to_chat(owner.current, "<span class='velvet bold big'>You are a darkspawn!</span>")
	to_chat(owner.current, "<i>Append :k or .k before your message to silently speak with any other darkspawn.</i>")
	to_chat(owner.current, "<i>When you're ready, retreat to a hidden location and Divulge to shed your human skin.</i>")
	to_chat(owner.current, "<span class='boldwarning'>If you do not do this within twenty five minutes, this will happen involuntarily. Prepare quickly.</span>")
	to_chat(owner.current, "<i>Remember that this will make you die in the light and heal in the dark - keep to the shadows.</i>")
	owner.current.playsound_local(get_turf(owner.current), 'yogstation/sound/ambience/antag/darkspawn.ogg', 50, FALSE)

/datum/objective/darkspawn
	explanation_text = "Become lucid and perform the Sacrament."

/datum/objective/darkspawn/update_explanation_text()
	explanation_text = "Become lucid and perform the Sacrament. You will need to devour [SSticker.mode.required_succs] different people's wills and purchase all passive upgrades to do so."

/datum/objective/darkspawn/check_completion()
	return (SSticker.mode.sacrament_done)

/datum/antagonist/darkspawn/proc/adjust_darkspawn_hud(add_hud)
	if(add_hud)
		SSticker.mode.update_darkspawn_icons_added(owner)
	else
		SSticker.mode.update_darkspawn_icons_removed(owner)

// Darkspawn-related things like Psi //

/datum/antagonist/darkspawn/process() //This is here since it controls most of the Psi stuff
	psi = min(psi, psi_cap)
	if(psi != psi_cap)
		psi_regen_ticks--
		if(!psi_regen_ticks)
			regenerate_psi()
	update_psi_hud()

/datum/antagonist/darkspawn/proc/has_psi(amt)
	return psi >= amt

/datum/antagonist/darkspawn/proc/use_psi(amt)
	if(!has_psi(amt))
		return
	psi_regen_ticks = psi_regen_delay
	psi_used_since_regen += amt
	psi -= amt
	psi = round(psi, 0.2)
	update_psi_hud()
	return TRUE

/datum/antagonist/darkspawn/proc/regenerate_psi()
	set waitfor = FALSE
	if(psi_regenerating)
		return
	psi_regenerating = TRUE
	var/total_regen = min(psi_regen, psi_used_since_regen)
	for(var/i in 1 to psi_cap) //tick it up very quickly instead of just increasing it by the regen; also include a failsafe to avoid infinite loops
		if(!total_regen || psi >= psi_cap)
			break
		psi = min(psi + 1, psi_cap)
		total_regen--
		update_psi_hud()
		sleep(0.5)
	psi_used_since_regen = 0
	psi_regen_ticks = psi_regen_delay
	psi_regenerating = FALSE
	return TRUE

/datum/antagonist/darkspawn/proc/update_psi_hud()
	if(!owner.current || !owner.current.hud_used)
		return
	var/obj/screen/counter = owner.current.hud_used.psi_counter
	counter.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#7264FF'>[psi]</font></div>"

/datum/antagonist/darkspawn/proc/regain_abilities()
	for(var/A in abilities)
		var/datum/action/innate/darkspawn/ability = abilities[A]
		if(ability)
			ability.Remove(ability.owner)
			ability.Grant(owner.current)

/datum/antagonist/darkspawn/proc/has_ability(id)
	if(isnull(abilities[id]))
		return
	return abilities[id]

/datum/antagonist/darkspawn/proc/add_ability(id, silent, no_cost)
	if(has_ability(id))
		return
	for(var/V in subtypesof(/datum/action/innate/darkspawn))
		var/datum/action/innate/darkspawn/D = V
		if(initial(D.id) == id)
			var/datum/action/innate/darkspawn/action = new D
			action.Grant(owner.current)
			action.darkspawn = src
			abilities[id] = action
			if(!silent)
				to_chat(owner.current, "<span class='velvet'>You have learned the <b>[action.name]</b> ability.</span>")
			if(!no_cost)
				lucidity = max(0, lucidity - action.lucidity_price)
			return TRUE

/datum/antagonist/darkspawn/proc/remove_ability(id, silent)
	if(!has_ability(id))
		return
	var/datum/action/innate/darkspawn/D = abilities[id]
	if(!silent)
		to_chat(owner.current, "<span class='velvet'>You have lost the <b>[D.name]</b> ability.</span>")
	QDEL_NULL(abilities[id])
	abilities -= abilities[id]
	return TRUE

/datum/antagonist/darkspawn/proc/has_upgrade(id)
	return upgrades[id]

/datum/antagonist/darkspawn/proc/add_upgrade(id, silent, no_cost)
	if(has_upgrade(id))
		return
	for(var/V in subtypesof(/datum/darkspawn_upgrade))
		var/datum/darkspawn_upgrade/_U = V
		if(initial(_U.id) == id)
			var/datum/darkspawn_upgrade/U = new _U(src)
			upgrades[id] = TRUE
			if(!silent)
				to_chat(owner.current, "<span class='velvet bold'>You have adapted the \"[U.name]\" upgrade.</span>")
			if(!no_cost)
				lucidity = max(0, lucidity - initial(U.lucidity_price))
			U.unlock()

/datum/antagonist/darkspawn/proc/begin_force_divulge()
	if(darkspawn_state != MUNDANE)
		return
	to_chat(owner.current, "<span class='userdanger'>You feel the skin you're wearing crackling like paper - you will forcefully divulge soon! Get somewhere hidden and dark!</span>")
	owner.current.playsound_local(owner.current, 'yogstation/sound/magic/divulge_01.ogg', 50, FALSE, pressure_affected = FALSE)
	addtimer(CALLBACK(src, .proc/force_divulge), 1200)

/datum/antagonist/darkspawn/proc/force_divulge()
	if(darkspawn_state != MUNDANE)
		return
	var/mob/living/carbon/C = owner.current
	if(C && !ishuman(C))
		C.humanize()
	var/mob/living/carbon/human/H = owner.current
	if(!H)
		owner.current.gib(TRUE)
	H.visible_message("<span class='boldwarning'>[H]'s skin begins to slough off in sheets!</span>", \
	"<span class='userdanger'>You can't maintain your disguise any more! It begins sloughing off!</span>")
	playsound(H, 'yogstation/sound/creatures/darkspawn_force_divulge.ogg', 50, FALSE)
	H.do_jitter_animation(1000)
	var/processed_message = "<span class='velvet'><b>\[Mindlink\] [H.real_name] has not divulged in time and is now forcefully divulging.</b></span>"
	for(var/mob/M in GLOB.player_list)
		if(M.stat == DEAD)
			var/link = FOLLOW_LINK(M, H)
			to_chat(M, "[link] [processed_message]")
		else if(isdarkspawn(M))
			to_chat(M, processed_message)
	addtimer(CALLBACK(src, .proc/divulge), 25)
	addtimer(CALLBACK(/atom/.proc/visible_message, H, "<span class='boldwarning'>[H]'s skin sloughs off, revealing black flesh covered in symbols!</span>", \
	"<span class='userdanger'>You have forcefully divulged!</span>"), 25)

/datum/antagonist/darkspawn/proc/divulge()
	if(darkspawn_state >= DIVULGED)
		return
	var/mob/living/carbon/human/user = owner.current
	to_chat(user, "<span class='velvet bold'>Your mind has expanded. The Psi Web is now available. Avoid the light. Keep to the shadows. Your time will come.</span>")
	user.fully_heal()
	user.set_species(/datum/species/darkspawn)
	add_ability("psi_web", TRUE)
	add_ability("sacrament", TRUE)
	add_ability("devour_will", TRUE)
	add_ability("pass", TRUE)
	remove_ability("divulge", TRUE)
	darkspawn_state = DIVULGED

/datum/antagonist/darkspawn/proc/sacrament()
	var/mob/living/carbon/human/user = owner.current
	var/mob/living/simple_animal/hostile/darkspawn_progenitor/progenitor = new(get_turf(user))
	user.status_flags |= GODMODE
	user.mind.transfer_to(progenitor)
	progenitor.mind.AddSpell(new /obj/effect/proc_holder/spell/targeted/progenitor_curse(null))
	if(!SSticker.mode.sacrament_done)
		addtimer(CALLBACK(src, .proc/sacrament_shuttle_call), 50)
	for(var/V in abilities)
		remove_ability(abilities[V], TRUE)
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(M, 'yogstation/sound/magic/sacrament_complete.ogg', 70, FALSE, pressure_affected = FALSE)
	psi = 9999
	psi_cap = 9999
	psi_regen = 9999
	psi_regen_delay = 1
	SSticker.mode.sacrament_done = TRUE
	darkspawn_state = PROGENITOR
	QDEL_IN(user, 5)

/datum/antagonist/darkspawn/proc/sacrament_shuttle_call()
	SSshuttle.emergency.request(null, 0, null, FALSE, 0.1)


// Psi Web code //

/datum/antagonist/darkspawn/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = 0, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.not_incapacitated_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "PsiWeb", "Psi Web", 900, 480, master_ui, state)
		ui.open()

/datum/antagonist/darkspawn/ui_data(mob/user)
	var/list/data = list()

	data["lucidity"] = "[lucidity]  |  [lucidity_drained] / 20 unique drained total"

	var/list/abilities = list()
	var/list/upgrades = list()

	for(var/path in subtypesof(/datum/action/innate/darkspawn))
		var/datum/action/innate/darkspawn/ability = path

		if(initial(ability.blacklisted))
			continue

		var/list/AL = list() //This is mostly copy-pasted from the cellular emporium, but it should be fine regardless
		AL["name"] = initial(ability.name)
		AL["id"] = initial(ability.id)
		AL["desc"] = initial(ability.desc)
		AL["psi_cost"] = "[initial(ability.psi_cost)][initial(ability.psi_addendum)]"
		AL["lucidity_cost"] = initial(ability.lucidity_price)
		AL["owned"] = has_ability(initial(ability.id))
		AL["can_purchase"] = !AL["owned"] && lucidity >= initial(ability.lucidity_price)

		abilities += list(AL)

	data["abilities"] = abilities

	for(var/path in subtypesof(/datum/darkspawn_upgrade))
		var/datum/darkspawn_upgrade/upgrade = path

		var/list/DE = list()
		DE["name"] = initial(upgrade.name)
		DE["id"] = initial(upgrade.id)
		DE["desc"] = initial(upgrade.desc)
		DE["lucidity_cost"] = initial(upgrade.lucidity_price)
		DE["owned"] = has_upgrade(initial(upgrade.id))
		DE["can_purchase"] = !DE["owned"] && lucidity >= initial(upgrade.lucidity_price)

		upgrades += list(DE)

	data["upgrades"] = upgrades

	return data

/datum/antagonist/darkspawn/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("unlock")
			add_ability(params["id"])
		if("upgrade")
			add_upgrade(params["id"])

#undef MUNDANE
#undef DIVULGED
#undef PROGENITOR
