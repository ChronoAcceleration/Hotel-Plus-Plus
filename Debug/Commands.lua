-- Commands.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.
-- Purely for debugging purposes. (this is ugly!)

if not _G.DEBUG_HOTELPLUSPLUS then
    return
end

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Commands = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main/Modules/Command.lua"))()

task.spawn(
    function(): ()
        Commands:AddCommand("mischevious", "Toggle Mischevious Light", function(_, ARGUMENTS)
            if #ARGUMENTS ~= 0 then
                _G.DO_RED_GUY = ARGUMENTS[1] == "true"
                return Commands:SendMessage("Toggle: " .. tostring(_G.DO_RED_GUY))
            end
        
            _G.DO_RED_GUY = not _G.DO_RED_GUY
            Commands:SendMessage("Toggle: " .. tostring(_G.DO_RED_GUY))
        end)
    end
)

task.spawn(
    function(): ()
        Commands:AddCommand("suicide", "Kill yourself, in the name of DEBUGGING!", function(PLAYER, ARGUMENTS)
            local FixatedArgument = ARGUMENTS[1] or "false"
            local BooleanArgument = FixatedArgument == "true"
            local Type = ARGUMENTS[2] or "Blue"
        
            local Character = PLAYER.Character
            local Humanoid = Character.Humanoid
        
            local function runGuidingLight(Text: table, Type: string): ()
                local RemotesFolder = ReplicatedStorage.RemotesFolder
                local DeathHint = RemotesFolder.DeathHint
            
                firesignal(DeathHint.OnClientEvent, Text, Type)
            end
            
            local function changeDeathCause(Cause: string, Player: Player): ()
                local GameStats = ReplicatedStorage.GameStats
                local PlayerStats = GameStats[string.format("Player_%s", Player.Name)]
                local Total = PlayerStats.Total
                local DeathCause = Total.DeathCause
            
                DeathCause.Value = Cause
                Humanoid:TakeDamage(100)
            end
        
            changeDeathCause("Suicide", PLAYER)
            
            if BooleanArgument then
                runGuidingLight(
                    {
                        "Hello.",
                        "It looks like you killed yourself.",
                        "Unfortunate.",
                        "Okay, goodbye now."
                    },
                    Type
                )
            else
                runGuidingLight(
                    {
                        string.rep(".\n", 50):sub(1, -2)
                    },
                    Type
                )
            end
        end)
    end
)