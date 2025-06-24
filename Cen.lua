local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

local bulletVelocity = 800
local fovRadius = 100 -- Tamaño del FOV en píxeles
local aimSmoothness = 0.15 -- Entre 0 (instantáneo) y 1 (muy suave)

-- Devuelve pantalla y distancia de un punto 3D
local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Encuentra enemigo dentro del FOV más cercano
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local myPos = character.HumanoidRootPart.Position
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    local closest = nil
    local closestPredictedPos = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                local distance = (hrp.Position - myPos).Magnitude
                local travelTime = distance / bulletVelocity
                local predictedPos = hrp.Position + (hrp.Velocity * travelTime)
                local screenPos, visible = worldToScreen(predictedPos)

                if visible then
                    local distFromCenter = (screenPos - screenCenter).Magnitude
                    if distFromCenter < fovRadius and distFromCenter < shortestDist then
                        shortestDist = distFromCenter
                        closest = player
                        closestPredictedPos = predictedPos
                    end
                end
            end
        end
    end

    return closest, closestPredictedPos
end

-- Aimbot suave y limitado por FOV
RunService.RenderStepped:Connect(function()
    local _, targetPos = GetClosestEnemy()
    if targetPos then
        local current = Camera.CFrame
        local desired = CFrame.new(current.Position, targetPos)
        Camera.CFrame = current:Lerp(desired, aimSmoothness)
    end
end)
