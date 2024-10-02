-- NodeConverter.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local CurrentRooms = workspace:WaitForChild("CurrentRooms")

local function convertToLegacy(Room: Model): ()
    if Room:HasTag("Converted") then
        return nil
    end

    local PathfindNodes = Room:WaitForChild("PathfindNodes", 10)

    if not PathfindNodes then
        warn("PathfindNodes not found in room: " .. Room.Name)
        return nil
    end

    local LegacyNodes = PathfindNodes:Clone()
    LegacyNodes.Name = "Nodes"
    LegacyNodes.Parent = Room
    Room:AddTag("Converted")

    if _G.DEBUG_HOTELPLUSPLUS then
        warn("Converted PathfindNodes to Nodes in room: " .. Room.Name)
    end
end

CurrentRooms.ChildAdded:Connect(
    function(Room: Model): ()
        convertToLegacy(Room)
    end
)

for Index, Room in CurrentRooms:GetChildren() do
    convertToLegacy(Room)
end
