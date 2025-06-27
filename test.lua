--// Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

--// Configuración
local BULLET_VELOCITY = 1000
local FOV_RADIUS = 100
local TARGET_PARTS = { "Head", "Torso", "HumanoidRootPart" }
local GRAVITY = Workspace.Gravity
local AUTO_FIRE = true -- el juego dispara automáticamente

--// Dibujar FOV
local circle = Drawing.new("Circle")
circle.Radius = FOV_RADIUS
circle.Thickness = 1.5
circle.Color = Color3.fromRGB(255, 0, 0)
circle.Transparency = 0.6
circle.Filled = false
circle.Visible = true

RunService.RenderStepped:Connect(function()
    circle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
end)

--// Utilidades
local function WorldToScreen(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), onScreen
end

local function IsVisible(fromPos, toPos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = { LocalPlayer.Character }
    return not Workspace:Raycast(fromPos, toPos - fromPos, params)
end

local function IsPartValid(part)
    return part and part:IsA("BasePart") and part.Transparency < 1 and part.Size.Magnitude > 0
end

local function PredictPosition(part)
    local originPart = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not originPart then return part.Position end

    local distance = (part.Position - originPart.Position).Magnitude
    local time = distance / BULLET_VELOCITY
    local gravityOffset = Vector3.new(0, 0.5 * GRAVITY * time * time, 0)

    return part.Position + part.Velocity * time - gravityOffset
end

local function GetBestTarget()
    local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
    local bestPos, shortestDist

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Team ~= LocalPlayer.Team then
            local char = player.Character
            local humanoid = char and char:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 then
                for _, partName in ipairs(TARGET_PARTS) do
                    local part = char:FindFirstChild(partName)
                    if IsPartValid(part) then
                        local predicted = PredictPosition(part)
                        local screenPos, onScreen = WorldToScreen(predicted)
                        local dist = (screenPos - screenCenter).Magnitude

                        if onScreen and dist < FOV_RADIUS and dist < (shortestDist or math.huge) then
                            if IsVisible(Camera.CFrame.Position, predicted) then
                                bestPos = predicted
                                shortestDist = dist
                            end
                        end
                    end
                end
            end
        end
    end

    return bestPos
end

--// Aimbot loop
RunService.RenderStepped:Connect(function()
    local targetPosition = GetBestTarget()
    if targetPosition then
        local camPos = Camera.CFrame.Position
        local desiredDirection = (targetPosition - camPos).Unit
        local currentDirection = Camera.CFrame.LookVector
        local angleDifference = math.deg(math.acos(currentDirection:Dot(desiredDirection)))

        if AUTO_FIRE then
            Camera.CFrame = CFrame.new(camPos, targetPosition)
        else
            local smoothness = 0.5
            local targetCFrame = CFrame.new(camPos, targetPosition)
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
        end

        -- Puedes agregar lógica de disparo aquí si estás usando triggerbot
    end
end)
