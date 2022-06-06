---LocalToWorldPosition
---@param position table coordinates
---@return table localspace coordinates.
function Realm:LocalToWorldPosition(position)
    local pos = position
    pos.x = pos.x + self.StartPos.x
    pos.y = pos.y + self.StartPos.y
    pos.z = pos.z + self.StartPos.z
    return pos
end

---WorldToLocalPosition
---@param position table
---@return table worldspace coordinates
function Realm:WorldToLocalPosition(position)
    local pos = position
    pos.x = pos.x - self.StartPos.x
    pos.y = pos.y - self.StartPos.y
    pos.z = pos.z - self.StartPos.z
    return pos
end

function Realm.gridToWorldSpace(coords)
    local val = { x = 0, y = 0, z = 0 }
    val.x = (coords.x * 80) - Realm.const.worldSize
    val.y = (coords.y * 80) - Realm.const.worldSize
    val.z = (coords.z * 80) - Realm.const.worldSize
    return val
end

function Realm.worldToGridSpace(coords)
    Debug.logCoords(coords, "World Coords")
    local val = { x = 0, y = 0, z = 0 }
    val.x = (coords.x + Realm.const.worldSize) / 80
    val.y = (coords.y + Realm.const.worldSize) / 80
    val.z = (coords.z + Realm.const.worldSize) / 80
    Debug.logCoords(val, "Grid Coords")
    return val
end