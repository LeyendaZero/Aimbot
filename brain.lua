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

-- Crear botón flotante
local btn = Drawing.new("Text")
btn.Text = "[ Activar AutoTP ]"
btn.Size = 18
btn.Color = Color3.fromRGB(255, 255, 0)
btn.Position = Vector2.new(40, 120)
btn.Visible = true
btn.Outline = true
btn.Center = false
btn.Font = 2

-- Notificación flotante
local notify = Drawing.new("Text")
notify.Size = 18
notify.Color = Color3.fromRGB(0, 255, 0)
notify.Position = Vector2.new(40, 145)
notify.Visible = false
notify.Outline = true
notify.Center = false
notify.Font = 2

-- Mostrar mensaje en pantalla
local function showNotify(text, color)
    notify.Text = text
    notify.Color = color or Color3.fromRGB(0, 255, 0)
    notify.Position = btn.Position + Vector2.new(0, 25)
    notify.Visible = true
    task.delay(2, function()
        notify.Visible = false
    end)
end

-- Detección de tap (táctil y mouse)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local btnX, btnY = btn.Position.X, btn.Position.Y
        local width, height = 220, 25

        if pos.X >= btnX and pos.X <= btnX + width and
           pos.Y >= btnY and pos.Y <= btnY + height then
           
           -- Alternar AutoTP
           if not getgenv().autoTP then
               local hrp = getHRP()
               getgenv().coords = hrp.Position
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

-- Bucle de TP cada 60s
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().autoTP and getgenv().coords then
            pcall(function()
                local hrp = getHRP()
                hrp.CFrame = CFrame.new(getgenv().coords)
                showNotify("¡Teletransportado!", Color3.fromRGB(0, 200, 255))
            end)
        end
    end
end)
