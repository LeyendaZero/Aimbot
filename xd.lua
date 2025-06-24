warn("Loaded Aimbot with ESP Marker (Mobile Compatible)")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local bulletVelocity = 800
local aimPart -- Parte donde se mostrará el ESP

-- Crea un marcador visual con un círculo
local function createAimMarker()
    -- Parte invisible para colocar el marcador
    local part = Instance.new("Part")
    part.Name = "AimbotESPPart"
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Transparency = 1
    part.Parent = workspace

    -- BillboardGui encima de la parte
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 20, 0, 20)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.Parent = part

    local circle = Instance.new("Frame")
    circle.Size = UDim2.new(1, 0, 1, 0)
    circle.BackgroundTransparency = 1
    circle.BorderSizePixel = 2
    circle.BorderColor3 = Color3.fromRGB(255, 0, 0)
    circle.Parent = billboard

    return part
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

-- Calcula el tiempo de viaje de la bala
local function GetTravelTime(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end

    local myPosition = character.HumanoidRootPart.Position
    local distance = (targetPosition - myPosition).Magnitude
    return distance / bulletVelocity
end

-- Predice la posición futura
local function PredictPosition(hrp, travelTime)
    return hrp.Position + (hrp.Velocity * travelTime)
end

-- Crear el marcador solo una vez
aimPart = createAimMarker()

-- Loop principal
RunService.Heartbeat:Connect(function()
    local enemy = GetClosestEnemy()
    if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = enemy.Character.HumanoidRootPart
        local timeToHit = GetTravelTime(hrp.Position)
        local predictedPos = PredictPosition(hrp, timeToHit)

        if predictedPos then
            -- Mueve el marcador visual al punto predicho
            aimPart.Position = predictedPos

            -- Disparar
            ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predictedPos})
        end
    else
        aimPart.Position = Vector3.new(0, -1000, 0) -- lo oculta bajo el mapa
    end
end)
