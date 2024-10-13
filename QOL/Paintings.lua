-- Paintings.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local SyncHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/SyncHelper.lua"))()

local SyncSeed = SyncHelper:returnSeed()
local SyncRandom = Random.new(SyncSeed)

local ScriptUtility = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local RoomHook = ScriptUtility.RoomHook:New()

local Player = game:GetService("Players").LocalPlayer
local Character = Player.Character

local PlayerGui = Player.PlayerGui
local MainUI = PlayerGui.MainUI
local MainFrame = MainUI.MainFrame

local NormalPaintingWeight = 50 -- Should be higher than 20

-- Name of the Painting Models.
local PaintingNames = {
	"Painting_Small",
	"Painting_Big",
	"Painting_VeryBig",
	"Painting_Tall"
}

local Paintings = {
	{
		["ID"]="DogDay",
		["CanBeOn"]={
			"Painting_Small",
			"Painting_Big"
		},
		["PaintingMessage"]="This painting is titled 'Chrono'. You have no idea why.",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="https://github.com/ChronoAcceleration/Hotel-Plus-Plus/blob/main/QOL/PaintingAssets/Chrono_PAINTING.png?raw=true",
		["Weight"]=0.2
	},
	{
		["ID"]="CatNap",
		["CanBeOn"]={
			"Painting_Small",
			"Painting_Big"
		},
		["PaintingMessage"]="This painting is titled 'Geo'. You have no idea why.",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="https://github.com/ChronoAcceleration/Hotel-Plus-Plus/blob/main/QOL/PaintingAssets/Geodude_PAINTING.png?raw=true",
		["Weight"]=0.2
	},
	{
		["ID"]="Cat",
		["CanBeOn"]={
			"Painting_Big",
			"Painting_VeryBig"
		},
		["PaintingMessage"]="This painting is titled 'Cat'",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="rbxassetid://15802357974",
		["Weight"]=2
	},
	{
		["ID"]="Random_Scribbles",
		["CanBeOn"]={
			"Painting_Big",
			"Painting_VeryBig"
		},
		["PaintingMessage"]="This painting is titled 'Scribbling'",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="rbxassetid://15802362846",
		["Weight"]=1.4
	},
	{
		["ID"]="Rooms",
		["CanBeOn"]={
			"Painting_Big",
			"Painting_VeryBig"
		},
		["PaintingMessage"]="This painting is titled 'A Old Place'. It looks oddly familiar to you...",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="rbxassetid://15802243628",
		["Weight"]=0.785
	},
	{
		["ID"]="Capybara",
		["CanBeOn"]={
			"Painting_Big",
			"Painting_VeryBig"
		},
		["PaintingMessage"]="This painting is titled 'A Capybara without Drip'",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="rbxassetid://15802353245",
		["Weight"]=2
	},
	{
		["ID"]="Chicken",
		["CanBeOn"]={
			"Painting_VeryBig",
			"Painting_Small",
			"Painting_Tall"
		},
		["PaintingMessage"]="This is a Chicken.",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main/QOL/PaintingAssets/ChickenYummy.png",
		["Weight"]=2.4
	},
	{
		["ID"]="Sunset",
		["CanBeOn"]={
			"Painting_VeryBig",
			"Painting_Big",
			"Painting_Small"
		},
		["PaintingMessage"]="This painting is titled 'Nice Sunset'",
		["PaintingMessageDuration"]=5,
		["PaintingImage"]="http://www.roblox.com/asset/?id=135617544426029",
		["Weight"]=2
	}
}

-- Load Images

function GetGithubImage(URL, Name): string
	if not isfile(Name..".png") then -- This will prevent it from reloading even if its loaded.
		writefile(Name..".png", game:HttpGet(URL))
	end

	return (getcustomasset or getsynasset)(Name..".png")
end

for _, PaintingTable in pairs(Paintings) do
	local PaintingImage = PaintingTable.PaintingImage
	if string.sub(PaintingImage, 1, 5):lower() == "https" then -- If the ID is a https
		PaintingTable.PaintingImage = GetGithubImage(PaintingImage, PaintingTable.ID)
	end
end

-- Painting Weight

function GetPaintingByWeight(): {}
	local totalWeight = 0

	for _, Painting in pairs(Paintings) do
		totalWeight = totalWeight + Painting.Weight
	end

	totalWeight += NormalPaintingWeight -- Normal Painting Weight so we dont always get custom paintings

	local randomWeight = SyncRandom:NextNumber() * totalWeight
	local cumulativeWeight = 0

	for _, Painting in pairs(Paintings) do
		cumulativeWeight = cumulativeWeight + Painting.Weight
		if randomWeight <= cumulativeWeight then
			return Painting
		end
	end

	return nil
end

-- Painting Functions

function PaintingCaption(Message, Duration): ()
	if MainUI:FindFirstChild("LiveCaption") then
		MainUI:FindFirstChild("LiveCaption"):Destroy()
	end
	local CaptionFrame = MainFrame.Caption:Clone();
	CaptionFrame.Name = "LiveCaption";
	CaptionFrame.Visible = true;
	CaptionFrame.Text = Message;
	CaptionFrame.Parent = MainUI;
	if not Duration then
		Duration = 7;
	end;
	game:GetService("TweenService"):Create(CaptionFrame,	TweenInfo.new(Duration, Enum.EasingStyle.Exponential, Enum.EasingDirection.In), {
		BackgroundTransparency = 1, 
		TextTransparency = 1, 
		TextStrokeTransparency = 2
	}):Play();
	game:GetService("TweenService"):Create(CaptionFrame, TweenInfo.new(1.5, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out), {
		BackgroundColor3 = Color3.new(0, 0, 0)
	}):Play();
	game.Debris:AddItem(CaptionFrame, Duration + 10);
end

function LoadPaintingTableOnPainting(PaintingModel: Model, PaintingTable): ()
	if PaintingModel:GetAttribute("IsCustom") then
		return
	end
	PaintingModel:SetAttribute("IsCustom", true)
	local Canvas = PaintingModel.Canvas
	local ImageLabel = Canvas.SurfaceGui.ImageLabel

	ImageLabel.Image = PaintingTable["PaintingImage"]

	local Prompt = PaintingModel:FindFirstChildOfClass("ProximityPrompt")
	local NewPrompt = Prompt:Clone()
	NewPrompt.Parent = PaintingModel
	NewPrompt.Triggered:Connect(function()
		PaintingCaption(PaintingTable["PaintingMessage"], PaintingTable["PaintingMessageDuration"])
	end)
	Prompt:Destroy()
end

function CanLoadPaintingTableOnPaintingModel(t, m)
	if table.find(t["CanBeOn"], m.Name) then
		return true
	end
	return false
end

function IsPaintingTable(t)
	if t["ID"] and t["PaintingImage"] and t["PaintingMessage"] then
		return true
	end
	return false
end

RoomHook:On(
	"ServerRoomChanged",
	function(Room: Model): ()
		repeat
			task.wait()
		until Room:FindFirstChild("Assets")

		local Assets = Room:FindFirstChild("Assets")

		for _, v in Assets:GetChildren() do
			if table.find(PaintingNames, v.Name) and v and v ~= nil then
				local Painting = GetPaintingByWeight()

				if Painting and Painting ~= nil then
					if IsPaintingTable(Painting) then
						if CanLoadPaintingTableOnPaintingModel(Painting, v) then
							LoadPaintingTableOnPainting(v, Painting)
						else
							warn("Could not load painting because its ignored in table thingy and because "..tostring(table.unpack(Painting["CanBeOn"])).. " Is not like named after ".. v.Name)
						end
					end
				end
			end
		end

	end
)