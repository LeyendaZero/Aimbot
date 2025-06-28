-- Servicios básicos
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Protección: intentar obtener RunService sin crashear
local RunService = nil
pcall(function()
    RunService = game:GetService("RunService")
end)

-- Si no existe, detener el script seguro
if not RunService or not RunService.Heartbeat then
    warn("❌ RunService o Heartbeat no disponible. Script cancelado para evitar errores.")
    return
end

-- Variables de control
local active = false
local lastHealth = 100

-- Crear GUI con botón
local function createButton()
    local gui = Instance.new("ScreenGui")
    gui.Name = "AntiPredictGUI"
    gui.ResetOnSpawn = false
    pcall(function() gui.Parent = LocalPlayer:WaitForChild("PlayerGui") end)

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 160, 0, 40)
    btn.Position = UDim2.new(0.5, -80, 1, -80)
    btn.BackgroundColor3 = Color3.fromRGB(50, 50, 200)
    btn.Text = "Anti-Predict: OFF"
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.Parent = gui

    btn.MouseButton1Click:Connect(function()
        active = not active
        btn.Text = active and "Anti-Predict: ON" or "Anti-Predict: OFF"
        btn.BackgroundColor3 = active and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
    end)
end

-- Detecta si el personaje está en un avión
local function isPlane(character)
    if not character then return false end
    for _, child in pairs(character:GetChildren()) do
        if child:IsA("Model") or child:IsA("VehicleSeat") then
            if child.Name:lower():find("plane") then
                return true
            end
        end
    end
    return false
end

-- Evasión rápida si te disparan
local function dodge()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dir = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit
    hrp.Velocity = hrp.Velocity + dir * 120
end

-- Loop anti-aim
RunService.Heartbeat:Connect(function()
    if not active then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    -- Evasión si te disparan
    if hum.Health < lastHealth then
        dodge()
    end
    lastHealth = hum.Health

    local isFlying = isPlane(char)
    local intensity = 1

    if not isFlying then
        -- Si estás corriendo o caminando, aumenta intensidad
        if hum.MoveDirection.Magnitude > 0 then
            intensity = 3
        end

        local offset = Vector3.new(
            math.random(-1, 1),
            0,
            math.random(-1, 1)
        ) * 10 * intensity

        hrp.Velocity = hrp.Velocity + offset
    else
        -- Movimiento aleatorio para aviones
        local plane = char
        local bv = plane:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity", plane)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        local offset = Vector3.new(math.random(-1,1), math.random(-1,1), math.random(-1,1)) * 25
        bv.Velocity = plane.Velocity + offset
    end
end)

-- Crear GUI al inicio
createButton()

-- Volver a crear botón si mueres y reapareces
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if not LocalPlayer.PlayerGui:FindFirstChild("AntiPredictGUI") then
        createButton()
    end
end)
