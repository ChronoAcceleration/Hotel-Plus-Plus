-- Loader.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel +++ Project.

--[[

Globals:
_G.DEBUG_HOTELPLUSPLUSPLUS (self explanatory lol)

--]]

local function loadCode(URL: string, NewThread: boolean): ()
    local Raw = game:HttpGet(URL)

    if NewThread then
        task.spawn(loadstring(Raw, "Hotel++"))
    else
        loadstring(Raw, "Hotel++")()
    end
end

loadCode("https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main/Backend/NodeConverter.lua") -- Backend/NodeConverter.lua
loadCode("https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main/QOL/Ambient.lua", true)  -- QOL/Ambient.lua (Includes While Loop)
