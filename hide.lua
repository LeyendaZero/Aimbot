local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local bulletVelocity = 1000
local fovRadius = 150
local aimSmoothness = 0.3

-- Dibujar el FOV
local circle = Drawing.new("Circle")
circle.Radius = fovRadius
circle.Thickness = 1.5
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Transparency = 0.6
circle.Filled = false
circle.Visible = true

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

-- Posición de pantalla
local function worldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

-- Obtener enemigo más cercano en FOV
local function GetClosestEnemy()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return nil end

    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local myPos = char.HumanoidRootPart.Position

    local closest = nil
    local predictedPos = nil
    local shortestDist = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = player.Character.HumanoidRootPart
            local hum = player.Character:FindFirstChildOfClass("Humanoid")

            if hum and hum.Health > 0 then
                local dist = (hrp.Position - myPos).Magnitude
                local travelTime = dist / bulletVelocity
                local futurePos = hrp.Position + (hrp.Velocity * travelTime)

                local screenPos, onScreen = worldToScreen(futurePos)
                local distFromCenter = (screenPos - screenCenter).Magnitude

                -- Depuración opcional:
                -- print(player.Name, "onScreen:", onScreen, "distFromCenter:", math.floor(distFromCenter))

                if onScreen and distFromCenter <= fovRadius and distFromCenter < shortestDist then
                    closest = player
                    predictedPos = futurePos
                    shortestDist = distFromCenter
                end
            end
        end
    end

    return closest, predictedPos
end

-- Aimbot
RunService.RenderStepped:Connect(function()
    local _, targetPos = GetClosestEnemy()
    if targetPos then
        local current = Camera.CFrame
        local targetCFrame = CFrame.new(current.Position, targetPos)
        Camera.CFrame = current:Lerp(targetCFrame, aimSmoothness)
    end
end)
