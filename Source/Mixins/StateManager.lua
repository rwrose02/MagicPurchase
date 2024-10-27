---@class ns
ns = select(2, ...)


local StateManager = {}
StateManager.__index = StateManager

function StateManager:new()
    local self = setmetatable({}, StateManager)
    self.value = nil
    self.locked = false -- Lock flag to control changes
    return self
end

function StateManager:setValue(newValue)
    if self.locked then
        print("State is locked. Cannot set itemid.")
        return false
    end
    self.value = newValue
    return true
end

function StateManager:getValue()
    return self.value
end

function StateManager:lock()
    self.locked = true
    -- print("State locked.")
end

function StateManager:unlock()
    self.locked = false
    -- print("State unlocked.")
end

function StateManager:getState()
    return self.locked
end
function StateManager:tostring()
    return tostring(self.value)
end

ns.StateManager = StateManager
