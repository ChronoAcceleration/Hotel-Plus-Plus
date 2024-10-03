-- DoorSounds.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local ScriptUtility = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local RoomHook = ScriptUtility.RoomHook:New()

RoomHook:On(
    "ServerRoomChanged",
    function(Room: Model): ()
        Room:WaitForChild("Door")
        
        local Door = Room:FindFirstChild('Door')
        Door.Door.Unlock.SoundId = "rbxassetid://7758131110"
        Door.Door.Bell.Volume = 1.3
        Door.Door.SlamOpen.SoundId = "rbxassetid://9113647192"
        Door.Door.SlamOpen.TimePosition = 0.2
        Door.Door.Fall.Volume = 0.5
    end
)