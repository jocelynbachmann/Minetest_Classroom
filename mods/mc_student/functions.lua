local marker_expiry = 30

function mc_student.record_coordinates(player,message)
	if mc_core.checkPrivs(player,{interact = true}) then
		local pmeta = player:get_meta()
		local pos = player:get_pos()
		local realmID = pmeta:get_int("realm")
		local temp
		clean_message = minetest.formspec_escape(message)
		temp = minetest.deserialize(pmeta:get_string("coordinates"))
		if temp == nil then
			datanew = {
				realms = { realmID, },
				coords = { pos, }, 
				notes = { clean_message, },
			}
		else
			if temp.realms then table.insert(temp.realms, realmID) else temp.realms = {realmID} end
			if temp.coords then table.insert(temp.coords, pos) else temp.coords = {pos} end
			if temp.notes then table.insert(temp.notes, clean_message) else temp.notes = {clean_message} end
			datanew = {realms = temp.realms, coords = temp.coords, notes = temp.notes, }
		end
		pmeta:set_string("coordinates", minetest.serialize(datanew))
		minetest.chat_send_player(player:get_player_name(), minetest.colorize("#FF00FF","[Minetest Classroom] Your position was recorded in your notebook."))
	end
end

function mc_student.queue_marker(player,message,pos)
	if player and pos then
		local pname = player:get_player_name()
		if not message then 
			message = "m" 
		else
			message = "m "..message
		end
		if mc_student.markers[pname] then
			mc_student.markers[pname].timer:cancel()
		end
		mc_student.markers[pname] = {
			timer = minetest.after(marker_expiry, mc_student.remove_marker, pname),
		}
		mc_student.show_marker(pname,message,pos)
	end
end

function mc_student.show_marker(pname,message,pos)
	if not mc_student.hud:get(pname,pname) then 
		mc_student.hud:add(pname,pname,{
			hud_elem_type = "waypoint",
			world_pos = pos,
			precision = 1,
			number = 0xFF0000,
			text = message
		})
	else
		mc_student.hud:change(pname,pname,{
			world_pos = pos,
			text = message
		})
	end
end

function mc_student.remove_marker(pname)
	if mc_student.markers[pname] then
		mc_student.markers[pname].timer:cancel()
		mc_student.markers[pname] = nil
	end
	if mc_student.hud:get(pname,pname) then
		mc_student.hud:remove(pname,pname)
	end
end