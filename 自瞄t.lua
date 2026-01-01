local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local RunService = game:GetService("RunService")
local old

local FOV_RADIUS = 60  
local AIM_SMOOTHNESS = 0.2

local FOV_Circle = Drawing.new("Circle")
FOV_Circle.Visible = true
FOV_Circle.Radius = FOV_RADIUS
FOV_Circle.Color = Color3.fromRGB(255, 0, 0)
FOV_Circle.Thickness = 2
FOV_Circle.Transparency = 0.8
FOV_Circle.Filled = false
FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
Camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    FOV_Circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

local function getValidTarget()
    local closestTarget = nil
    local closestDistance = math.huge
    local camPos = Camera.CFrame.Position
    local camDir = Camera.CFrame.LookVector

    for _, player in ipairs(Players:GetPlayers()) do
        
        if player ~= LocalPlayer 
        and player.Character 
        and player.Character:FindFirstChild("Head") 
        and player.Character:FindFirstChildOfClass("Humanoid") 
        and player.Character.Humanoid.Health > 0 
        and not player.Character:FindFirstChild("ForceField") then
            
            local head = player.Character.Head
            local headPos = head.Position
            
            local directionToTarget = (headPos - camPos).Unit
            local angle = math.deg(math.acos(camDir:Dot(directionToTarget)))

            if angle <= FOV_RADIUS then
               
                local distance = (headPos - camPos).Magnitude
                if distance < closestDistance then
                    closestTarget = head
                    closestDistance = distance
                end
            end
        end
    end
    return closestTarget
end

local function enableAimbot()
    RunService.RenderStepped:Connect(function()
        local target = getValidTarget()
        if target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            
            local targetPos = target.Position
            local lookAt = CFrame.new(Camera.CFrame.Position, targetPos)
            
            Camera.CFrame = Camera.CFrame:Lerp(lookAt, AIM_SMOOTHNESS)
        end
    end)
end

local function antiKickAndMaintain()
    while wait(1) do
        pcall(function()
            
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if not char or (hum and hum.Health <= 0) then
                LocalPlayer:LoadCharacter()
                wait(0.5) 
                enableAimbot()
            end
            
            if not FOV_Circle.Visible then
                FOV_Circle.Visible = true
            end
        end)
    end
end

enableAimbot()
coroutine.wrap(antiKickAndMaintain)()
