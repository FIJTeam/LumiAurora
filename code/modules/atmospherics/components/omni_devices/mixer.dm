//--------------------------------------------
// Gas mixer - omni variant
//--------------------------------------------
/obj/machinery/atmospherics/omni/mixer
	name = "omni gas mixer"
	icon_state = "map_mixer"
	base_icon = "mixer"
	desc_info = "Combines gas from custom input and output directions.  The percentage of combined gas can be defined."

	use_power = POWER_USE_IDLE
	idle_power_usage = 150		//internal circuitry, friction losses and stuff
	power_rating = 15000			//15000 W ~ 20 HP

	var/list/inputs = new()
	var/datum/omni_port/output

	//setup tags for initial concentration values (must be decimal)
	var/tag_north_con
	var/tag_south_con
	var/tag_east_con
	var/tag_west_con

	var/max_flow_rate = ATMOS_DEFAULT_VOLUME_MIXER
	var/set_flow_rate = ATMOS_DEFAULT_VOLUME_MIXER

	var/list/mixing_inputs = list()

/obj/machinery/atmospherics/omni/mixer/Initialize()
	. = ..()
	if(mapper_set())
		var/con = 0
		for(var/datum/omni_port/P in ports)
			switch(P.dir)
				if(NORTH)
					if(tag_north_con && tag_north == 1)
						P.concentration = tag_north_con
						con += max(0, tag_north_con)
				if(SOUTH)
					if(tag_south_con && tag_south == 1)
						P.concentration = tag_south_con
						con += max(0, tag_south_con)
				if(EAST)
					if(tag_east_con && tag_east == 1)
						P.concentration = tag_east_con
						con += max(0, tag_east_con)
				if(WEST)
					if(tag_west_con && tag_west == 1)
						P.concentration = tag_west_con
						con += max(0, tag_west_con)

	for(var/datum/omni_port/P in ports)
		P.air.volume = ATMOS_DEFAULT_VOLUME_MIXER

/obj/machinery/atmospherics/omni/mixer/Destroy()
	inputs.Cut()
	output = null
	return ..()

/obj/machinery/atmospherics/omni/mixer/sort_ports()
	for(var/datum/omni_port/P in ports)
		if(P.update)
			if(output == P)
				output = null
			if(inputs.Find(P))
				inputs -= P

			switch(P.mode)
				if(ATM_INPUT)
					inputs += P
				if(ATM_OUTPUT)
					output = P

	if(!mapper_set())
		for(var/datum/omni_port/P in inputs)
			P.concentration = 1 / max(1, inputs.len)

	if(output)
		output.air.volume = ATMOS_DEFAULT_VOLUME_MIXER * 0.75 * inputs.len
		output.concentration = 1

	rebuild_mixing_inputs()

/obj/machinery/atmospherics/omni/mixer/proc/mapper_set()
	return (tag_north_con || tag_south_con || tag_east_con || tag_west_con)

/obj/machinery/atmospherics/omni/mixer/error_check()
	if(!output || !inputs)
		return 1
	if(inputs.len < 2) //requires at least 2 inputs ~otherwise why are you using a mixer?
		return 1

	//concentration must add to 1
	var/total = 0
	for (var/datum/omni_port/P in inputs)
		total += P.concentration

	if (total != 1)
		return 1

	return 0

/obj/machinery/atmospherics/omni/mixer/process()
	if(!..())
		return 0

	//Figure out the amount of moles to transfer
	var/transfer_moles = 0
	for (var/datum/omni_port/P in inputs)
		transfer_moles += (set_flow_rate*P.concentration/P.air.volume)*P.air.total_moles

	var/power_draw = -1
	if (transfer_moles > MINIMUM_MOLES_TO_FILTER)
		power_draw = mix_gas(src, mixing_inputs, output.air, transfer_moles, power_rating)

	if (power_draw >= 0)
		last_power_draw = power_draw
		use_power_oneoff(power_draw)

		for(var/datum/omni_port/P in inputs)
			if(P.concentration && P.network)
				P.network.update = 1

		if(output.network)
			output.network.update = 1

	return 1

/obj/machinery/atmospherics/omni/mixer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AtmosMixer", capitalize_first_letters(name))
		ui.open()

/obj/machinery/atmospherics/omni/mixer/ui_data()
	var/list/data = new()

	data["power"] = use_power
	data["configuring"] = configuring
	data["power_draw"] = last_power_draw
	data["max_power_draw"] = power_rating

	var/portData[0]
	for(var/datum/omni_port/P in ports)
		if(!configuring && P.mode == 0)
			continue

		var/input = 0
		var/output = 0
		switch(P.mode)
			if(ATM_INPUT)
				input = 1
			if(ATM_OUTPUT)
				output = 1

		portData[++portData.len] = list("dir" = dir_name(P.dir, capitalize = 1), \
										"concentration" = round(P.concentration * 100), \
										"input" = input, \
										"output" = output, \
										"lock" = P.con_lock)

	if(portData.len)
		data["ports"] = portData
	if(output)
		data["flow_rate"] = set_flow_rate
		data["current_flow_rate"] = last_flow_rate
		data["max_flow_rate"] = max_flow_rate

	return data

/obj/machinery/atmospherics/omni/mixer/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("power")
			if(!configuring)
				update_use_power(!use_power)
			else
				update_use_power(POWER_USE_OFF)
		if("configure")
			configuring = !configuring
			if(configuring)
				update_use_power(POWER_USE_OFF)

	if(configuring && !use_power)
		switch(action)
			if("set_flow_rate")
				set_flow_rate = between(0, params["rate"], max_flow_rate)
			if("switch_mode")
				switch_mode(dir_flag(params["dir"]), params["mode"])
			if("set_concentration")
				change_concentration(dir_flag(params["dir"]), params["concentration"] / 100)
			if("switch_lock")
				con_lock(dir_flag(params["dir"]))

	update_icon()
	return TRUE

/obj/machinery/atmospherics/omni/mixer/proc/switch_mode(var/port = NORTH, var/mode = ATM_NONE)
	if(mode != ATM_INPUT && mode != ATM_OUTPUT)
		switch(mode)
			if("in")
				mode = ATM_INPUT
			if("out")
				mode = ATM_OUTPUT
			else
				mode = ATM_NONE

	for(var/datum/omni_port/P in ports)
		var/old_mode = P.mode
		if(P.dir == port)
			switch(mode)
				if(ATM_INPUT)
					if(P.mode == ATM_OUTPUT)
						return
					P.mode = mode
				if(ATM_OUTPUT)
					P.mode = mode
					P.con_lock = FALSE
				if(ATM_NONE)
					if(P.mode == ATM_OUTPUT)
						return
					if(P.mode == ATM_INPUT && inputs.len > 2)
						P.mode = mode
		else if(P.mode == ATM_OUTPUT && mode == ATM_OUTPUT)
			P.mode = ATM_INPUT
		if(P.mode != old_mode)
			switch(P.mode)
				if(ATM_NONE)
					initialize_directions &= ~P.dir
					P.disconnect()
				else
					initialize_directions |= P.dir
					P.connect()
			P.update = 1

	update_ports()
	rebuild_mixing_inputs()

/obj/machinery/atmospherics/omni/mixer/proc/change_concentration(var/port = NORTH, var/value)
	tag_north_con = null
	tag_south_con = null
	tag_east_con = null
	tag_west_con = null

	var/non_locked = 0
	var/input_unlocked_ports = 0
	var/remain_con = 1

	for(var/datum/omni_port/P in inputs)
		if(!P.con_lock && P.mode == ATM_INPUT)
			input_unlocked_ports++
		if(P.dir != port)
			if(!P.con_lock && P.mode == ATM_INPUT)
				non_locked++
			else
				remain_con -= P.concentration

	//return if no adjustable ports
	if(non_locked < 1)
		return
	// if only one unlocked port we return
	if(input_unlocked_ports < 2)
		return

	//cap it between 0 and the max remaining concentration
	var/new_con = clamp(value, 0, remain_con)

	//new_con = min(remain_con, new_con)

	//clamp remaining concentration so we don't go into negatives
	remain_con = max(0, remain_con - new_con)

	//distribute remaining concentration between unlocked ports evenly
	remain_con /= non_locked

	for(var/datum/omni_port/P in inputs)
		if(P.dir == port)
			P.concentration = new_con
		else if(!P.con_lock)
			P.concentration = remain_con

	rebuild_mixing_inputs()

/obj/machinery/atmospherics/omni/mixer/proc/rebuild_mixing_inputs()
	mixing_inputs.Cut()
	for(var/datum/omni_port/P in inputs)
		mixing_inputs[P.air] = P.concentration

/obj/machinery/atmospherics/omni/mixer/proc/con_lock(var/port = NORTH)
	for(var/datum/omni_port/P in inputs)
		if(P.dir == port)
			P.con_lock = !P.con_lock
