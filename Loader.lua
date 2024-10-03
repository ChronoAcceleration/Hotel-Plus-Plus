-- Loader.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel +++ Project.

--[[

Globals:
_G.DEBUG_HOTELPLUSPLUS (self explanatory lol)

--]]

_G.DEBUG_HOTELPLUSPLUS = true -- Debugging (Since its in a beta lol)

local function loadCode(Path: string, NewThread: boolean): ()
    local BASE_URL = "https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main"
    local URL = string.format("%s/%s", BASE_URL, Path)
    local Raw = game:HttpGet(URL)

    if NewThread then
        task.spawn(loadstring(Raw, "Hotel++"))
    else
        loadstring(Raw, "Hotel++")()
    end
end

loadCode("Backend/NodeConverter.lua")
loadCode("Backend/MischeviousLight.lua")

loadCode("QOL/Ambient.lua", true)  -- (Includes While Loop)
loadCode("QOL/Daytime.lua")
loadCode("QOL/DoorSounds.lua", true)

loadCode("Entities/BaseEntityRemux.lua")