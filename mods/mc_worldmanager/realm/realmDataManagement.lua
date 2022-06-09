---@private
---Loads the persistant global data for the realm class
---@return void
function Realm.LoadDataFromStorage()
    Realm.realmCount = tonumber(mc_worldManager.storage:get_string("realmCount"))
    if Realm.realmCount == nil then
        Realm.realmCount = 0
    end

    Realm.lastRealmPosition = minetest.deserialize(mc_worldManager.storage:get_string("realmLastPosition"))
    if Realm.lastRealmPosition == nil then
        Realm.lastRealmPosition = { x = 0, y = 0, z = 0 }
    end

    Realm.maxRealmSize = minetest.deserialize(mc_worldManager.storage:get_string("realmMaxSize"))
    if Realm.maxRealmSize == nil then
        Realm.maxRealmSize = { x = 0, y = 0, z = 0 }
    end

    Realm.EmptyChunks = minetest.deserialize(mc_worldManager.storage:get_string("realmEmptyChunks"))
    if Realm.EmptyChunks == nil then
        Realm.EmptyChunks = {}
    end

    local tmpRealmDict = minetest.deserialize(mc_worldManager.storage:get_string("realmDict"))
    if tmpRealmDict == nil then
        tmpRealmDict = {}
    end

    for key, realm in pairs(tmpRealmDict) do
        Realm:Restore(realm)
    end
end

---@private
---Saves the persistant global data for the realm class
---@return void
function Realm.SaveDataToStorage ()
    mc_worldManager.storage:set_string("realmDict", minetest.serialize(Realm.realmDict))
    mc_worldManager.storage:set_string("realmCount", tostring(Realm.realmCount))

    mc_worldManager.storage:set_string("realmLastPosition", minetest.serialize(Realm.lastRealmPosition))
    mc_worldManager.storage:set_string("realmMaxSize", minetest.serialize(Realm.maxRealmSize))
    mc_worldManager.storage:set_string("realmMaxSize", minetest.serialize(Realm.maxRealmSize))
    mc_worldManager.storage:set_string("realmEmptyChunks", minetest.serialize(Realm.EmptyChunks))
end

---@private
---Restores a dimension based on supplied parameters. Do not use this method to make new dimensions; use Realm:New() instead
---@return self
function Realm:Restore(template)

    --We are sanitizing input to help stop shenanigans from happening
    local this = {
        Name = tostring(template.Name),
        ID = tonumber(template.ID),
        StartPos = { x = template.StartPos.x, y = template.StartPos.y, z = template.StartPos.z },
        EndPos = { x = template.EndPos.x, y = template.EndPos.y, z = template.EndPos.z },
        SpawnPoint = { x = template.SpawnPoint.x, y = template.SpawnPoint.y, z = template.SpawnPoint.z },
        PlayerJoinTable = template.PlayerJoinTable,
        PlayerLeaveTable = template.PlayerLeaveTable,
        RealmDeleteTable = template.RealmDeleteTable,
        MetaStorage = template.MetaStorage
    }

    --Reconstruct the class metatables
    setmetatable(this, self)

    --Insert ourselves into the realmDict
    table.insert(Realm.realmDict, this.ID, this)
    return this
end

function Realm:set_string(key, value)
    self.MetaStorage[key] = value
end

function Realm:get_string(key)
    return self.MetaStorage[key]
end

function Realm:set_int(key, value)
    self.MetaStorage[key] = tostring(value)
end

function Realm:get_int(key)
    return tonumber(self.MetaStorage[key])
end