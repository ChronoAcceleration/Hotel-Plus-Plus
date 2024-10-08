-- BaseEntityRemux.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local RunService = game:GetService("RunService")
local ExecutorHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main/Modules/Executor.lua"))()
local ScriptUtility = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local EntityHook = ScriptUtility.EntityHook:New()

--[[

if ExecutorHelper:IsSolara() then
    return warn("Solara does not support entity remuxing!")
end

When I implement camerashake later, make sure to add this condition chrono. (Past Self)
Also make sure to remux ambush later.

--]]

local Players = game:GetService("Players")
local Player = Players.LocalPlayer -- this does not follow my standards, but i dont care lol
local Character = Player.Character or Player.CharacterAdded:Wait()
local RootPart = Character:WaitForChild("HumanoidRootPart")

EntityHook:On(
    "Rush",
    function(Rush: Model): ()
        if _G.DEBUG_HOTELPLUSPLUS then
            warn("Remuxing Rush entity!")
        end

        local RushNew = Rush.RushNew

        local RushFootsteps = RushNew.Footsteps
        local RushAmbient = RushNew.PlaySound
        RushFootsteps.PlaybackSpeed = 0.15
        RushAmbient.PlaybackSpeed = 0.05

        local CloseSound = RushFootsteps:Clone()
        CloseSound.PlaybackSpeed = 0.1
        CloseSound.Volume = 4.5
        CloseSound.Parent = RushNew
        CloseSound.Name = "CloseSound"
        CloseSound.RollOffMaxDistance = 90
        CloseSound.RollOffMinDistance = 0
        CloseSound.RollOffMode = Enum.RollOffMode.Linear
        CloseSound.SoundId = "rbxassetid://9112796831"
        CloseSound.Looped = true
        CloseSound:Play()
        
        for Index, SoundMod in CloseSound:GetChildren() do
            SoundMod:Destroy()
        end

        local RushEffects = RushNew.Attachment
        local RushBlack = RushEffects.Black
        local RushMainTrail = RushEffects.BlackTrail
        local RushFace = RushEffects.ParticleEmitter

        RushBlack.Size = NumberSequence.new(10)
        RushBlack.LockedToPart = false
        RushBlack.Enabled = true
        RushMainTrail.Size = NumberSequence.new(9)
        RushFace.Rotation = NumberRange.new(-5, 5)

        local DistanceConnection = RunService.Heartbeat:Connect(
            function(): ()
                local Distance = (RushNew.Position - RootPart.Position).Magnitude

                if Distance < 15 then
                    CloseSound.PlaybackSpeed = 0.1 + (15 - Distance) * 0.01
                else
                    CloseSound.PlaybackSpeed = 0.1
                end
            end
        )

        Rush.Destroying:Wait()
        DistanceConnection:Disconnect()
    end
)
