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

-- Guardar posición inicial
local hrp = getHRP()
getgenv().coords = hrp.Position

-- Mostrar notificación
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
    task.delay(1.5, function()
        notify.Visible = false
    end)
end

-- Comprobar si el color es amarillo
local function isYellow(color)
    local r, g, b = color.R, color.G, color.B
    return r > 0.9 and g > 0.8 and b < 0.3 -- amarillo fuerte
end

-- Teleport si pisas parte amarilla
RunService.RenderStepped:Connect(function()
    if not getgenv().autoTP then return end

    local hrp = getHRP()
    local parts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(4, 2, 4))

    for _, part in pairs(parts) do
        if part:IsA("BasePart") and isYellow(part.Color) then
            pcall(function()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("TP desde parte amarilla", Color3.fromRGB(255, 255, 0))
            end)
            break
        end
    end
end)
