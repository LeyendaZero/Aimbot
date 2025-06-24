warn("Loaded Aimbot + ESP with Toggle Button (Mobile Ready)")

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local bulletVelocity = 800
local aiming = false
local aimPart

-- Crear marcador ESP
local function createAimMarker()
    local part = Instance.new("Part")
    part.Name = "AimbotESPPart"
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(0.2, 0.2, 0.2)
    part.Transparency = 1
    part.Parent = workspace

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

-- Crear botón flotante
local function createToggleButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotToggleGUI"
    pcall(function() screenGui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 120, 0, 40)
    button.Position = UDim2.new(0.5, -60, 1, -60)
    button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    button.Text = "Aimbot: OFF"
    button.TextColor3 = Color3.new(1, 1, 1)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 18
    button.Parent = screenGui

    button.MouseButton1Click:Connect(function()
        aiming = not aiming
        if aiming then
            button.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            button.Text = "Aimbot: ON"
        else
            button.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            button.Text = "Aimbot: OFF"
            aimPart.Position = Vector3.new(0, -1000, 0) -- ocultar
        end
    end)
end

-- Función para encontrar al enemigo más cercano
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local myPosition = character.HumanoidRootPart.Position
    local closest = nil
    local minDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local distance = (hrp.Position - myPosition).Magnitude
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 and distance < minDistance then
                minDistance = distance
                closest = player
            end
        end
    end

    return closest
end

-- Predicción del disparo
local function GetTravelTime(targetPosition)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return 0 end

    local myPosition = character.HumanoidRootPart.Position
    local distance = (targetPosition - myPosition).Magnitude
    return distance / bulletVelocity
end

local function PredictPosition(hrp, travelTime)
    return hrp.Position + (hrp.Velocity * travelTime)
end

-- Inicializar
aimPart = createAimMarker()
createToggleButton()

-- Loop
RunService.Heartbeat:Connect(function()
    if not aiming then return end

    local enemy = GetClosestEnemy()
    if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = enemy.Character.HumanoidRootPart
        local timeToHit = GetTravelTime(hrp.Position)
        local predictedPos = PredictPosition(hrp, timeToHit)

        if predictedPos then
            aimPart.Position = predictedPos
            ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predictedPos})
        end
    else
        aimPart.Position = Vector3.new(0, -1000, 0) -- ocultar si no hay objetivo
    end
end)
