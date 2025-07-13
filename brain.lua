-- CONFIGURACIÓN INICIAL
getgenv().autoTP = true -- siempre activo
getgenv().coords = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Obtener HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Mostrar mensaje flotante
local notify = Drawing.new("Text")
notify.Size = 18
notify.Color = Color3.fromRGB(255, 255, 0)
notify.Position = Vector2.new(40, 145)
notify.Visible = false
notify.Outline = true
notify.Center = false
notify.Font = 2

local function showNotify(text, color)
    notify.Text = text
    notify.Color = color or Color3.fromRGB(0, 255, 0)
    notify.Visible = true
    task.delay(2, function()
        notify.Visible = false
    end)
end

-- Guardar posición inicial
local hrp = getHRP()
getgenv().coords = hrp.Position
showNotify("Posición guardada para AutoTP", Color3.fromRGB(0, 200, 255))

-- Detector de parte bajo el jugador (para botón)
local touchedCooldown = false

RunService.RenderStepped:Connect(function()
    if not getgenv().autoTP or touchedCooldown then return end

    local hrp = getHRP()
    local position = hrp.Position
    local parts = workspace:GetPartBoundsInBox(CFrame.new(position), Vector3.new(4, 1, 4))

    for _, part in pairs(parts) do
        if part:IsA("BasePart") and part.Transparency < 1 and part.CanCollide then
            touchedCooldown = true
            task.delay(0.2, function()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("¡AutoTP al pisar botón!", Color3.fromRGB(255, 100, 0))
                task.wait(2)
                touchedCooldown = false
            end)
            break
        end
    end
end)

-- TP automático cada 60 segundos
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().autoTP and getgenv().coords then
            pcall(function()
                local hrp = getHRP()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("AutoTP cada 60s", Color3.fromRGB(0, 255, 255))
            end)
        end
    end
end)
