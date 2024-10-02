-- Daytime.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.
-- this is so DOGDAY right guys???

local CurrentRooms = workspace:WaitForChild("CurrentRooms")
local RunService = game:GetService("RunService")

local function convertToDay(Room: Model): ()
    task.wait(1.5) -- Stream In
    local IndexedWindows = {}

    for _, RoomAsset in Room:GetDescendants() do
        if not RoomAsset:IsA("Model") then
            if _G.DEBUG_HOTELPLUSPLUS then
                warn("Found non-model asset in room: " .. Room.Name)
            end

            continue
        end

        if RoomAsset.Name == "Window" then
            if _G.DEBUG_HOTELPLUSPLUS then
                warn("Found window in room: " .. Room.Name)
            end

            table.insert(IndexedWindows, RoomAsset)
        end

        RunService.Heartbeat:Wait()
    end

    for _, Window in IndexedWindows do
        local Success, Error = pcall(
            function(): ()
                local Skybox = Window.Skybox
                local LightPanel = Window.LightPanel
                local Glass = Window.Glass
                local SurfaceLight = LightPanel.SurfaceLight
                local NewSurfaceLight = SurfaceLight:Clone()

                for _, Child in Glass:GetChildren() do
                    if Child:IsA("Sound") then
                        Child.Volume = 0.15
                        Child.PlaybackSpeed = 1
                    end
                end

                for _, Child in LightPanel:GetChildren() do
                    Child:Destroy()
                end

                NewSurfaceLight.Parent = LightPanel
                NewSurfaceLight.Name = "Daylight"
                NewSurfaceLight.Brightness = 1
                NewSurfaceLight.Color = Color3.fromRGB(193, 193, 193)
                NewSurfaceLight.Range = 60
                NewSurfaceLight.Angle = 120
                NewSurfaceLight.Shadows = true
                NewSurfaceLight.Enabled = true

                Skybox.Color = Color3.fromRGB(126, 126, 126)
                local Forcer = Skybox:GetPropertyChangedSignal("Color"):Connect(
                    function(): ()
                        Skybox.Color = Color3.fromRGB(126, 126, 126)
                    end
                )

                Room.Destroying:Once(
                    function(): ()
                        Forcer:Disconnect()
                    end
                )
            end
        )

        assert(Success, Error)
    end
end

CurrentRooms.ChildAdded:Connect(
    function(Room: Model): ()
        task.spawn(convertToDay, Room)
    end
)

for _, Room in CurrentRooms:GetChildren() do
    task.spawn(convertToDay, Room)
end
