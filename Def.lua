local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local bulletVelocity = 800
local aiming = false
local aimPart
local lastFire = 0
local FOV_RADIUS = 100

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

-- Crear botón y slider
local function createButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AimbotToggleGUI"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 120, 0, 40)
    btn.Position = UDim2.new(0.5, -60, 1, -120)
    btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    btn.Text = "Aimbot: OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = gui

    -- FOV circle
    local fovCircle = Instance.new("Frame")
    fovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
    fovCircle.Position = UDim2.new(0.5, -FOV_RADIUS, 0.5, -FOV_RADIUS)
    fovCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    fovCircle.BackgroundTransparency = 0.8
    fovCircle.BorderSizePixel = 1
    fovCircle.BorderColor3 = Color3.fromRGB(255, 255, 255)
    fovCircle.Visible = false
    fovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    fovCircle.Parent = gui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(1, 0)
    corner.Parent = fovCircle

    -- Slider para ajustar el FOV
    local sliderBack = Instance.new("Frame")
    sliderBack.Size = UDim2.new(0, 200, 0, 10)
    sliderBack.Position = UDim2.new(0.5, -100, 1, -60)
    sliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    sliderBack.BorderSizePixel = 0
    sliderBack.Parent = gui

    local slider = Instance.new("Frame")
    slider.Size = UDim2.new(0, FOV_RADIUS, 0, 10)
    slider.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    slider.BorderSizePixel = 0
    slider.Parent = sliderBack

    local dragging = false
    sliderBack.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
        end
    end)
    game:GetService("UserInputService").InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    game:GetService("UserInputService").InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local pos = input.Position.X - sliderBack.AbsolutePosition.X
            pos = math.clamp(pos, 10, 200)
            slider.Size = UDim2.new(0, pos, 0, 10)
            FOV_RADIUS = pos
            fovCircle.Size = UDim2.new(0, FOV_RADIUS * 2, 0, FOV_RADIUS * 2)
        end
    end)

    btn.MouseButton1Click:Connect(function()
        aiming = not aiming
        fovCircle.Visible = aiming
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

-- Obtener enemigo más cercano dentro del FOV
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end

    local closest = nil
    local shortest = math.huge
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                local screenPos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude
                    if dist <= FOV_RADIUS and dist < shortest then
                        shortest = dist
                        closest = player
                    end
                end
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
        local time = GetTravelTime(hrp.Position) * 0.9
        local predicted = PredictPosition(hrp, time)

        aimPart.Position = predicted
        ReplicatedStorage:WaitForChild("Event"):FireServer("aim", {predicted})
    else
        aimPart.Position = Vector3.new(0, -1000, 0)
    end
end)
