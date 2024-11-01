-- Event System Module
---@class ns
local ns = select(2, ...)
-- Event System Module
local EventSystem = {
    Mixin = {},  -- Will hold our mixin methods
    _framePools = {},  -- Optional: Pool frames by addon/module name
}

-- Mixin Implementation
function EventSystem.Mixin:RegisterEvent(event)
    self.events = self.events or {}
    
    local parent = self.parentInstance
    local handler = parent[event]
    
    if not handler then
        error(string.format("No handler method '%s' found in parent class", event))
        return self
    end
    
    self.events[event] = function(_, ...)
        handler(parent, ...)
    end
    
    self.frame:RegisterEvent(event)
    return self
end

function EventSystem.Mixin:RegisterEvents(...)
    for i = 1, select("#", ...) do
        self:RegisterEvent(select(i, ...))
    end
    return self
end

function EventSystem.Mixin:UnregisterEvent(event)
    if self.events and self.events[event] then
        self.frame:UnregisterEvent(event)
        self.events[event] = nil
    end
    return self
end

function EventSystem.Mixin:UnregisterAllEvents()
    if self.events then
        self.frame:UnregisterAllEvents()
        self.events = {}
    end
    return self
end

-- Core Creation Function
function EventSystem.CreateEventFrame(parentInstance)
    local frame = CreateFrame("Frame")
    local eventFrame = {
        frame = frame,
        events = {},
        parentInstance = parentInstance
    }
    
    Mixin(eventFrame, EventSystem.Mixin)
    
    frame:SetScript("OnEvent", function(_, event, ...)
        if eventFrame.events[event] then
            eventFrame.events[event](eventFrame, ...)
        end
    end)
    
    return eventFrame
end

-- Helper to make a class "EventCapable"
function EventSystem.EnableEvents(class)
    -- Add event delegation methods to the class prototype
    function class:InitializeEventDelegation()
        self.RegisterEvent = function(self, event)
            return self._eventHandler:RegisterEvent(event)
        end
        
        self.RegisterEvents = function(self, ...)
            return self._eventHandler:RegisterEvents(...)
        end
        
        self.UnregisterEvent = function(self, event)
            return self._eventHandler:UnregisterEvent(event)
        end
        
        self.UnregisterAllEvents = function(self)
            return self._eventHandler:UnregisterAllEvents()
        end
    end
    
    -- Modify the class's new method to include event handling
    local originalNew = class.new
    class.new = function(...)
        local instance = originalNew and originalNew(...) or {}
        instance._eventHandler = EventSystem.CreateEventFrame(instance)
        instance:InitializeEventDelegation()
        
        -- Call InitializeEvents if it exists
        if instance.InitializeEvents then
            instance:InitializeEvents()
        end
        
        return instance
    end
    
    return class
end

-- Example usage with multiple classes:

-- First Class
local PlayerTracker = {}
PlayerTracker.__index = PlayerTracker

-- Make PlayerTracker event-capable
EventSystem.EnableEvents(PlayerTracker)

function PlayerTracker:InitializeEvents()
    self:RegisterEvents(
        "PLAYER_ENTERING_WORLD",
        "PLAYER_LEAVING_WORLD"
    )
end

function PlayerTracker:PLAYER_ENTERING_WORLD(...)
    print("Player entered world")
end

function PlayerTracker:PLAYER_LEAVING_WORLD(...)
    print("Player left world")
end

-- Second Class
local CombatTracker = {}
CombatTracker.__index = CombatTracker

-- Make CombatTracker event-capable
EventSystem.EnableEvents(CombatTracker)

function CombatTracker:InitializeEvents()
    self:RegisterEvents(
        "PLAYER_REGEN_DISABLED",
        "PLAYER_REGEN_ENABLED"
    )
end

function CombatTracker:PLAYER_REGEN_DISABLED(...)
    print("Entered combat!")
end

function CombatTracker:PLAYER_REGEN_ENABLED(...)
    print("Left combat!")
end

-- Usage Example:
--[[
-- Create instances of both classes
local playerTracker = PlayerTracker.new()
local combatTracker = CombatTracker.new()

-- Each has their own event handlers but uses the same system
]]--


-- Example of a class that inherits from another event-capable class
local EnhancedPlayerTracker = {}
EnhancedPlayerTracker.__index = EnhancedPlayerTracker
setmetatable(EnhancedPlayerTracker, { __index = PlayerTracker })

-- Make EnhancedPlayerTracker event-capable
EventSystem.EnableEvents(EnhancedPlayerTracker)

function EnhancedPlayerTracker:InitializeEvents()
    -- Call parent's InitializeEvents
    PlayerTracker.InitializeEvents(self)
    -- Add our own events
    self:RegisterEvent("PLAYER_LEVEL_UP")
end

function EnhancedPlayerTracker:PLAYER_LEVEL_UP(...)
    print("Level up!")
end

-- Return the module
ns.EventSystem = EventSystem