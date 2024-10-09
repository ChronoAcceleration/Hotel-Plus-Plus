-- PlusLightModule.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

--[[

In Order to assure solara support, this script must go the burden of being ugly asf.
Unfortunate decompiled code... LSPLSAHSHjkdghjrkhgdrtijghqwkihiUHIKUJDFLHFG IM KILLING YOUUUU RAHHHHHHHHHHHHHHHHHHHHHH

THIS IS NOT MY CODE DO NOT HOLD ME ACCOUNTABLE FOR IT GSC OR ILL KILL YOU!!

--]]

local LightingModule = {};
local ShakeModule = nil;
local Replicated = game:GetService("ReplicatedStorage")
local Workspace = workspace
local CurrentRooms = Workspace.CurrentRooms

function LightingModule.init(shakeModuleRef)
    ShakeModule = shakeModuleRef;
end

local TweenService = game:GetService("TweenService");
local ShardModels = Replicated.Shards:GetChildren();

function LightingModule.shatter(room, percentToShatter, shatterSpeed, randomSeed)
    local targetRoom = room;
    local shatterPercentage = percentToShatter;
    local speed = shatterSpeed;
    local seed = randomSeed;

    task.spawn(function()
        if typeof(targetRoom) ~= "Instance" then
            if typeof(targetRoom) == "number" then
                targetRoom = CurrentRooms:FindFirstChild(targetRoom);
            else
                targetRoom = nil;
            end
        end

        if targetRoom == nil then
            warn("Cannot find room");
        end

        if targetRoom:GetAttribute("CannotShatter") then
            return;
        end

        if not shatterPercentage then
            shatterPercentage = 100;
        end

        if not speed then
            speed = 60;
        end

        if not seed then
            seed = Random.new(tick());
        end

        local roomLength = (targetRoom.RoomEntrance.Position - targetRoom.RoomExit.Position).Magnitude / speed;
        local lightFixtures = {};

        for _, object in pairs(targetRoom:GetDescendants()) do
            if object:IsA("Model") and (object.Name == "LightStand" or object.Name == "Chandelier") then
                table.insert(lightFixtures, object);
            end
        end

        shatterPercentage = math.min(shatterPercentage, #lightFixtures);
        local totalFixtures = #lightFixtures;

        if shatterPercentage < 50 then
            local selectedFixtures = {};
            for i = 1, 100 do
                local randomFixture = lightFixtures[seed:NextInteger(1, #lightFixtures)];
                local isUnique = true;
                for _, selectedFixture in pairs(selectedFixtures) do
                    if selectedFixture == randomFixture then
                        isUnique = false;
                    end
                end
                if isUnique then
                    table.insert(selectedFixtures, randomFixture);
                end
                if shatterPercentage <= #selectedFixtures then
                    break;
                end
            end
            lightFixtures = selectedFixtures;
        end

        for _, fixture in pairs(lightFixtures) do
            for _, descendant in pairs(fixture:GetDescendants()) do
                if descendant:IsA("Light") then
                    descendant:SetAttribute("OriginalBrightness", descendant.Brightness);
                end
            end
        end

        if shatterPercentage > 5 then
            targetRoom:SetAttribute("Ambient", Color3.new(0, 0, 0));
        end

        for _, fixture in pairs(lightFixtures) do
            local shatterDelay = (targetRoom.RoomEntrance.Position - fixture.PrimaryPart.Position).Magnitude / speed + seed:NextInteger(-10, 10) / 50;
            local chargeDuration = seed:NextInteger(5, 20) / 100;

            if shatterPercentage <= 5 and shatterPercentage < totalFixtures then
                shatterDelay = seed:NextInteger(5, 300) / 10;
                chargeDuration = seed:NextInteger(5, 70) / 100;
            end

            task.delay(shatterDelay, function()
                local chargeSound = game:GetService("ReplicatedStorage").Sounds.BulbCharge:Clone();
                chargeSound.Parent = fixture.PrimaryPart;
                chargeSound.Pitch = chargeSound.Pitch + math.random(-140, 140) / 800;
                chargeSound:Play();
                game.Debris:AddItem(chargeSound, 2);

                local neonPart = fixture:FindFirstChild("Neon", true);
                if neonPart then
                    TweenService:Create(neonPart, TweenInfo.new(chargeDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                        Transparency = 0, 
                        Color = Color3.new(1, 1, 1)
                    });
                end

                for _, descendant in pairs(fixture:GetDescendants()) do
                    if descendant:IsA("Light") then
                        TweenService:Create(descendant, TweenInfo.new(chargeDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                            Brightness = descendant:GetAttribute("OriginalBrightness") * 2
                        }):Play();
                    end
                end

                task.wait(chargeDuration + 0.01);

                if neonPart then
                    neonPart.Transparency = 1;
                end

                for _, descendant in pairs(fixture:GetDescendants()) do
                    if descendant:IsA("Light") then
                        TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Brightness = 0
                        }):Play();
                    end
                end

                chargeSound:Stop();
                local breakSound = game:GetService("ReplicatedStorage").Sounds.BulbBreak:Clone();
                breakSound.Parent = fixture.PrimaryPart;
                breakSound.Pitch = breakSound.Pitch + math.random(-140, 140) / 1000;
                breakSound.TimePosition = math.random(0, 7) * 3;
                breakSound:Play();
                game.Debris:AddItem(breakSound, 2);

                pcall(function()
                    ShakeModule.shakerel(fixture.PrimaryPart.Position, 2, 12, 0, 0.4, Vector3.new(0, 0, 0));
                end);

                for i = 1, 4 do
                    local shardModel = ShardModels[math.random(1, #ShardModels)]:Clone();
                    shardModel.CFrame = fixture.PrimaryPart.CFrame + Vector3.new(math.random(-3, 3) / 5, math.random(-3, 3) / 5, math.random(-3, 3) / 5);
                    shardModel.Velocity = Vector3.new(math.random(-6, 6), math.random(-6, 6), math.random(-6, 6));
                    shardModel.RotVelocity = Vector3.new(math.random(-3, 3) / 5, math.random(-3, 3) / 5, math.random(-3, 3) / 5);
                    shardModel.Parent = workspace.CurrentCamera;
                    game.Debris:AddItem(shardModel, math.random(20, 35));
                end
            end);
        end

        if totalFixtures <= shatterPercentage then
            for _, descendant in pairs(targetRoom:GetDescendants()) do
                if descendant:IsA("Light") and descendant:GetAttribute("ForceOn") ~= true then
                    if descendant.Parent.Name ~= "LightBase" and descendant.Parent.Name ~= "LightPanel" and descendant.Parent.Name ~= "Log" then
                        local delay = 2;
                        local parentPart = descendant:FindFirstAncestorWhichIsA("BasePart");
                        if parentPart then
                            delay = (targetRoom.RoomEntrance.Position - parentPart.Position).Magnitude / speed;
                        end
                        task.delay(delay, function()
                            descendant.Enabled = false;
                            TweenService:Create(descendant, TweenInfo.new(roomLength / 2, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                                Brightness = 0
                            }):Play();
                        end);
                    end
                elseif descendant:IsA("ParticleEmitter") and descendant:GetAttribute("Light") == true then
                    local delay = 2;
                    local parentPart = descendant:FindFirstAncestorWhichIsA("BasePart");
                    if parentPart then
                        delay = (targetRoom.RoomEntrance.Position - parentPart.Position).Magnitude / speed;
                    end
                    task.delay(delay, function()
                        descendant.Enabled = false;
                    end);
                elseif descendant:IsA("Sound") and descendant:GetAttribute("Light") == true then
                    local delay = 2;
                    local parentPart = descendant:FindFirstAncestorWhichIsA("BasePart");
                    if parentPart then
                        delay = (targetRoom.RoomEntrance.Position - parentPart.Position).Magnitude / speed;
                    end
                    task.delay(delay, function()
                        descendant.Volume = 0;
                        descendant:Stop();
                    end);
                end
            end
        end

        task.wait(roomLength / 2);
        if shatterPercentage >= 5 then
            TweenService:Create(game.Lighting, TweenInfo.new(roomLength / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                Ambient = Color3.new(0, 0, 0)
            }):Play();
            targetRoom:SetAttribute("Ambient", Color3.new(0, 0, 0));
        end
        targetRoom:SetAttribute("CannotFlicker", true)
        targetRoom:SetAttribute("CannotShatter", true)
    end);
end

function LightingModule.flicker(room, flickerDuration, percentToFlicker, randomSeed)
    local targetRoom = room;
    local flickerPercentage = percentToFlicker;
    local seed = randomSeed;

    task.spawn(function()
        if typeof(targetRoom) ~= "Instance" then
            if typeof(targetRoom) == "number" then
                targetRoom = workspace.CurrentRooms:FindFirstChild(targetRoom);
            else
                targetRoom = nil;
            end
        end

        if targetRoom == nil then
            warn("Cannot find room");
        end

        if targetRoom:GetAttribute("CannotFlicker") then
            return;
        end

        if not flickerPercentage then
            flickerPercentage = 100;
        end

        if not seed then
            seed = Random.new(tick());
        end

        local lightFixtures = {};
        for _, object in pairs(targetRoom:GetDescendants()) do
            if object:IsA("Model") and (object.Name == "LightStand" or object.Name == "Chandelier") then
                table.insert(lightFixtures, object);
            end
        end

        flickerPercentage = math.min(flickerPercentage, #lightFixtures);

        if flickerPercentage < 100 then
            local selectedFixtures = {};
            for i = 1, 100 do
                local randomFixture = lightFixtures[seed:NextInteger(1, #lightFixtures)];
                local isUnique = true;
                for _, selectedFixture in pairs(selectedFixtures) do
                    if selectedFixture == randomFixture then
                        isUnique = false;
                    end
                end
                if isUnique then
                    table.insert(selectedFixtures, randomFixture);
                end
                if flickerPercentage <= #selectedFixtures then
                    break;
                end
            end
            lightFixtures = selectedFixtures;
        end

        for _, fixture in pairs(lightFixtures) do
            for _, descendant in pairs(fixture:GetDescendants()) do
                if descendant:IsA("Light") then
                    descendant:SetAttribute("OriginalBrightness", descendant.Brightness);
                end
            end
        end

        if flickerPercentage > 5 then
            TweenService:Create(game.Lighting, TweenInfo.new(flickerDuration / 2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out, 0, true), {
                Ambient = Color3.new(0, 0, 0)
            }):Play();
        end

        local startTime = tick();
        for _, fixture in pairs(lightFixtures) do
            task.spawn(function()
                task.wait(seed:NextNumber(1, 30) / 100);
                local adjustedDuration = flickerDuration + seed:NextNumber(-100, 100) / 250;
                for i = 1, 1000 do
                    local flickerDuration = seed:NextNumber(3, 12) / 100;
                    if startTime + adjustedDuration <= tick() then
                        for _, descendant in pairs(fixture:GetDescendants()) do
                            if descendant:IsA("Light") then
                                descendant.Brightness = 0;
                                TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    Brightness = descendant:GetAttribute("OriginalBrightness")
                                }):Play();
                            end
                            if descendant.Name == "Neon" then
                                descendant.Transparency = 0.8;
                                TweenService:Create(descendant, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                                    Transparency = 0.1
                                }):Play();
                            end                        
                        end
                        return;
                    end

                    local zapSound = fixture.PrimaryPart:FindFirstChild("BulbZap", true);
                    if not zapSound then
                        zapSound = game:GetService("ReplicatedStorage").Sounds.BulbZap:Clone();
                        zapSound.Parent = fixture.PrimaryPart;
                    end

                    if zapSound then
                        zapSound.TimePosition = math.random(0, 13) / 20;
                        zapSound.Pitch = zapSound.Pitch + math.random(-100, 100) / 5000;
                        zapSound:Play();
                    end

                    for _, descendant in pairs(fixture:GetDescendants()) do
                        if descendant:IsA("Light") then
                            descendant.Brightness = descendant:GetAttribute("OriginalBrightness");
                            TweenService:Create(descendant, TweenInfo.new(flickerDuration, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0), {
                                Brightness = 0
                            }):Play();
                        end
                    end

                    local neonPart = fixture:FindFirstChild("Neon", true);
                    if neonPart and neonPart.Name == "Neon" then
                        neonPart.Transparency = 0;
                        TweenService:Create(neonPart, TweenInfo.new(flickerDuration, Enum.EasingStyle.Back, Enum.EasingDirection.In, 0), {
                            Transparency = 0.7
                        }):Play();
                    end

                    task.wait(flickerDuration + seed:NextNumber(-20, 20) / 100);
                end
            end);
        end
    end);
end

function LightingModule.toggle(room, turnOn, ambientColor)
    local targetRoom = room;

    task.spawn(function()
        if typeof(targetRoom) ~= "Instance" then
            if typeof(targetRoom) == "number" then
                targetRoom = workspace.CurrentRooms:FindFirstChild(targetRoom);
            else
                targetRoom = nil;
            end
        end

        if targetRoom == nil then
            warn("Cannot find room");
        end

        local randomSeed = Random.new(math.ceil(os.time()));
        local lightFixtures = {};

        for _, object in pairs(targetRoom:GetDescendants()) do
            if object:IsA("Model") and (object.Name == "LightStand" or object.Name == "Chandelier") then
                table.insert(lightFixtures, object);
            end
        end

        if not turnOn then
            for _, fixture in pairs(lightFixtures) do
                for _, descendant in pairs(fixture:GetDescendants()) do
                    if descendant:IsA("Light") then
                        descendant:SetAttribute("OriginalBrightness", descendant.Brightness);
                    elseif descendant:IsA("Sound") then
                        descendant:SetAttribute("OriginalVolume", descendant.Volume);
                    end
                end
            end
        end

        TweenService:Create(game.Lighting, TweenInfo.new(2, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
            Ambient = ambientColor
        }):Play();
        targetRoom:SetAttribute("Ambient", ambientColor);

        local startTime = tick();
        if turnOn then
            for _, fixture in pairs(lightFixtures) do
                local randomDelay = randomSeed:NextInteger(-10, 10) / 50;
                local turnOnDuration = randomSeed:NextInteger(5, 20) / 100;
                
                task.delay((targetRoom.RoomEntrance.Position - fixture.PrimaryPart.Position).Magnitude / 150 + randomDelay, function()
                    local neonPart = fixture:FindFirstChild("Neon", true);
                    
                    for _, descendant in pairs(fixture:GetDescendants()) do
                        if descendant:IsA("Light") then
                            TweenService:Create(descendant, TweenInfo.new(turnOnDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                                Brightness = descendant:GetAttribute("OriginalBrightness") * 1
                            }):Play();
                        elseif descendant:IsA("Sound") then
                            TweenService:Create(descendant, TweenInfo.new(turnOnDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                                Volume = descendant:GetAttribute("OriginalVolume")
                            }):Play();
                        end
                    end

                    if neonPart then
                        neonPart.Transparency = 0.9;
                        neonPart.Material = Enum.Material.Neon;
                        TweenService:Create(neonPart, TweenInfo.new(turnOnDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.InOut), {
                            Transparency = 0.2
                        }):Play();
                    end
                end);
            end
        else
            for _, fixture in pairs(lightFixtures) do
                local randomDelay = randomSeed:NextInteger(-10, 10) / 50;
                local turnOffDuration = randomSeed:NextInteger(5, 20) / 100;
                
                task.delay((targetRoom.RoomEntrance.Position - fixture.PrimaryPart.Position).Magnitude / 150 + randomDelay, function()
                    local chargeSound = game:GetService("ReplicatedStorage").Sounds.BulbCharge:Clone();
                    chargeSound.Parent = fixture.PrimaryPart;
                    chargeSound.Pitch = chargeSound.Pitch + math.random(-140, 140) / 800;
                    chargeSound:Play();
                    game.Debris:AddItem(chargeSound, 2);

                    local neonPart = fixture:FindFirstChild("Neon", true);
                    if neonPart then
                        TweenService:Create(neonPart, TweenInfo.new(turnOffDuration, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                            Transparency = 0
                        }):Play();
                    end

                    for _, descendant in pairs(fixture:GetDescendants()) do
                        if descendant:IsA("Light") then
                            TweenService:Create(descendant, TweenInfo.new(turnOffDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                                Brightness = descendant:GetAttribute("OriginalBrightness") * 2
                            }):Play();
                        elseif descendant:IsA("Sound") then
                            TweenService:Create(descendant, TweenInfo.new(turnOffDuration, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut), {
                                Volume = 0
                            }):Play();
                        end
                    end

                    task.wait(turnOffDuration + 0.01);

                    if neonPart then
                        neonPart.Transparency = 0;
                        neonPart.Material = Enum.Material.Glass;
                    end

                    for _, descendant in pairs(fixture:GetDescendants()) do
                        if descendant:IsA("Light") then
                            TweenService:Create(descendant, TweenInfo.new(0.5, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                                Brightness = 0
                            }):Play();
                        end
                    end

                    chargeSound:Stop();
                end);
            end
        end
    end);
end

return LightingModule
