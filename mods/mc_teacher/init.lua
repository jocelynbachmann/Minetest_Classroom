minetest_classroom.classrooms = minetest.get_mod_storage()

-- Required MT version
assert(minetest.features.formspec_version_element, "Minetest 5.1 or later is required")

-- Internationalisaton
minetest_classroom.S = minetest.get_translator("minetest_classroom")
minetest_classroom.FS = function(...)
    return minetest.formspec_escape(minetest_classroom.S(...))
end

-- Source files
dofile(minetest.get_modpath("mc_teacher") .. "/api.lua")
dofile(minetest.get_modpath("mc_teacher") .. "/gui_dash.lua")
dofile(minetest.get_modpath("mc_teacher") .. "/gui_group.lua")
dofile(minetest.get_modpath("mc_teacher") .. "/freeze.lua")
dofile(minetest.get_modpath("mc_teacher") .. "/actions.lua")

-- Privileges
minetest.register_privilege("teacher", {
    give_to_singleplayer = false
})

-- Hooks needed to make api.lua testable
minetest_classroom.get_connected_players = minetest.get_connected_players
minetest_classroom.get_player_by_name = minetest.get_player_by_name
minetest_classroom.check_player_privs = minetest.check_player_privs

minetest_classroom.load_from(minetest_classroom.classrooms)

function minetest_classroom.save()
    minetest_classroom.save_to(minetest_classroom.classrooms)
end

minetest.register_on_shutdown(minetest_classroom.save)

schematicManager.registerSchematicPath("vancouver_osm", minetest.get_modpath("mc_teacher") .. "/maps/vancouver_osm")
schematicManager.registerSchematicPath("MKRF512_all", minetest.get_modpath("mc_teacher") .. "/maps/MKRF512_all")
schematicManager.registerSchematicPath("MKRF512_aspect", minetest.get_modpath("mc_teacher") .. "/maps/MKRF512_aspect")
schematicManager.registerSchematicPath("MKRF512_dtm", minetest.get_modpath("mc_teacher") .. "/maps/MKRF512_dtm")
schematicManager.registerSchematicPath("MKRF512_hillshade", minetest.get_modpath("mc_teacher") .. "/maps/MKRF512_hillshade")
schematicManager.registerSchematicPath("MKRF512_slope", minetest.get_modpath("mc_teacher") .. "/maps/MKRF512_slope")
schematicManager.registerSchematicPath("MKRF512_tpi", minetest.get_modpath("mc_teacher") .. "/maps/MKRF512_tpi")


--[[
Realm.RegisterOnCreateCallback(function(realm)
    minetest_classroom.create_group(realm.Name)
end)

Realm.RegisterOnLeaveCallback(function(realm)
    minetest_classroom.remove_group(realm.Name)
end)

Realm.RegisterOnJoinCallback(function(realm, player)
    minetest_classroom.add_student_to_group(realm.Name .. " Realm Group", player:get_player_name())
end)

Realm.RegisterOnLeaveCallback(function(realm, player)
    minetest_classroom.remove_student_from_group(realm.Name .. " Realm Group", player:get_player_name())
end)
--]]