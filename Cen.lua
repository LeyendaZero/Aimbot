local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local bulletVelocity = 800 -- Puedes ajustar esto según el juego

-- Encuentra al enemigo más cercano con predicción
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = character.HumanoidRootPart.Position

    local closest = nil
    local closestPredictedPos = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        -- Ignorar si es uno mismo, o está en el mismo equipo
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = player.Character.HumanoidRootPart
            local enemyHum = player.Character:FindFirstChildOfClass("Humanoid")

            if enemyHum and enemyHum.Health > 0 then
                local distance = (enemyHRP.Position - myPos).Magnitude
                local travelTime = distance / bulletVelocity
                local predictedPos = enemyHRP.Position + (enemyHRP.Velocity * travelTime)

                local predictedDistance = (predictedPos - myPos).Magnitude
                if predictedDistance < shortestDist then
                    shortestDist = predictedDistance
                    closest = player
                    closestPredictedPos = predictedPos
                end
            end
        end
    end

    return closest, closestPredictedPos
end

-- Loop principal para apuntar a enemigo más cercano con predicción
RunService.RenderStepped:Connect(function()
    local _, predictedPos = GetClosestEnemy()
    if predictedPos then
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, predictedPos)
    end
end)
