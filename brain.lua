-- Variables globales
getgenv().autoTP = false
getgenv().coords = nil

-- Servicios
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Esperar personaje
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local hrp = getHRP()

-- Crear botón flotante
local btn = Drawing.new("Text")
btn.Text = "[ Activar AutoTP ]"
btn.Size = 18
btn.Color = Color3.fromRGB(255, 255, 0)
btn.Position = Vector2.new(30, 100)
btn.Visible = true
btn.Outline = true
btn.Center = false
btn.Font = 2

-- Crear notificación
local notify = Drawing.new("Text")
notify.Text = ""
notify.Size = 18
notify.Color = Color3.fromRGB(0, 255, 0)
notify.Position = Vector2.new(30, 130)
notify.Visible = false
notify.Outline = true
notify.Center = false
notify.Font = 2

local function showNotify(msg, color)
    notify.Text = msg
    notify.Color = color or Color3.fromRGB(0, 255, 0)
    notify.Visible = true
    task.delay(2, function()
        notify.Visible = false
    end)
end

-- Drag y clic
local dragging = false
local dragOffset = Vector2.zero

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position
        if mousePos.X >= btn.Position.X and mousePos.X <= btn.Position.X + 200 and
           mousePos.Y >= btn.Position.Y and mousePos.Y <= btn.Position.Y + 20 then
            dragging = true
            dragOffset = mousePos - btn.Position
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if dragging then
        dragging = false
    else
        -- Solo activar/desactivar si fue un tap corto
        local mousePos = input.Position
        if mousePos.X >= btn.Position.X and mousePos.X <= btn.Position.X + 200 and
           mousePos.Y >= btn.Position.Y and mousePos.Y <= btn.Position.Y + 20 then
            if not getgenv().autoTP then
                getgenv().coords = getHRP().Position
                getgenv().autoTP = true
                btn.Text = "[ Desactivar AutoTP ]"
                showNotify("AutoTP activado", Color3.fromRGB(0, 255, 0))
            else
                getgenv().autoTP = false
                btn.Text = "[ Activar AutoTP ]"
                showNotify("AutoTP desactivado", Color3.fromRGB(255, 0, 0))
            end
        end
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local pos = input.Position
        btn.Position = pos - dragOffset
        notify.Position = btn.Position + Vector2.new(0, 30)
    end
end)

-- Bucle de teletransporte
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
