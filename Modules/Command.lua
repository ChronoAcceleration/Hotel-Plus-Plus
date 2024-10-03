-- Command.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.
-- Purely for debugging purposes.

local TextChatService = game:GetService("TextChatService")

local SlashCommands = {}
local Command = {}
Command.__index = Command

function Command.new(name, description, callback)
    local self = setmetatable({}, Command)
    self.name = name
    self.description = description
    self.callback = callback
    return self
end

local SlashCommandsModule = {}

function SlashCommandsModule:AddCommand(name, description, callback)
    local newCommand = Command.new(name, description, callback)
    SlashCommands[name:lower()] = newCommand
end

function SlashCommandsModule:RemoveCommand(name)
    SlashCommands[name:lower()] = nil
end

function SlashCommandsModule:SendMessage(message)
    TextChatService.TextChannels.RBXGeneral:SendAsync(message)
end

local function onChatMessage(textChatMessage)
    local message = textChatMessage.Text
    if message:sub(1, 1) ~= "?" then return end
    
    local args = message:split(" ")
    local commandName = args[1]:sub(2):lower()
    table.remove(args, 1) -- Remove the command name from args
    
    local command = SlashCommands[commandName]
    if command then
        command.callback(textChatMessage.TextSource, args)
    end
end

SlashCommandsModule:AddCommand("help", "Display all available commands", function(player, args)
    local helpMessage = "Available commands:\n"
    for name, command in pairs(SlashCommands) do
        helpMessage = helpMessage .. string.format("/%s - %s\n", name, command.description)
    end
    SlashCommandsModule:SendMessage(helpMessage)
end)

TextChatService.MessageReceived:Connect(onChatMessage)

--[[

Sample:

SlashCommandsModule:AddCommand("hello", "Say hello to the player", function(player, args)
    print("Hello, " .. player.Name .. "!")
end)

SlashCommandsModule:AddCommand("teleport", "Teleport to coordinates", function(player, args)
    if #args == 3 then
        local x, y, z = tonumber(args[1]), tonumber(args[2]), tonumber(args[3])
        if x and y and z then
            player.Character:SetPrimaryPartCFrame(CFrame.new(x, y, z))
        else
            print("Invalid coordinates")
        end
    else
        print("Usage: /teleport x y z")
    end
end)

--]]

return SlashCommandsModule