local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- CONFIG
local bulletVelocity = 800
local fovRadius = 100
local aimSmoothness = 0.2 -- menor = más fuerte
local autoShoot = false -- cambia a true si quieres que dispare automáticamente

-- Encuentra posición real del arma
local function getWeaponOrigin()
    local char = LocalPlayer.Character
    if not char then return Camera.CFrame.Position end
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local handle = tool:FindFirstChild("Handle")
        if handle then return handle.Position end
    end
    return Camera.CFrame.Position
end

-- Predicción (enemigo - tu velocidad)
local function predictPos(hrp, t)
    local targetVel = hrp.Velocity
    local myVel = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Velocity or Vector3.zero
    return hrp.Position + (targetVel - myVel) * t
end

-- Verifica si hay línea de visión
local function isVisible(from, to)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(from, (to - from).Unit * (to - from).Magnitude, rayParams)
    return not result
end

-- Dibujar FOV
local circle = Drawing.new("Circle")
circle.Radius = fovRadius
circle.Thickness = 1.5
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Filled = false
circle.Transparency = 0.7
circle.Visible = true

-- Mantener el círculo centrado
RunService.Heartbeat:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)
end)

-- Buscar objetivo válido
local function GetClosestEnemy()
    local myChar = LocalPlayer.Character
    if not myChar or not myChar:FindFirstChild("HumanoidRootPart") then return nil end
    local origin = getWeaponOrigin()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local best, predicted, bestDist = nil, nil, math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
            if hrp and hum and hum.Health > 0 then
                local dist = (hrp.Position - origin).Magnitude
                local t = dist / bulletVelocity
                local futurePos = predictPos(hrp, t)
                local screenPos, onScreen = Camera:WorldToViewportPoint(futurePos)
                local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                if onScreen and distFromCenter < fovRadius and distFromCenter < bestDist and isVisible(origin, futurePos) then
                    best, predicted, bestDist = player, futurePos, distFromCenter
                end
            end
        end
    end
    return best, predicted
end

-- Aimbot apuntando desde el arma
RunService.Heartbeat:Connect(function()
    local _, predictedPos = GetClosestEnemy()
    if predictedPos then
        local origin = getWeaponOrigin()
        local newCF = CFrame.new(origin, predictedPos)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, predictedPos), aimSmoothness)

        if autoShoot then
            local tool = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Tool")
            if tool and tool:FindFirstChild("Activate") then
                tool:Activate()
            end
        end
    end
end)
