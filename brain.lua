getgenv().autoTP = false
getgenv().coords = nil

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

-- Mostrar coordenadas
local coordsText = Drawing.new("Text")
coordsText.Size = 18
coordsText.Color = Color3.fromRGB(0, 255, 0)
coordsText.Position = Vector2.new(20, 40)
coordsText.Visible = true
coordsText.Center = false
coordsText.Outline = true
coordsText.Font = 2

-- Botón único flotante
local mainBtn = Drawing.new("Text")
mainBtn.Text = "[ Guardar y Activar AutoTP ]"
mainBtn.Size = 18
mainBtn.Color = Color3.fromRGB(255, 200, 0)
mainBtn.Position = Vector2.new(20, 100)
mainBtn.Visible = true
mainBtn.Center = false
mainBtn.Outline = true
mainBtn.Font = 2

-- Actualizar coordenadas en pantalla
RunService.RenderStepped:Connect(function()
    if hrp and coordsText then
        local pos = hrp.Position
        coordsText.Text = string.format("Coordenadas:\nX: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
    end
end)

-- Verificar clics
UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        local mousePos = input.Position

        if mousePos.X >= mainBtn.Position.X and mousePos.X <= mainBtn.Position.X + 250 and
           mousePos.Y >= mainBtn.Position.Y and mousePos.Y <= mainBtn.Position.Y + 25 then

            if not getgenv().autoTP then
                -- Guardar coordenadas y activar
                hrp = getHRP()
                getgenv().coords = hrp.Position
                getgenv().autoTP = true
                mainBtn.Text = "[ Desactivar AutoTP ]"
                print("[Sistema] AutoTP activado. Coordenadas guardadas:", getgenv().coords)
            else
                -- Desactivar AutoTP
                getgenv().autoTP = false
                mainBtn.Text = "[ Guardar y Activar AutoTP ]"
                print("[Sistema] AutoTP desactivado.")
            end
        end
    end
end)

-- Bucle AutoTP
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
