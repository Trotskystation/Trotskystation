/datum/department_goal/eng
	account = ACCOUNT_ENG

// Store like 70e6 joules
// Which is like, 14 roundstart SMES' worth (so requires upgrades)
/datum/department_goal/eng/SMES
	name = "Store 70MW"
	desc = "Store 70MW of energy in the station's SMES'"
	reward = "50000"

/datum/department_goal/eng/SMES/check_complete()
	var/charge = 0
	for(var/obj/machinery/power/smes/s in GLOB.machines)
		if(!is_station_level(s.z))
			continue
		charge += s.charge
	return charge >= 70e6


// Fire up a supermatter
/datum/department_goal/eng/additional_supermatter
	name = "Fire up a supermatter"
	desc = "Order and fire up a supermatter shard"
	reward = "50000"

// Only available if the station doesn't have a suppermatter
/datum/department_goal/eng/additional_supermatter/is_available()
	return !(GLOB.main_supermatter_engine)


// Set up a singularity
/datum/department_goal/eng/additional_singularity
	name = "Spark a singularity"
	desc = "Start a singularity engine using a singularity generator"
	reward = "50000"

/datum/department_goal/eng/additional_singularity/is_available()
	return GLOB.main_supermatter_engine

/datum/department_goal/eng/additional_singularity/check_complete()
	for(var/obj/singularity/s in GLOB.singularities)
		if(is_station_level(s.z) && !istype(s, /obj/singularity/energy_ball))
			return TRUE
	return FALSE
