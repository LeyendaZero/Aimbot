warn("Loaded Turret Auto Aim + ESP")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local bulletVelocity = 800
local aimMarker -- marcador visual

-- Crea el círculo visual en 3D
local function createAimESP()
    local billboard = Instance.new("BillboardGui")
    billboard.Name = "AimbotESP"
    billboard.Size = UDim2.new(0, 12, 0, 12)
    billboard.AlwaysOnTop = true
    billboard.LightInfluence = 0
    billboard.Adornee = nil

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 2
    circle.BorderColor3 = Color3.fromRGB(255, 0, 0)
    circle.Parent = billboard

    billboard.Parent = game.CoreGui
    return billboard
end

-- Encuentra al enemigo más cercano
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

-- Tiempo que tarda la bala en llegar
local function GetTravelTime(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end

    local myPosition = character.HumanoidRootPart.Position
    local distance = (targetPosition - myPosition).Magnitude
    return distance / bulletVelocity
end

-- Posición futura predicha
local function PredictPosition(hrp, travelTime)
    return hrp.Position + (hrp.Velocity * travelTime)
end

-- Inicia marcador
aimMarker = createAimESP()

-- Loop principal
RunService.Heartbeat:Connect(function()
    local enemy = GetClosestEnemy()
    if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = enemy.Character.HumanoidRootPart
        local timeToHit = GetTravelTime(hrp.Position)
        local predictedPos = PredictPosition(hrp, timeToHit)

        if predictedPos then
            -- Fijar la posición del marcador en el mundo
            if not aimMarker.Adornee then
                local tempPart = Instance.new("Part")
                tempPart.Anchored = true
                tempPart.CanCollide = false
                tempPart.Transparency = 1
                tempPart.Size = Vector3.new(0.1, 0.1, 0.1)
                tempPart.Name = "ESP_Target"
                tempPart.Parent = workspace
                aimMarker.Adornee = tempPart
            end

            aimMarker.Adornee.Position = predictedPos

            -- Disparar
            ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predictedPos})
        end
    else
        aimMarker.Adornee = nil
    end
end)
