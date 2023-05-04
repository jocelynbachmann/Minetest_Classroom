local selectedRealmID = nil

function mc_teacher.show_controller_fs(player,tab)
	local controller_width = 16.4
	local controller_height = 10.2
    local page_width = (controller_width/8)*3.5
    local pname = player:get_player_name()
	local pmeta = player:get_meta()
	if mc_helpers.checkPrivs(player) then
		local teacher_formtable = {
			"formspec_version[6]",
			"size[",
			tostring(controller_width),
			",",
			tostring(controller_height),
			"]",
			mc_core.draw_book_fs(controller_width, controller_height, {bg = "#63406a", shadow = "#3e2b45", binding = "#5d345e", divider = "#d9d9d9"}),
			"style[tabheader;noclip=true]",
		}
        if mc_helpers.checkPrivs(player,{server = true}) then
            teacher_formtable[#teacher_formtable + 1] = "tabheader[0,-0.25;16,0.55;record_nav;Overview,Manage Classrooms,Manage Players,Moderator,Manage Server;" 
            teacher_formtable[#teacher_formtable + 1] = tab or pmeta:get_string("default_teacher_tab") or mc_teacher.fs_context.tab or "1"
            teacher_formtable[#teacher_formtable + 1] = ";true;false]"
        else
            teacher_formtable[#teacher_formtable + 1] = "tabheader[0,-0.25;16,0.55;record_nav;Overview,Manage Classrooms,Manage Players,Moderator;" 
            teacher_formtable[#teacher_formtable + 1] = tab or pmeta:get_string("default_teacher_tab") or mc_teacher.fs_context.tab or "1"
            teacher_formtable[#teacher_formtable + 1] = ";true;false]"
        end
		local tab_map = {
			["1"] = function() -- OVERVIEW
				local fs = {}
				if pmeta:get_string("default_teacher_tab") == "1" then
					fs[#fs + 1] = "style_type[label;font_size=*0.8;textcolor=#000]label[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";This tab is the default]"
				else
					fs[#fs + 1] = "checkbox[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";default_tab;"
					fs[#fs + 1] = minetest.colorize("#000","Bookmark?")
					fs[#fs + 1] = ";false]"
				end
				return fs
			end,
			["2"] = function() -- CLASSROOMS
				local fsx, fsy, last_height, last_width
                local fs = {}
				if pmeta:get_string("default_teacher_tab") == "2" then
					fs[#fs + 1] = "style_type[label;font_size=*0.8;textcolor=#000]label[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";This tab is the default]"
				else
					fs[#fs + 1] = "checkbox[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";default_tab;"
					fs[#fs + 1] = minetest.colorize("#000","Bookmark?")
					fs[#fs + 1] = ";false]"
                end
                --PAGE ONE
                fsx = 1
                fsy = 0.85
                fs[#fs + 1] = "style[intro;textcolor=#000;border=false]textarea["
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(page_width)
                fs[#fs + 1] = ","
                last_height = controller_height/5
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";intro;"
                fs[#fs + 1] = minetest.colorize("#000","Instructions")
                fs[#fs + 1] = ";View classrooms to edit or create a new classroom below. Once the classroom has been created, it will appear in the list. The classroom highlighted in the list will expose more edit options for that classroom. You can hover over most elements to learn what a button or field does.]"
                
                fs[#fs + 1] = "style_type[label;font_size=*1]label["
                fs[#fs + 1] = tostring(fsx+2)
                fs[#fs + 1] = ","
                fsy = fsy + last_height + 0.4
                last_height = 0.3
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Available Classrooms")
                fs[#fs + 1] = "]textlist["
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fsy = fsy + last_height
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(page_width)
                fs[#fs + 1] = ","
                last_height = controller_height/5
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";classroomlist;"

                local counter = 0
                local countRealms = mc_worldManager.storage:get_string("realmCount")-1
                Realm.ScanForPlayerRealms()
                for _,thisRealm in pairs(Realm.realmDict) do
                    counter = counter + 1
                    if mc_helpers.checkPrivs(player,{teacher = true}) then
                        fs[#fs + 1] = thisRealm.Name
                        fs[#fs + 1] = " ("
                        local playerCount = tonumber(thisRealm:GetPlayerCount())
                        fs[#fs + 1] = tostring(playerCount)
                        if playerCount == 1 then
                            fs[#fs + 1] = " Player)"
                        else
                            fs[#fs + 1] = " Players)"
                        end
                    end
                    if counter ~= countRealms then fs[#fs + 1] = "," end
                end
                if not selectedRealmID then selectedRealmID = mc_worldManager.spawnRealmID end
                fs[#fs + 1] = ";1;false]"

                -- Teleport button
                fs[#fs + 1] = "button["
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fsy = fsy + last_height + 0.2
                fs[#fs + 1] = tostring(fsy)
                last_width = 1.7
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";teleportrealm;Teleport]"

                -- Delete button
                fs[#fs + 1] = "button["
                fsx = fsx + last_width + 0.2
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                last_width = 1.5
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";deleterealm;Delete]"

                -- Reset button
                fs[#fs + 1] = "button["
                fsx = fsx + last_width + 0.2
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                last_width = 1.4
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";resetrealm;Reset]"

                fs[#fs + 1] = "style_type[label;font_size=*1]label["
                fsx = 1
                fs[#fs + 1] = tostring(fsx+2)
                fs[#fs + 1] = ","
                fsy = fsy + last_height + 0.4
                last_height = 0.3
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Create a New Classroom")
                fs[#fs + 1] = "]"

                fs[#fs + 1] = "field["
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fsy = fsy + last_height + 0.2
                last_height = 0.3
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                last_width = (page_width/2)-0.1
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";realmname;"
                fs[#fs + 1] = minetest.colorize("#000","Name")
                fs[#fs + 1] = ";"
                if mc_teacher.fs_context.realmname then fs[#fs + 1] = mc_teacher.fs_context.realmname end
                fs[#fs + 1] = "]"

                fs[#fs + 1] = "dropdown["
                fsx = fsx + last_width + 0.2
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";mode;Select Mode,Size,Schematic,Digital Twin;"
                if not mc_teacher.fs_context.selectedMode then mc_teacher.fs_context.selectedMode = "1" end
                fs[#fs + 1] = tostring(mc_teacher.fs_context.selectedMode)
                fs[#fs + 1] = ";true]"

                if mc_teacher.fs_context.selectedMode == "2" then
                    -- SIZE
                    fs[#fs + 1] = "field["
                    fsx = 1
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fsy = fsy + last_height + 0.4
                    fs[#fs + 1] = tostring(fsy)
                    fs[#fs + 1] = ";"
                    last_width = (page_width/3)-0.1333
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";realmxsize;"
                    fs[#fs + 1] = minetest.colorize("#000","Width")
                    fs[#fs + 1] = ";"
                    if mc_teacher.fs_context.requested_realmxsize then
                        fs[#fs + 1] = tostring(mc_teacher.fs_context.requested_realmxsize)
                    end
                    fs[#fs + 1] = "]field["
                    fsx = fsx + last_width + 0.2
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(fsy)
                    fs[#fs + 1] = ";"
                    last_width = (page_width/3)-0.1333
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";realmzsize;"
                    fs[#fs + 1] = minetest.colorize("#000","Height")
                    fs[#fs + 1] = ";"
                    if mc_teacher.fs_context.requested_realmzsize then
                        fs[#fs + 1] = tostring(mc_teacher.fs_context.requested_realmzsize)
                    end
                    fs[#fs + 1] = "]field["
                    fsx = fsx + last_width + 0.2
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(fsy)
                    fs[#fs + 1] = ";"
                    last_width = (page_width/3)-0.1333
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";realmysize;"
                    fs[#fs + 1] = minetest.colorize("#000","Length")
                    fs[#fs + 1] = ";"
                    if mc_teacher.fs_context.requested_realmysize then
                        fs[#fs + 1] = tostring(mc_teacher.fs_context.requested_realmysize)
                    end
                    fs[#fs + 1] = "]button["
                    fsx = 1
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fsy = fsy + last_height + 0.2
                    fs[#fs + 1] = tostring(fsy)
                    last_width = 1.4
                    fs[#fs + 1] = ";"
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    last_height = 0.6
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";requestrealm;Create]"
                elseif mc_teacher.fs_context.selectedMode == "3" then
                    -- SCHEMATIC
                    fs[#fs + 1] = "dropdown["
                    fsx = 1
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fsy = fsy + last_height + 0.4
                    fs[#fs + 1] = tostring(fsy)
                    fs[#fs + 1] = ";"
                    last_width = page_width
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";schematic;Select a Schematic,"
                    -- iterate through registered schematics
                    local count, counter = 0, 0
                    for _ in pairs(schematicManager.schematics) do count = count + 1 end
                    for name, path in pairs(schematicManager.schematics) do
                        counter = counter + 1
                        fs[#fs + 1] = name
                        if counter ~= count then fs[#fs + 1] = "," end
                    end
                    fs[#fs + 1] = ";"
                    if mc_teacher.fs_context.selectedSchematicIndex then fs[#fs + 1] = mc_teacher.fs_context.selectedSchematicIndex end
                    fs[#fs + 1] = ";true]button["
                    fsx = 1
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fsy = fsy + last_height + 0.2
                    fs[#fs + 1] = tostring(fsy)
                    last_width = 1.4
                    fs[#fs + 1] = ";"
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    last_height = 0.6
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";requestrealm;Create]"
                elseif mc_teacher.fs_context.selectedMode == "4" then
                    -- REALTERRAIN
                    fs[#fs + 1] = "dropdown["
                    fsx = 1
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fsy = fsy + last_height + 0.4
                    fs[#fs + 1] = tostring(fsy)
                    fs[#fs + 1] = ";"
                    last_width = page_width
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";realterrain;Select a Digital Twin,"
                    -- iterate through registered DEMs
                    local count, counter = 0, 0
                    for _ in pairs(realterrainManager.dems) do count = count + 1 end
                    for name, path in pairs(realterrainManager.dems) do
                        counter = counter + 1
                        fs[#fs + 1] = name
                        if counter ~= count then fs[#fs + 1] = "," end
                    end
                    fs[#fs + 1] = ";"
                    if mc_teacher.fs_context.selectedDEMIndex then fs[#fs + 1] = mc_teacher.fs_context.selectedDEMIndex end
                    fs[#fs + 1] = ";true]button["
                    fsx = 1
                    fs[#fs + 1] = tostring(fsx)
                    fs[#fs + 1] = ","
                    fsy = fsy + last_height + 0.2
                    fs[#fs + 1] = tostring(fsy)
                    last_width = 1.4
                    fs[#fs + 1] = ";"
                    fs[#fs + 1] = tostring(last_width)
                    fs[#fs + 1] = ","
                    last_height = 0.6
                    fs[#fs + 1] = tostring(last_height)
                    fs[#fs + 1] = ";requestrealm;Create]"
                else
                end

                --PAGE TWO
                fsx = (controller_width/2)+1
                fsy = 0.85
                fs[#fs + 1] = "style_type[label;font_size=*1.2]label["
				fs[#fs + 1] = tostring(controller_width/2+3)
				fs[#fs + 1] = ",0.4;"
				fs[#fs + 1] = minetest.colorize("#000","Classroom Options")
				fs[#fs + 1] = "]"
                
                -- Category
                fs[#fs + 1] = "dropdown["
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                last_width = (page_width/2)-0.1
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";realmcategory;Default,Spawn,Classroom,Instanced;"
                if mc_teacher.fs_context.selectedCategory then fs[#fs + 1] = mc_teacher.fs_context.selectedCategory end
                fs[#fs + 1] = ";true]"

                -- Privileges
                fs[#fs + 1] = "checkbox["
                fsx = fsx + last_width + 0.4
                fsy = 1
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "setPrivInteract"
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Interact")
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "true]"

                fs[#fs + 1] = "checkbox["
                fsy = fsy + 0.4
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "setPrivShout"
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Shout")
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "true]"

                fs[#fs + 1] = "checkbox["
                fsx = fsx + 1.7
                fsy = 1
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "setPrivFly"
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Fly")
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "true]"

                fs[#fs + 1] = "checkbox["
                fsy = fsy + 0.4
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "setPrivFast"
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Fast")
                fs[#fs + 1] = ";"
                fs[#fs + 1] = "true]"
                
                -- World Gen

                -- Colorbrewer an symbology options

                --[[ -- Background Music
                -- method: local backgroundSound = realm:get_data("background_sound")
                fs[#fs + 1] = "dropdown["
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy)
                fs[#fs + 1] = ";"
                last_width = (page_width/2)-0.1
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                -- iterate registered music
                mc_worldManager.path
                fs[#fs + 1] = ";music;None,this song,another song,third song;"
                fs[#fs + 1] = ";true]" ]]

                fs[#fs + 1] = "]button["
                fsx = (controller_width/2)+1
                fs[#fs + 1] = tostring(fsx)
                fs[#fs + 1] = ","
                fsy = 0.85 + last_height + 0.2
                fs[#fs + 1] = tostring(fsy)
                last_width = 1.4
                fs[#fs + 1] = ";"
                fs[#fs + 1] = tostring(last_width)
                fs[#fs + 1] = ","
                last_height = 0.6
                fs[#fs + 1] = tostring(last_height)
                fs[#fs + 1] = ";saverealm;Save]"

				return fs
			end,
			["3"] = function() -- PLAYERS
                local fs = {}
				if pmeta:get_string("default_teacher_tab") == "3" then
					fs[#fs + 1] = "style_type[label;font_size=*0.8;textcolor=#000]label[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";This tab is the default]"
				else
					fs[#fs + 1] = "checkbox[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";default_tab;"
					fs[#fs + 1] = minetest.colorize("#000","Bookmark?")
					fs[#fs + 1] = ";false]"
				end
				return fs
			end,
			["4"] = function() -- MODERATOR
                local fs = {}
                local fsx, fsy
                fsx = ((controller_width/2)-(((controller_width/8)*3)))/2
				if pmeta:get_string("default_teacher_tab") == "4" then
					fs[#fs + 1] = "style_type[label;font_size=*0.8;textcolor=#000]label[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";This tab is the default]"
				else
					fs[#fs + 1] = "checkbox[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";default_tab;"
					fs[#fs + 1] = minetest.colorize("#000","Bookmark?")
					fs[#fs + 1] = ";false]label["
                    fs[#fs + 1] = tostring(fsx+(controller_width/2))
                    fs[#fs + 1] = ",0.55;"
                    fs[#fs + 1] = minetest.colorize("#000","Select a Player to View Messages")
                    fs[#fs + 1] = "]textlist["
                    fs[#fs + 1] = tostring(fsx+(controller_width/2))
                    fs[#fs + 1] = ",0.85;"
                    fs[#fs + 1] = tostring(page_width)
                    fs[#fs + 1] = ","
                    fs[#fs + 1] = tostring(controller_height/4)
                    fs[#fs + 1] = ";playerlist;"
                    local chatmessages, directmessages
                    chatmessages = minetest.deserialize(mc_student.meta:get_string("chat_messages"))
                    directmessages = minetest.deserialize(mc_student.meta:get_string("direct_messages"))
                    local countchat = 0
                    local countdm = 0
                    local counter = 0
                    if chatmessages then for _ in pairs(chatmessages) do countchat = countchat + 1 end end
                    local indexed_chat_players = {}
                    if directmessages then 
                        for pname,_ in pairs(directmessages) do
                            table.insert(indexed_chat_players,pname)
                            local player_messages = directmessages[pname]
                            for to_player,_ in pairs(player_messages) do
                                local to_player_messages = player_messages[to_player]
                                for _ in pairs(to_player_messages) do
                                    countdm = countdm + 1 
                                end
                            end
                        end 
                    end
                    local unique_chat_players = {}
                    if directmessages then
                        for pnamed,_ in pairs(directmessages) do
                            table.insert(unique_chat_players,pnamed)
                            table.insert(indexed_chat_players,pnamed)
                        end
                    end

                    if chatmessages then
                        for pnamec,_ in pairs(chatmessages) do
                            for pnamec,_ in pairs(unique_chat_players) do
                                if pnamed ~= pnamec then
                                    table.insert(unique_chat_players,pnamed)
                                    table.insert(indexed_chat_players,pnamed)
                                end
                            end
                        end
                    end
                    -- Send indexed_chat_players to mod storage so that we can use it later for delete/clear callbacks
                    mc_teacher.fs_context.indexed_chat_players = indexed_chat_players
                    if unique_chat_players then
                        for _,pname in pairs(unique_chat_players) do
                            counter = counter + 1
                            fs[#fs + 1] = pname
                            if counter ~= #unique_chat_players then fs[#fs + 1] = "," end
                        end
                    else
                        fs[#fs + 1] = "No chat messages logged"
                    end
                    fs[#fs + 1] = ";1;false]"
                    if #unique_chat_players > 0 then
                        -- Add another textlist below with the messages from the selected player
                        if not tonumber(mc_teacher.fs_context.chat_player_index) then mc_teacher.fs_context.chat_player_index = 1 end
                        fs[#fs + 1] = "label["
                        fs[#fs + 1] = tostring(fsx+(controller_width/2))
                        fs[#fs + 1] = ","
                        fs[#fs + 1] = tostring(controller_height/4+0.85+0.4)
                        fs[#fs + 1] = ";"
                        fs[#fs + 1] = minetest.colorize("#000","Select a Message")
                        fs[#fs + 1] = "]textlist["
                        fs[#fs + 1] = tostring(fsx+(controller_width/2))
                        fs[#fs + 1] = ","
                        fs[#fs + 1] = tostring(controller_height/4+0.85+0.7)
                        fs[#fs + 1] = ";"
                        fs[#fs + 1] = tostring(page_width)
                        fs[#fs + 1] = ","
                        fs[#fs + 1] = tostring(controller_height/4)
                        fs[#fs + 1] = ";playerchatlist;"
                        local pname = indexed_chat_players[tonumber(mc_teacher.fs_context.chat_player_index)]
                        local player_chat_log, player_dm_log
                        if chatmessages then player_chat_log = chatmessages[pname] end
                        local to_player_names = {}
                        if directmessages then 
                            player_dm_log = directmessages[pname]
                            -- Parse the textlist index to the to_player_names
                            if player_dm_log then
                                for to_pname,_ in pairs(player_dm_log) do
                                    local to_player_messages = player_dm_log[to_pname]
                                    -- Repeat the to_player_name for as many DMs logged to create the indexed array
                                    for _ in pairs(to_player_messages) do
                                        table.insert(to_player_names,to_pname) 
                                    end
                                end
                            end
                        end
                        -- Direct messages first
                        if player_dm_log then
                            for to_player,_ in pairs(player_dm_log) do
                                counter = 0
                                for key,message in pairs(player_dm_log[to_player]) do
                                    counter = counter + 1
                                    fs[#fs + 1] = key
                                    fs[#fs + 1] = " DM to "
                                    fs[#fs + 1] = to_player
                                    fs[#fs + 1] = ": "
                                    fs[#fs + 1] = message
                                    if (counter ~= #player_dm_log[to_player]) or (counter == #player_dm_log[to_player] and player_chat_log and #player_chat_log > 0) then 
                                        fs[#fs + 1] = "," 
                                    end
                                end
                            end
                        end
                        -- General chat messages second
                        if player_chat_log then
                            counter = 0
                            for key,message in pairs(player_chat_log) do
                                counter = counter + 1
                                fs[#fs + 1] = key
                                fs[#fs + 1] = ": "
                                fs[#fs + 1] = message
                                if counter ~= #player_chat_log then fs[#fs + 1] = "," end
                            end
                        end
                        fs[#fs + 1] = ";"
                        local chat_index = tonumber(mc_teacher.fs_context.chat_index) or 1
                        fs[#fs + 1] = tostring(chat_index)
                        fs[#fs + 1] = ";false]"
                        if countchat > 0 or countdm > 0 then
                            if countdm > 0 and chat_index <= countdm then
                                local selected_to_player = to_player_names[chat_index]
                                local selected_to_player_log = player_dm_log[selected_to_player]
                                -- Get the message
                                counter = 0
                                for key,message in pairs(selected_to_player_log) do
                                    counter = counter + 1
                                    -- There may be many DMs with the selected_to_player_log, so get the correct message based on the chat_index
                                    if counter == chat_index then
                                        fs[#fs + 1] = "label["
                                        fs[#fs + 1] = tostring(fsx+(controller_width/2))
                                        fs[#fs + 1] = ","
                                        fs[#fs + 1] = tostring(controller_height/4+0.85+0.7+controller_height/4+0.2+0.2)
                                        fs[#fs + 1] = ";"
                                        fs[#fs + 1] = minetest.colorize("#000","Direct message to "..selected_to_player)
                                        fs[#fs + 1] = "]style[message;textcolor=#000]textarea["
                                        fs[#fs + 1] = tostring(fsx+(controller_width/2))
                                        fs[#fs + 1] = ","
                                        fs[#fs + 1] = tostring(controller_height/4+0.85+0.7+controller_height/4+0.2+0.5)
                                        fs[#fs + 1] = ";"
                                        fs[#fs + 1] = tostring(page_width)
                                        fs[#fs + 1] = ","
                                        fs[#fs + 1] = "1"
                                        fs[#fs + 1] = ";message;;"
                                        fs[#fs + 1] = message
                                        fs[#fs + 1] = "]"
                                    end
                                end
                            else
                                counter = countdm
                                for key,message in pairs(player_chat_log) do
                                    counter = counter + 1
                                    if counter == chat_index then
                                        fs[#fs + 1] = "label["
                                        fs[#fs + 1] = tostring(fsx+(controller_width/2))
                                        fs[#fs + 1] = ","
                                        fs[#fs + 1] = tostring(controller_height/4+0.85+0.7+controller_height/4+0.2+0.2)
                                        fs[#fs + 1] = ";"
                                        fs[#fs + 1] = minetest.colorize("#000","Message to all players")
                                        fs[#fs + 1] = "]style[message;textcolor=#000]textarea["
                                        fs[#fs + 1] = tostring(fsx+(controller_width/2))
                                        fs[#fs + 1] = ","
                                        fs[#fs + 1] = tostring(controller_height/4+0.85+0.7+controller_height/4+0.2+0.5)
                                        fs[#fs + 1] = ";"
                                        fs[#fs + 1] = tostring(page_width)
                                        fs[#fs + 1] = ","
                                        fs[#fs + 1] = "1"
                                        fs[#fs + 1] = ";message;;"
                                        fs[#fs + 1] = message
                                        fs[#fs + 1] = "]"
                                    end
                                end
                            end
                            -- There are chat messages, so add buttons
                            fs[#fs + 1] = "button["
                            fs[#fs + 1] = tostring(fsx+(controller_width/2))
                            fs[#fs + 1] = ","
                            fs[#fs + 1] = tostring(controller_height/4+0.85+0.7+controller_height/4+0.2+0.5+1+0.2)
                            fs[#fs + 1] = ";2.8,0.6;deletemessage;Delete Selected]button["
                            fs[#fs + 1] = tostring(fsx+(controller_width/2))
                            fs[#fs + 1] = ","
                            fs[#fs + 1] = tostring(controller_height/4+0.85+0.7+controller_height/4+0.2+0.5+1+0.2+0.6+0.2)
                            fs[#fs + 1] = ";3,0.6;clearlog;Clear Player's Log]"
                        end
                    end
                end
				return fs
			end,
			["5"] = function() -- SERVER
                local fsx, fsy
				local fs = {}
				if pmeta:get_string("default_teacher_tab") == "5" then
					fs[#fs + 1] = "style_type[label;font_size=*0.8;textcolor=#000]label[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";This tab is the default]"
				else
					fs[#fs + 1] = "checkbox[0.2,"
					fs[#fs + 1] = tostring(controller_height-0.2)
					fs[#fs + 1] = ";default_tab;"
					fs[#fs + 1] = minetest.colorize("#000","Bookmark?")
					fs[#fs + 1] = ";false]"
				end
                fs[#fs + 1] = "field[1,0.85;"
                fs[#fs + 1] = tostring((page_width)-1.6)
                fs[#fs + 1] = ",0.8;servermessage;"
                fs[#fs + 1] = minetest.colorize("#000","Send Message to All Connected Players")
                fs[#fs + 1] = ";]button["
                fs[#fs + 1] = tostring((controller_width/2)-1.4)
                fs[#fs + 1] = ",0.85;1.4,0.8;submitmessage;Send]style_type[label;font_size=*1;textcolor=#000]label[1,2;"
                fs[#fs + 1] = minetest.colorize("#000","Schedule Server Restart")
                fs[#fs + 1] = "]dropdown[1,2.2;3,0.8;time;1 minute,5 minutes,10 minutes,15 minutes,30 minutes,1 hour,6 hours,12 hours,24 hours;1;false]"
                fs[#fs + 1] = "button[4.2,2.2;3,0.8;submitsched;Schedule Restart]"
                fs[#fs + 1] = "button_exit[1,3.2;3,0.8;submitshutdown;Shutdown Now]"
                fsx = ((controller_width/2)-(((controller_width/8)*3)))/2
                fsy = 1
				fs[#fs + 1] = "style_type[label;font_size=*1.2]label["
				fs[#fs + 1] = tostring(controller_width/2+1.6)
				fs[#fs + 1] = ",0.4;"
				fs[#fs + 1] = minetest.colorize("#000","White-Listed IPv4 Addresses")
				fs[#fs + 1] = "]textlist["
				fs[#fs + 1] = tostring(fsx+(controller_width/2))
				fs[#fs + 1] = ",1.1;"
				fs[#fs + 1] = tostring(page_width)
				fs[#fs + 1] = ","
				fs[#fs + 1] = tostring(controller_height/3)
				fs[#fs + 1] = ";iplist;"
				local ipv4_whitelist = minetest.deserialize(networking.storage:get_string("ipv4_whitelist"))
                local count = 0
                local counter = 0
                for _ in pairs(ipv4_whitelist) do count = count + 1 end
                for ipv4,_ in pairs(ipv4_whitelist) do
                    counter = counter + 1
                    fs[#fs + 1] = ipv4
                    if counter ~= count then fs[#fs + 1] = "," end
                end
                fs[#fs + 1] = ";1;false]style_type[label;font_size=*1]label["
                fs[#fs + 1] = tostring(fsx+(controller_width/2))
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+1.3)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","Start IPv4 Range")
                fs[#fs + 1] = "]field["
                fs[#fs + 1] = tostring(fsx+(controller_width/2))
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+1.5)
                fs[#fs + 1] = ";3,0.8;ipstart;;0.0.0.0]style_type[label;font_size=*1]label["
                fs[#fs + 1] = tostring(fsx+(controller_width/2))
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+2.5)
                fs[#fs + 1] = ";"
                fs[#fs + 1] = minetest.colorize("#000","End IPv4 Range")
                fs[#fs + 1] = "]field["
                fs[#fs + 1] = tostring(fsx+(controller_width/2))
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+2.7)
                fs[#fs + 1] = ";3,0.8;ipend;;Optional]"
                fs[#fs + 1] = "button["
                fs[#fs + 1] = tostring(fsx+(controller_width/2)+3.2)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+2.7)
                fs[#fs + 1] = ";1.1,0.8;addip;Add]"
                fs[#fs + 1] = "button["
                fs[#fs + 1] = tostring(fsx+(controller_width/2)+3.2+1.3)
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+2.7)
                fs[#fs + 1] = ";1.7,0.8;removeip;Remove]"
                local state = minetest.deserialize(networking.storage:get_string("enabled"))
                if state then
                    fs[#fs + 1] = "button["
                    fs[#fs + 1] = tostring(fsx+(controller_width/2)+3.2)
                    fs[#fs + 1] =  ","
                    fs[#fs + 1] = tostring(fsy+(controller_height/4)+1.5)
                    fs[#fs + 1] = ";3,0.8;toggleoff;Turn OFF Whitelist]"
                else
                    fs[#fs + 1] = "button["
                    fs[#fs + 1] = tostring(fsx+(controller_width/2)+3.2)
                    fs[#fs + 1] =  ","
                    fs[#fs + 1] = tostring(fsy+(controller_height/4)+1.5)
                    fs[#fs + 1] = ";3,0.8;toggleon;Turn ON Whitelist]"
                end
                fs[#fs + 1] = "button_exit["
                fs[#fs + 1] = tostring(fsx+(controller_width/2))
                fs[#fs + 1] = ","
                fs[#fs + 1] = tostring(fsy+(controller_height/4)+2.7+1.2)
                fs[#fs + 1] = ";3.9,0.8;modifyrules;Modify Server Rules]"
                -- TODO: Manage Bans
				return fs
			end,
		}
		table.insert(teacher_formtable, table.concat(tab_map[tab or pmeta:get_string("default_teacher_tab") or mc_teacher.fs_context.tab or "1"](), ""))
		minetest.show_formspec(pname, "mc_teacher:controller_fs", table.concat(teacher_formtable, ""))
		return true
	end
end