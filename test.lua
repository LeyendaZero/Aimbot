-- Servicios protegidos
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local active = false
local lastHealth = 100

-- Crear GUI
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

-- Detectar si estás en avión
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

-- Maniobra evasiva reactiva
local function dodge()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    local dir = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit
    hrp.Velocity = hrp.Velocity + dir * 120
end

-- Loop principal
RunService.Heartbeat:Connect(function()
    if not active then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local hum = char:FindFirstChildOfClass("Humanoid")
    if not hum then return end

    local isFlying = isPlane(char)

    -- Detectar si recibiste daño (te dispararon)
    if hum.Health < lastHealth then
        dodge() -- evasión reactiva
    end
    lastHealth = hum.Health

    -- Movimiento continuo anti-predict
    local mult = 2

    if not isFlying then
        -- Aumenta intensidad si vas caminando o corriendo
        if hum.MoveDirection.Magnitude > 0 then
            mult = 2.5
        end

        local offset = Vector3.new(
            math.random(-1, 1),
            0,
            math.random(-1, 1)
        ) * 10 * mult

        hrp.Velocity = hrp.Velocity + offset
    else
        -- Para aviones
        local plane = char
        local bv = plane:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity", plane)
        bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        local offset = Vector3.new(math.random(-1,1), math.random(-1,1), math.random(-1,1)) * 20
        bv.Velocity = plane.Velocity + offset
    end
end)

-- Crear botón
createButton()

-- Reaparece el botón al morir
LocalPlayer.CharacterAdded:Connect(function()
    task.wait(2)
    if not LocalPlayer.PlayerGui:FindFirstChild("AntiPredictGUI") then
        createButton()
    end
end)
