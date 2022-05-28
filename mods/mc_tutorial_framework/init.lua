mc_tutorialFramework = { path = minetest.get_modpath("mc_tf")}


schematicManager.registerSchematicPath("testSchematic", mc_tutorialFramework.path .. "/realmTemplates/TestSchematic")

mc_realmportals.newPortal("mc_tf","tf_testRealm", false, "testSchematic")


----------------------------------
--    TUTORIAL BOOK FUNCTIONS   --
----------------------------------

-- Check for shout priv
local function check_perm(player)
	return minetest.check_player_privs(player:get_player_name(), { shout = true })
end

-- Define a formspec that will describe tutorials and give the option to teleport to selected tutorial realm
local mc_tf_menu = {
	"formspec_version[5]",
	"size[13,10]", 
	"box[0.2,8.4;10.2,1.4;#505050]",
	"box[10.7,8.4;2.1,1.4;#C0C0C0]",
	"textarea[5,0.2;7.8,8;text;;Welcome to Minetest Classroom! To access tutorials, select the topic you would like to learn about on the left. Tutorials can also be accessed via portals that will teleport you to the tutorial relevant to the area you are in. To use a portal, stand in the wormhole until it transports you to a new area. Once you are in the tutorial realm, you can use the portal again to return to the area you were previously in.]",
	"button_exit[11,8.65;1.5,0.9;exit;Exit]",
	"button[0.4,8.7;9.8,0.8;teleport;Teleport to Tutorial]", 
	"textlist[0.2,0.2;4.6,8;tutorials;Introduction]"
}

local descriptions = {}

local function addTutorial(name, description) 
        -- Add tutorial to the text list
		local textlist = mc_tf_menu[#mc_tf_menu]
		textlist = textlist:sub(1, textlist:len() - 1) .. "," .. name .. "]"
        mc_tf_menu[#mc_tf_menu] = textlist

		table.insert(descriptions, #descriptions, description)
		-- local textarea = mc_tf_menu[5]
		-- textarea = "textarea[5,0.2;7.8,8;text;;" .. description .. "]"
		-- mc_tf_menu[5] = textarea
end 

addTutorial("test", "testing")

local function show_tutorial_menu(player)
	if check_perm(player) then
		local pname = player:get_player_name()

		local formspec = ""
		for i=1,#mc_tf_menu do 
			formspec = formspec .. mc_tf_menu[i]
		end

		minetest.show_formspec(pname, "mc_tf:menu", formspec)
		return true
	end
end

-- The tutorial book for accessing tutorials
minetest.register_tool("mc_tf:tutorialbook" , {
	description = "Tutorial book",
	inventory_image = "tutorial_book.png",
	-- Left-click the tool activates the tutorial menu
	on_use = function (itemstack, user, pointed_thing)
        local pname = user:get_player_name()
		-- Check for shout privileges
		if check_perm(user) then
			show_tutorial_menu(user)
		end
	end,
	-- Destroy the book on_drop to keep things tidy
	on_drop = function (itemstack, dropper, pos)
		minetest.set_node(pos, {name="air"})
	end,
})

minetest.register_alias("tutorialbook", "mc_tf:tutorialbook")
tutorialbook = minetest.registered_aliases[tutorialbook] or tutorialbook

-- Processing the form from the menu
minetest.register_on_player_receive_fields(function(player, formname, fields)
	if string.sub(formname, 1, 5) ~= "mc_tf" then
		return false
	end

	local wait = os.clock()
	while os.clock() - wait < 0.05 do end --popups don't work without this

	-- Menu
	if fields.tutorials then
		local event = minetest.explode_textlist_event(fields.tutorials)
		if event.type == "CHG" then
			local textarea = mc_tf_menu[5]
			textarea = "textarea[5,0.2;7.8,8;text;;" .. descriptions[event.index - 1] .. "]"
			mc_tf_menu[5] = textarea
		end
	end
end)

-- Give the tutorialbook to any player who joins with shout privileges or take them away if they do not have shout
minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	if inv:contains_item("main", ItemStack("mc_tf:tutorialbook")) then
		if check_perm(player) then
			return
		else
			player:get_inventory():remove_item('main', 'mc_tf:tutorialbook')
		end
	else
		if check_perm(player) then
			player:get_inventory():add_item('main', 'mc_tf:tutorialbook')
		else
			return
		end
	end
end)

--    END TUTORIAL FUNCTIONS    --
----------------------------------