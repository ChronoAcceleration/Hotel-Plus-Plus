-- AmbientNew.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel +++ Project.

local Players = game:GetService("Players")
local SyncHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/SyncHelper.lua"))()

local Terrain = workspace:WaitForChild("Terrain")
local Ambience_Dark = workspace:WaitForChild("Ambience_Dark")
local Ambience_Hotel = workspace:WaitForChild("Ambience_Hotel")
local Ambience_Hotel2 = workspace:WaitForChild("Ambience_Hotel2")
Ambience_Dark.PlaybackSpeed = 1
Ambience_Hotel.PlaybackSpeed = 0.99
Ambience_Hotel2.PlaybackSpeed = 0.9

local AMBIENT_SOUNDS = {
    "rbxassetid://9112775414", -- Eerie Ambience 2 (SFX)
    "rbxassetid://9119386548" -- Spacecraft Engine Idle Constant Mild Roar 1 (SFX)
}

local SLAMS = {
    "rbxassetid://5468133300", -- Door Slam
    "rbxassetid://3908308607", -- Metal Door Slam
    "rbxassetid://9117180053", -- Oven Door Removed From Hinges 1 (SFX)
    "rbxassetid://7309106429" -- metal_door_hatch_close_slam_02
}

local Player = Players.LocalPlayer

local function createAmbientNoise(Table: table): Sound
    local AttachmentParent = Instance.new("Attachment", Terrain)
    local PlayerCharacter = Player.Character

    local function returnAmbiencePosition(Character, Distance)
        local RandomAngle = math.rad(math.random(0, 360))
        local OffsetX = math.cos(RandomAngle) * Distance
        local OffsetZ = math.sin(RandomAngle) * Distance
        local CharacterPosition = Character:GetPivot().Position
        return Vector3.new(CharacterPosition.X + OffsetX, CharacterPosition.Y, CharacterPosition.Z + OffsetZ)
    end

    local GlobalAmbienceDistance = math.random(2, 6)
    local AmbiencePosition = returnAmbiencePosition(PlayerCharacter, GlobalAmbienceDistance)
    AttachmentParent.Position = AmbiencePosition

    local RandomSoundIndex = SyncHelper:generateFullRandom(1, #Table, os.time())
    local LowGainChance = SyncHelper:generateFullRandom(1, 3, os.time())
    local HighGainChance = SyncHelper:generateFullRandom(-50, -80, os.time())
    local MidGainChance = SyncHelper:generateFullRandom(-80, -10, os.time())

    local Sound = Instance.new("Sound", AttachmentParent)
    Sound.SoundId = Table[RandomSoundIndex]
    Sound.Volume = 0.4

    local Equalizer = Instance.new("EqualizerSoundEffect", Sound)
    Equalizer.LowGain = LowGainChance
    Equalizer.MidGain = MidGainChance
    Equalizer.HighGain = HighGainChance

    Sound.Ended:Once(
        function(): ()
            AttachmentParent:Destroy()

            if _G.DEBUG_HOTELPLUSPLUSPLUS then
                warn("Deleted Ambient Sound!")
            end
        end
    )

    if _G.DEBUG_HOTELPLUSPLUSPLUS then
        warn("Ambient Sound Created: ", AttachmentParent.Position)
    end

    return Sound
end

while true do
    SyncHelper:deltaWait(
        SyncHelper:generateFullRandom(10, 30, os.time())
    )

    local TableChance = SyncHelper:generateFullRandom(1, 2, os.time())

    if TableChance == 1 then
        createAmbientNoise(AMBIENT_SOUNDS):Play()
    else
        createAmbientNoise(SLAMS):Play()
    end
end
