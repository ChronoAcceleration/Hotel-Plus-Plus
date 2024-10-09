-- PlantVariants.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local SyncHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/SyncHelper.lua"))()
local ScriptUtility = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local RoomHook = ScriptUtility.RoomHook:New()

-- In case DOORS adds new Plant Models.
local PlantNames = {
	"Potted_Plant"
}

local Plants = game:GetObjects("rbxassetid://122436475286095")[1]
local success, PlantTable = pcall(function()
	return Plants:GetChildren()
end)

if not success then
  return error("Failed to get Plants!")
end

RoomHook:On(
    "ServerRoomChanged",
    function(Room: Model): ()
        repeat
			task.wait()
		until Room:FindFirstChild("Assets")

		local Assets = Room:FindFirstChild("Assets")

		for _, v in Assets:GetChildren() do
			if table.find(PlantNames, v.Name) and v and v ~= nil then
				local ChosenPlant = SyncHelper:generateFullRandom(1, #PlantTable, tonumber(Room.Name))
				if ChosenPlant then
					if PlantTable[ChosenPlant]~=nil then
					    local NewPlant = PlantTable[ChosenPlant]:Clone()
						NewPlant.Parent = v.Parent
						NewPlant:PivotTo(v:GetPivot() * CFrame.fromEulerAnglesXYZ(0, math.random(-180, 180), 0))
						v:Destroy()
					else
						warn("Unknown error while finding a new plant variant inside plant table")
					    continue
					end
				else
				    warn("Unknown error while getting a new plant variant")
					continue
				end
			end
		end
        
    end
)