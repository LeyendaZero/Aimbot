-- Variables globales
getgenv().autoTP = false
getgenv().coords = nil

-- Servicios
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- Esperar HRP
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local hrp = getHRP()

-- Botón flotante
local btn = Drawing.new("Text")
btn.Text = "[ Activar AutoTP ]"
btn.Size = 18
btn.Color = Color3.fromRGB(255, 255, 0)
btn.Position = Vector2.new(30, 100)
btn.Visible = true
btn.Outline = true
btn.Center = false
btn.Font = 2

-- Notificación flotante
local notify = Drawing.new("Text")
notify.Text = ""
notify.Size = 18
notify.Color = Color3.fromRGB(0, 255, 0)
notify.Position = Vector2.new(30, 130)
notify.Visible = false
notify.Outline = true
notify.Center = false
notify.Font = 2

-- Mostrar notificación por 2s
local function showNotify(msg, color)
    notify.Text = msg
    notify.Color = color or Color3.fromRGB(0, 255, 0)
    notify.Position = btn.Position + Vector2.new(0, 30)
    notify.Visible = true
    task.delay(2, function()
        notify.Visible = false
    end)
end

-- Drag y clic
local dragging = false
local dragOffset = Vector2.zero

-- Detección de toque
UserInputService.TouchStarted:Connect(function(input, gameProcessed)
    local pos = input.Position
    if pos.X >= btn.Position.X and pos.X <= btn.Position.X + 200 and
       pos.Y >= btn.Position.Y and pos.Y <= btn.Position.Y + 25 then
        dragging = true
        dragOffset = pos - btn.Position
    end
end)

UserInputService.TouchMoved:Connect(function(input)
    if dragging then
        btn.Position = input.Position - dragOffset
        notify.Position = btn.Position + Vector2.new(0, 30)
    end
end)

UserInputService.TouchEnded:Connect(function(input)
    if dragging then
        dragging = false
        -- Si fue un tap (sin mover mucho), alternar estado
        local endPos = input.Position
        if endPos.X >= btn.Position.X and endPos.X <= btn.Position.X + 200 and
           endPos.Y >= btn.Position.Y and endPos.Y <= btn.Position.Y + 25 then
            if not getgenv().autoTP then
                getgenv().coords = getHRP().Position
                getgenv().autoTP = true
                btn.Text = "[ Desactivar AutoTP ]"
                showNotify("AutoTP activado")
            else
                getgenv().autoTP = false
                btn.Text = "[ Activar AutoTP ]"
                showNotify("AutoTP desactivado", Color3.fromRGB(255, 0, 0))
            end
        end
    end
end)

-- Auto TP cada 60s
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().autoTP and getgenv().coords then
            pcall(function()
                local hrp = getHRP()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("Teletransportado", Color3.fromRGB(0, 200, 255))
            end)
        end
    end
end)
