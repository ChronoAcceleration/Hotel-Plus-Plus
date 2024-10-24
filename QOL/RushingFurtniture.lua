-- RushingFurtniture.lua
-- [Comet Development] By Chrono
-- This file is part of the Hotel ++ Project.

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local ExecutorHelper = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Hotel-Plus-Plus/refs/heads/main/Modules/Executor.lua"))()
local ScriptUtility = loadstring(game:HttpGet("https://raw.githubusercontent.com/ChronoAcceleration/Comet-Development/refs/heads/main/Doors/Utility/DoorsScriptUtility.lua"))()
local EntityHook = ScriptUtility.EntityHook:New()

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()

local CurrentRooms = workspace:FindFirstChild("CurrentRooms")
local Movable = {
"Potted_Plant",
"Table",
"Desk",
"Chair",
"Regal_Chair",
"Regal_Couch",
"Regal_Sofa"
}

function FullUnanchor(Model): ()
     for _, v in Model:GetDescendants() do
         if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("BasePart") or v:IsA("UnionOperation") then
              v.Anchored = false
              v.CustomPhysicalProperties = PhysicalProperties.new(0.001, 0.001, 0.001)
         end
     end
end

function AutoWeld(Model, PrimaryPart): ()
     for _, v in Model:GetDescendants() do
         if v:IsA("Part") or v:IsA("MeshPart") or v:IsA("BasePart") or v:IsA("UnionOperation") then
               v.CanCollide = true
               v.CanQuery = true
               v.CanTouch = true
               local Space = v.CFrame:ToObjectSpace(PrimaryPart.CFrame)
               local Weld = Instance.new("Weld", PrimaryPart)
               Weld.C1 = Space
               Weld.Part0 = PrimaryPart
               Weld.Part1 = v
         end
     end
end

EntityHook:On(
    "Rush", 
    function(Rush: Model): ()
        local Hitbox = Instance.new("Part", workspace)
        Hitbox.Name = "RushBox"
        Hitbox.Anchored = true
        Hitbox.Size = Vector3.new(50,50,50)
        Hitbox.CanCollide = false
        Hitbox.Transparency = 1
        Hitbox.CFrame = Rush:GetPivot()
        local lastCheck = tick()
        local lastPosition = Rush:GetPivot().Position
        
        local CheckConnection
        CheckConnection = RunService.Heartbeat:Connect(
            function(): ()
                Hitbox.CFrame = Rush:GetPivot()
               
                if tick() - lastCheck >= 0.4 then
                  lastCheck = tick()
                   
                   local Params = OverlapParams.new()
                   Params.FilterDescendantsInstances = {Rush, Rush.RushNew}
                   Params.FilterType = Enum.RaycastFilterType.Exclude
                   Params.RespectCanCollide = false
                    local Parts = Workspace:GetPartsInPart(Hitbox, Params)
                    
                    for _, v in pairs(Parts) do
                      if v and v~=nil then
                      if v.Parent~=nil then
                         if table.find(Movable, v.Parent.Name) then
                            local Furtniture = v.Parent:Clone()
                            Furtniture.Parent = v.Parent.Parent
                            v.Parent:Destroy()
                            
                              local Base = Furtniture:FindFirstChild("Base") or Furtniture:FindFirstChild("Main") or Furtniture.PrimaryPart or Furtniture:FindFirstChildWhichIsA("BasePart")
                   
                              Base.Anchored = false
                              task.spawn(AutoWeld, Furtniture, Base)
                              task.spawn(FullUnanchor, Furtniture)
                              
                               local Direction = (Base.Position - lastPosition).Unit
                               local LastPositionDistance = (lastPosition - Rush:GetPivot().Position).Magnitude
                               local Force =  Instance.new("BodyVelocity", Base)
                               Force.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
                               Force.Velocity = Direction * LastPositionDistance * 8
                               game:GetService("Debris"):AddItem(Force, 0.1)
                         end
                         end
                         end
                    end
                    lastPosition = Rush:GetPivot().Position
                   
                end    
            end    
         )
 
    Rush.Destroying:Once(
        function(): ()
              Hitbox:Destroy()
             CheckConnection:Disconnect()
        end
    )
end
)
