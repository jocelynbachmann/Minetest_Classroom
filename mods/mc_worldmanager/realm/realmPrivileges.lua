Realm.whitelistedPrivs = {}
local worldRealmPrivWhitelist = minetest.get_worldpath() .. "/realmPrivilegeWhitelist.conf"
local modRealmPrivWhitelist = mc_worldManager.path .. "/realmPrivilegeWhitelist.conf"

function Realm.SetPrivWhitelist(file)
    local settings = Settings(file)

    for k, v in pairs(Realm.whitelistedPrivs) do
        settings:set_bool(tostring(k), v)
    end

    local success = settings:write()
    return success
end

function Realm.GetPrivWhitelist(file)
    local settings = Settings(file)
    local names = settings:get_names()

    for index, key in pairs(names) do
        local value = settings:get_bool(key)

        if (value == true) then
            Realm.whitelistedPrivs[key] = true
        end
    end
end

function Realm.AugmentPrivWhitelist(sourceFile, destFile)
    local source = Settings(sourceFile)
    local sourceKeys = source:get_names()
    local dest = Settings(destFile)
    
    for _,key in pairs(sourceKeys) do
        if not dest:get(tostring(key)) then
            local val = source:get_bool(tostring(key))
            dest:set_bool(tostring(key), val)
        end
    end

    local success = dest:write()
    return success
end

function Realm.LoadPrivModDefaults()
    Realm.GetPrivWhitelist(modRealmPrivWhitelist)
    Realm.SetPrivWhitelist(worldRealmPrivWhitelist)
end

function Realm:UpdateRealmPrivilege(privilegeTable)
    local invalidPrivs = {}

    if (self.Permissions == nil) then
        self.Permissions = {}
    end

    for k, v in pairs(privilegeTable) do
        if (v == true or v == "true") then
            if (Realm.whitelistedPrivs[k] ~= true) then
                table.insert(invalidPrivs, k)
                Debug.log(tostring(k))
            else
                self.Permissions[k] = true
            end
        else
            self.Permissions[k] = nil
        end
    end

    if (#invalidPrivs > 0) then
        return false, invalidPrivs
    end

    return true, invalidPrivs
end

function Realm:ApplyPrivileges(player)
    local name = player:get_player_name()
    local pmeta = player:get_meta()

    -- Revoke all privileges
    local privs = {} --minetest.get_player_privs(name) 

    local universalPrivs = minetest.deserialize(pmeta:get_string("universalPrivs")) or {}
    local realmPrivs = self.Permissions or {}
    local overridePrivs = self.PermissionsOverride and self.PermissionsOverride[name] or {}

    -- Create list of privs to check
    local privsToCheck = {}
    for k,_ in pairs(universalPrivs) do
        privsToCheck[k] = true
    end
    for k,_ in pairs(realmPrivs) do
        privsToCheck[k] = true
    end
    for k,_ in pairs(overridePrivs) do
        privsToCheck[k] = true
    end

    -- Perform priv checks
    for k,_ in pairs(privsToCheck) do
        if (overridePrivs[k] == false) or (overridePrivs[k] == nil and ((universalPrivs[k] == false) or (universalPrivs[k] == nil and realmPrivs ~= true))) then
            privs[k] = false
        elseif (overridePrivs[k] == true) or (universalPrivs[k] == nil and realmPrivs == true) then
            privs[k] = (Realm.whitelistedPrivs[k] == true)
        elseif (realmPrivs ~= false) then
            privs[k] = true
        else
            -- TODO: add check to see if universal privs take precedence
            privs[k] = true
        end
    end

    minetest.log(minetest.serialize(privs))

    -- debug
    --minetest.log("universal: "..minetest.serialize(universalPrivs))
    --minetest.log("realm: "..minetest.serialize(realmPrivs))
    --minetest.log("override: "..minetest.serialize(overridePrivs))
    --minetest.log("FINAL: "..minetest.serialize(privs))

    --[[if (self.PermissionsOverride and self.PermissionsOverride[name]) then
        for k, v in pairs(self.PermissionsOverride[name]) do
            if (Realm.whitelistedPrivs[k] == true) then
                privs[k] = v
            end
        end
    end

    -- Add the universal privileges that a player has access to
    local universalPrivs = minetest.deserialize(pmeta:get_string("universalPrivs")) or {}
    for k, v in pairs(universalPrivs) do
        --minetest.log(minetest.serialize(k)..": "..minetest.serialize(v))
        privs[k] = v
    end

    -- Add the realm privileges for any given realm, as long as universal privileges are not denied
    if (self.Permissions ~= nil) then
        for k, v in pairs(self.Permissions) do
            if (Realm.whitelistedPrivs[k] == true and universalPrivs[k] ~= false) then
                privs[k] = v
            end
        end
    end

    -- Remove overridden privileges for the player in the current realm
    if (self.PermissionsOverride and self.PermissionsOverride[name]) then
        for k, v in pairs(self.PermissionsOverride[name]) do
            if (Realm.whitelistedPrivs[k] == true) then
                privs[k] = v
            end
        end
    end]]

    -- Ensure privs set to false do not get added
    for k, v in pairs(privs) do
        if v == false then
            privs[k] = nil
        end
    end
    minetest.set_player_privs(name, privs)
end

if (mc_core.fileExists(worldRealmPrivWhitelist)) then
    Realm.AugmentPrivWhitelist(modRealmPrivWhitelist, worldRealmPrivWhitelist)
    Realm.GetPrivWhitelist(worldRealmPrivWhitelist)
else
    Debug.log("No realm permissions whitelist found, load mod defaults...")
    Realm.LoadPrivModDefaults()
end

Debug.logTable("whitelisted Privs", Realm.whitelistedPrivs)

