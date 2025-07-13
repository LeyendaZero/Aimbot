-- CONFIGURACIÓN INICIAL
getgenv().autoTP = false
getgenv().coords = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Obtener HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Mostrar notificaciones flotantes
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

-- Bandera para evitar múltiples activaciones al pisar
local touchedCooldown = false

-- Temporizador que inicia cuando activas AutoTP
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().autoTP and getgenv().coords then
            pcall(function()
                local hrp = getHRP()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("AutoTP (cada 60s)", Color3.fromRGB(0, 255, 255))
            end)
        end
    end
end)

-- Detección al pisar "PlotBlock"
RunService.RenderStepped:Connect(function()
    if touchedCooldown then return end

    local hrp = getHRP()
    local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(4, 1, 4))

    for _, part in pairs(parts) do
        if part:IsA("BasePart") and part.Name == "PlotBlock" then
            touchedCooldown = true

            task.spawn(function()
                -- Si aún no estaba activo, activar AutoTP
                if not getgenv().autoTP then
                    getgenv().coords = getHRP().Position
                    getgenv().autoTP = true
                    showNotify("AutoTP activado", Color3.fromRGB(0, 255, 0))
                end

                -- Teletransportar inmediatamente
                pcall(function()
                    hrp.CFrame = CFrame.new(getgenv().coords)
                    showNotify("TP inmediato al pisar PlotBlock", Color3.fromRGB(255, 100, 0))
                end)

                task.wait(2)
                touchedCooldown = false
            end)

            break
        end
    end
end)
