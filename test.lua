local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local bulletVelocity = 800
local fovRadius = 100
local aimSmoothness = 0.15

-- Encuentra el arma equipada
local function getWeaponOrigin()
    local char = LocalPlayer.Character
    if not char then return Camera.CFrame.Position end

    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        local handle = tool:FindFirstChild("Handle")
        if handle then
            return handle.Position
        end
    end

    -- Fallback si no hay arma equipada
    return Camera.CFrame.Position
end

-- Predicción considerando tu movimiento
local function predictPos(targetHrp, travelTime)
    local enemyVel = targetHrp.Velocity
    local myChar = LocalPlayer.Character
    local myVel = myChar and myChar:FindFirstChild("HumanoidRootPart") and myChar.HumanoidRootPart.Velocity or Vector3.new()
    return targetHrp.Position + (enemyVel - myVel) * travelTime
end

-- Conversión 3D → 2D
local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Verificar visibilidad (raycast)
local function isVisible(fromPos, toPos)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}
    local result = Workspace:Raycast(fromPos, (toPos - fromPos).Unit * (toPos - fromPos).Magnitude, rayParams)
    return not result
end

-- Dibujar FOV
local circle = Drawing.new("Circle")
circle.Radius = fovRadius
circle.Thickness = 1.5
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Transparency = 0.6
circle.Filled = false
circle.Visible = true

-- Actualizar posición del círculo
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Buscar enemigo dentro de FOV visible desde el arma
local function GetClosestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end
    local origin = getWeaponOrigin()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local closest, predicted, shortestDist = nil, nil, math.huge

    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Team ~= LocalPlayer.Team then
            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
            local humanoid = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
            if hrp and humanoid and humanoid.Health > 0 then
                local dist = (hrp.Position - origin).Magnitude
                local travelTime = dist / bulletVelocity
                local futurePos = predictPos(hrp, travelTime)
                local screenPos, visible = worldToScreen(futurePos)
                local distToCenter = (screenPos - screenCenter).Magnitude

                if visible and distToCenter < fovRadius and distToCenter < shortestDist and isVisible(origin, futurePos) then
                    closest, predicted, shortestDist = p, futurePos, distToCenter
                end
            end
        end
    end

    return closest, predicted
end

-- Aimbot: apuntar la cámara hacia donde debe disparar el arma
RunService.RenderStepped:Connect(function()
    local _, targetPos = GetClosestEnemy()
    if targetPos then
        local origin = getWeaponOrigin()
        local lookCFrame = CFrame.new(origin, targetPos)
        Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), aimSmoothness)
    end
end)
