-- Servicios
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Config
local AIMBOT_ENABLED = true
local FIELD_OF_VIEW = 120 -- grados
local TARGET_PART_NAME = "Head" -- o "HumanoidRootPart"
local SMOOTHNESS = 0.08 -- cuanto más bajo, más rápido el movimiento

-- Inicialización de cámara
local function getScreenCenter()
    local size = Camera.ViewportSize
    return Vector2.new(size.X / 2, size.Y / 2)
end

-- Convierte posición mundial a pantalla
local function worldToScreen(position)
    local screenPoint, onScreen = Camera:WorldToViewportPoint(position)
    return Vector2.new(screenPoint.X, screenPoint.Y), onScreen
end

-- Busca el jugador enemigo más cercano al centro de la pantalla
local function getClosestTarget()
    local closest = nil
    local closestDist = math.huge
    local screenCenter = getScreenCenter()

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local hum = player.Character:FindFirstChildOfClass("Humanoid")
            local part = player.Character:FindFirstChild(TARGET_PART_NAME)
            if hum and hum.Health > 0 and part then
                local screenPos, onScreen = worldToScreen(part.Position)
                if onScreen then
                    local dist = (screenPos - screenCenter).Magnitude
                    if dist < FIELD_OF_VIEW and dist < closestDist then
                        closest = part
                        closestDist = dist
                    end
                end
            end
        end
    end

    return closest
end

-- Aimbot loop
RunService.RenderStepped:Connect(function()
    if not AIMBOT_ENABLED then return end

    local targetPart = getClosestTarget()
    if targetPart then
        local mousePos = UserInputService:GetMouseLocation()
        local screenPos = worldToScreen(targetPart.Position)

        local dx = (screenPos.X - mousePos.X) * SMOOTHNESS
        local dy = (screenPos.Y - mousePos.Y) * SMOOTHNESS

        -- Mueve suavemente el mouse hacia el objetivo
        mousemoverel(dx, dy)
    end
end)
