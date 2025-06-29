local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local bulletVelocity = 800
local aiming = false
local aimPart
local lastFire = 0

-- Crear ESP como punto rojo
local function createESP()
    local part = Instance.new("Part")
    part.Name = "ESP_Target"
    part.Anchored = true
    part.CanCollide = false
    part.Size = Vector3.new(0.1, 0.1, 0.1)
    part.Transparency = 1
    part.Position = Vector3.new(0, -1000, 0)
    part.Parent = workspace

    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 6, 0, 6)
    billboard.AlwaysOnTop = true
    billboard.Adornee = part
    billboard.Parent = part

    local dot = Instance.new("Frame")
    dot.Size = UDim2.new(1, 0, 1, 0)
    dot.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    dot.BackgroundTransparency = 0
    dot.BorderSizePixel = 0
    dot.Parent = billboard

    local corner = Instance.new("UICorner", dot)
    corner.CornerRadius = UDim.new(1, 0)

    return part
end

-- Crear botón
local function createButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimbotToggleGUI"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = UDim2.new(0.5, -60, 1, -70)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = "Aimbot: OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        aiming = not aiming
        if aiming then
            btn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
            btn.Text = "Aimbot: ON"
        else
            btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
            btn.Text = "Aimbot: OFF"
            if aimPart then
                aimPart.Position = Vector3.new(0, -1000, 0)
            end
        end
    end)
end

-- Reaparece
LocalPlayer.CharacterAdded:Connect(function()
    aiming = false
    task.wait(2)
    if not LocalPlayer.PlayerGui:FindFirstChild("AimbotToggleGUI") then
        createButton()
    end
end)

-- Buscar enemigo más cercano
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPosition = character.HumanoidRootPart.Position

    local closest = nil
    local shortest = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local dist = (hrp.Position - myPosition).Magnitude
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 and dist < shortest then
                shortest = dist
                closest = player
            end
        end
    end

    return closest
end

-- Predicción
local function PredictPosition(hrp, time)
    return hrp.Position + hrp.Velocity * time
end

local function GetTravelTime(targetPos)
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return 0 end
    local myPos = char.HumanoidRootPart.Position
    return (targetPos - myPos).Magnitude / bulletVelocity
end

-- Crear ESP y botón
aimPart = createESP()
createButton()

-- Loop principal
RunService.Heartbeat:Connect(function(dt)
    if not aiming then return end
    lastFire += dt
    if lastFire < 0.1 then return end
    lastFire = 0

    local target = GetClosestEnemy()
    if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
        local hrp = target.Character.HumanoidRootPart
        local time = GetTravelTime(hrp.Position) * 0.9 -- predicción suavizada
        local predicted = PredictPosition(hrp, time)

        aimPart.Position = predicted
        ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predicted})
    else
        aimPart.Position = Vector3.new(0, -1000, 0)
    end
end)
