-- Variables globales para control
getgenv().autoTP = false
getgenv().coords = nil

-- Servicios
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- Esperar personaje
local function getHRP()
    local char = player.Character or player.CharacterAdded:Wait()
    return char:WaitForChild("HumanoidRootPart")
end

local hrp = getHRP()

-- Mostrar coordenadas
local coordsText = Drawing.new("Text")
coordsText.Size = 18
coordsText.Color = Color3.fromRGB(0, 255, 0)
coordsText.Position = Vector2.new(20, 40)
coordsText.Visible = true
coordsText.Center = false
coordsText.Outline = true
coordsText.Font = 2

-- Botón "Cerrar"
local closeBtn = Drawing.new("Text")
closeBtn.Text = "[ Cerrar (Guardar y TP) ]"
closeBtn.Size = 18
closeBtn.Color = Color3.fromRGB(255, 0, 0)
closeBtn.Position = Vector2.new(20, 100)
closeBtn.Visible = true
closeBtn.Center = false
closeBtn.Outline = true
closeBtn.Font = 2

-- Botón Encender/Apagar
local toggleBtn = Drawing.new("Text")
toggleBtn.Text = "[ Apagar ]"
toggleBtn.Size = 18
toggleBtn.Color = Color3.fromRGB(255, 255, 0)
toggleBtn.Position = Vector2.new(20, 130)
toggleBtn.Visible = true
toggleBtn.Center = false
toggleBtn.Outline = true
toggleBtn.Font = 2

-- Actualizar coordenadas en pantalla
RunService.RenderStepped:Connect(function()
    if hrp and coordsText then
        local pos = hrp.Position
        coordsText.Text = string.format("Coordenadas:\nX: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
    end
end)

-- Función para verificar clics
local UserInputService = game:GetService("UserInputService")
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position

        -- Clic en botón "Cerrar"
        if mousePos.X >= closeBtn.Position.X and mousePos.X <= closeBtn.Position.X + 200 and
           mousePos.Y >= closeBtn.Position.Y and mousePos.Y <= closeBtn.Position.Y + 20 then

            -- Guardar coordenadas
            hrp = getHRP()
            getgenv().coords = hrp.Position
            getgenv().autoTP = true
            print("[Sistema] Coordenadas guardadas: ", getgenv().coords)

        -- Clic en botón "Encender/Apagar"
        elseif mousePos.X >= toggleBtn.Position.X and mousePos.X <= toggleBtn.Position.X + 200 and
               mousePos.Y >= toggleBtn.Position.Y and mousePos.Y <= toggleBtn.Position.Y + 20 then

            getgenv().autoTP = not getgenv().autoTP
            toggleBtn.Text = getgenv().autoTP and "[ Apagar ]" or "[ Encender ]"
            print("[Sistema] AutoTP:", getgenv().autoTP)
        end
    end
end)

-- Bucle de teletransporte cada 60 segundos
task.spawn(function()
    while true do
        task.wait(60)
        if getgenv().autoTP and getgenv().coords then
            hrp = getHRP()
            hrp.CFrame = CFrame.new(getgenv().coords)
            print("[Sistema] Teletransportado a coordenadas guardadas.")
        end
    end
end)
