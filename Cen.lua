local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local bulletVelocity = 1100
local fovRadius = 20
local aimSmoothness = 0.50

-- Dibujar el FOV
local circle = Drawing.new("Circle")
circle.Radius = fovRadius
circle.Thickness = 1.5
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Transparency = 0.6
circle.Filled = false
circle.Visible = true

-- Actualizar el círculo en pantalla
RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Convierte posición 3D a 2D
local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Verifica si hay línea de visión libre (sin pared)
local function isVisible(fromPos, toPos)
    local rayParams = RaycastParams.new()
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character}

    local result = Workspace:Raycast(fromPos, (toPos - fromPos).Unit * (toPos - fromPos).Magnitude, rayParams)
    return not result -- si no choca con nada, es visible
end

-- Buscar enemigo más cercano visible dentro del FOV
local function GetClosestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = char.HumanoidRootPart.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local closest = nil
    local predictedPos = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
            if humanoid and humanoid.Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                local travelTime = dist / bulletVelocity
                local futurePos = hrp.Position + (hrp.Velocity * travelTime)

                local screenPos, onScreen = worldToScreen(futurePos)
                local distFromCenter = (screenPos - screenCenter).Magnitude

                if onScreen and distFromCenter < fovRadius and distFromCenter < shortestDist then
                    if isVisible(Camera.CFrame.Position, futurePos) then
                        shortestDist = distFromCenter
                        closest = player
                        predictedPos = futurePos
                    end
                end
            end
        end
    end

    return closest, predictedPos
end

-- Aimbot con FOV, predicción, suavidad y detección de paredes
RunService.RenderStepped:Connect(function()
    local _, targetPos = GetClosestEnemy()
    if targetPos then
        local current = Camera.CFrame
        local targetCFrame = CFrame.new(current.Position, targetPos)
        Camera.CFrame = current:Lerp(targetCFrame, aimSmoothness)
    end
end)
