-- CONFIGURACIÓN
getgenv().autoTP = true
getgenv().coords = nil

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Obtener HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

-- Guardar posición inicial para teletransporte
local hrp = getHRP()
getgenv().coords = hrp.Position

-- Mostrar notificación (opcional)
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
    task.delay(1, function()
        notify.Visible = false
    end)
end

-- Teleport cada vez que estás encima de "PlotBlock"
RunService.RenderStepped:Connect(function()
    if not getgenv().autoTP then return end

    local hrp = getHRP()
    local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(4, 2, 4))

    for _, part in pairs(parts) do
        if part:IsA("BasePart") and part.Name == "PlotBlock" then
            -- Teletransportar rápidamente a la posición guardada
            pcall(function()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("TP desde PlotBlock", Color3.fromRGB(255, 100, 0))
            end)
            break
        end
    end
end)
