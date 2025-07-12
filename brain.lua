getgenv().autoTP = false
getgenv().coords = nil

local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Esperar HumanoidRootPart
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local hrp = getHRP()

-- Botón flotante
local mainBtn = Drawing.new("Text")
mainBtn.Text = "[ Guardar y Activar AutoTP ]"
mainBtn.Size = 18
mainBtn.Color = Color3.fromRGB(255, 255, 0)
mainBtn.Position = Vector2.new(20, 100)
mainBtn.Visible = true
mainBtn.Center = false
mainBtn.Outline = true
mainBtn.Font = 2

-- Mensaje flotante temporal
local notify = Drawing.new("Text")
notify.Size = 18
notify.Color = Color3.fromRGB(0, 255, 0)
notify.Position = Vector2.new(20, 130)
notify.Visible = false
notify.Center = false
notify.Outline = true
notify.Font = 2

-- Función para mostrar mensaje temporal
local function showNotify(text, color)
    notify.Text = text
    notify.Color = color or Color3.fromRGB(0, 255, 0)
    notify.Visible = true
    task.delay(2, function()
        notify.Visible = false
    end)
end

-- Drag variables
local dragging = false
local dragOffset = Vector2.new()

-- Detectar drag + click
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        local pos = input.Position
        if pos.X >= mainBtn.Position.X and pos.X <= mainBtn.Position.X + 250 and
           pos.Y >= mainBtn.Position.Y and pos.Y <= mainBtn.Position.Y + 25 then
            dragging = true
            dragOffset = pos - mainBtn.Position
        end
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
        if dragging then
            dragging = false
        else
            -- Toggle autoTP
            if not getgenv().autoTP then
                hrp = getHRP()
                getgenv().coords = hrp.Position
                getgenv().autoTP = true
                mainBtn.Text = "[ Desactivar AutoTP ]"
                showNotify("AutoTP activado", Color3.fromRGB(0, 255, 0))
            else
                getgenv().autoTP = false
                mainBtn.Text = "[ Guardar y Activar AutoTP ]"
                showNotify("AutoTP desactivado", Color3.fromRGB(255, 50, 50))
            end
        end
    end
end)

-- Mientras arrastra
UserInputService.InputChanged:Connect(function(input)
    if dragging and (input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseMovement) then
        local pos = input.Position
        mainBtn.Position = pos - dragOffset
        notify.Position = mainBtn.Position + Vector2.new(0, 30)
    end
end)

-- Teletransporte automático
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().autoTP and getgenv().coords then
            hrp = getHRP()
            hrp.CFrame = CFrame.new(getgenv().coords)
            showNotify("Teletransportado!", Color3.fromRGB(0, 200, 255))
        end
    end
end)
