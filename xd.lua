warn("Loaded Turret Auto Aim")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local bulletVelocity = 800 -- Velocidad de la bala (puedes cambiar entre 799 y 800)

-- Encuentra al enemigo más cercano y vivo
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local myPosition = character.HumanoidRootPart.Position
    local closest = nil
    local minDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = player.Character.HumanoidRootPart
            local distance = (enemyHRP.Position - myPosition).Magnitude
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 and distance < minDistance then
                minDistance = distance
                closest = player
            end
        end
    end

    return closest
end

-- Calcula cuánto tardará la bala en llegar al objetivo
local function GetTravelTime(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end

    local myPosition = character.HumanoidRootPart.Position
    local distance = (targetPosition - myPosition).Magnitude
    return distance / bulletVelocity
end

-- Calcula la posición futura del objetivo según su velocidad
local function PredictPosition(targetHRP, travelTime)
    if not targetHRP then return nil end
    return targetHRP.Position + (targetHRP.Velocity * travelTime)
end

-- Bucle principal del aimbot
RunService.Heartbeat:Connect(function()
    local enemy = GetClosestEnemy()
    if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = enemy.Character.HumanoidRootPart
        local timeToHit = GetTravelTime(hrp.Position)
        local predictedPos = PredictPosition(hrp, timeToHit)

        if predictedPos then
            ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predictedPos})
        end
    end
end)
