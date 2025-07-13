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

-- Crear fondo del botón
local btnBg = Drawing.new("Square")
btnBg.Size = Vector2.new(220, 25)
btnBg.Position = Vector2.new(40, 120)
btnBg.Color = Color3.fromRGB(30, 30, 30)
btnBg.Thickness = 1
btnBg.Transparency = 0.6
btnBg.Filled = true
btnBg.Visible = true

-- Crear texto del botón
local btn = Drawing.new("Text")
btn.Text = "[ Activar AutoTP ]"
btn.Size = 18
btn.Color = Color3.fromRGB(255, 255, 0)
btn.Position = btnBg.Position + Vector2.new(5, 3)
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
    notify.Position = btnBg.Position + Vector2.new(0, 30)
    notify.Visible = true
    task.delay(2, function()
        notify.Visible = false
    end)
end

-- Detección de tap (táctil y mouse)
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        local btnX, btnY = btnBg.Position.X, btnBg.Position.Y
        local width, height = btnBg.Size.X, btnBg.Size.Y

        if pos.X >= btnX and pos.X <= btnX + width and
           pos.Y >= btnY and pos.Y <= btnY + height then
           
           -- Alternar AutoTP
           if not getgenv().autoTP then
               local hrp = getHRP()
               getgenv().coords = hrp.Position
               getgenv().autoTP = true
               btn.Text = "[ Desactivar AutoTP ]"
               btn.Color = Color3.fromRGB(0, 255, 0)
               showNotify("AutoTP activado")
           else
               getgenv().autoTP = false
               btn.Text = "[ Activar AutoTP ]"
               btn.Color = Color3.fromRGB(255, 255, 0)
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
