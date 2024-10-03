-- Command.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.
-- Purely for debugging purposes.

local Players = game:GetService("Players")
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
    TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(message)
end

local function onChatMessage(textChatMessage)
    local message = textChatMessage.Text
    if message:sub(1, 1) ~= "?" then return end
    
    local args = message:split(" ")
    local commandName = args[1]:sub(2):lower()
    table.remove(args, 1) -- Remove the command name from args

    local commandUser = textChatMessage.TextSource
    local player = Players:FindFirstChild(commandUser)
    
    local command = SlashCommands[commandName]
    if command then
        command.callback(player, args)
    end
end

SlashCommandsModule:AddCommand("help", "Display all available commands", function(player, args)
    local helpMessage = "Available commands:\n"
    for name, command in pairs(SlashCommands) do
        helpMessage = helpMessage .. string.format("?%s - %s\n", name, command.description)
    end
    SlashCommandsModule:SendMessage(helpMessage)
end)

local MessageCooldown = {}
TextChatService.OnIncomingMessage = function(TextChatMessage: TextChatMessage): ()
    if MessageCooldown[TextChatMessage.MessageId] then return end
    MessageCooldown[TextChatMessage.MessageId] = true

    task.delay(
        0.5,
        function(): ()
            MessageCooldown[TextChatMessage.MessageId] = nil
        end
    )

    onChatMessage(TextChatMessage)
end

return SlashCommandsModule