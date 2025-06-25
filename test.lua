local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Interfaz para mostrar la velocidad
local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
screenGui.Name = "BulletSpeedDisplay"

local textLabel = Instance.new("TextLabel", screenGui)
textLabel.Size = UDim2.new(0, 300, 0, 50)
textLabel.Position = UDim2.new(0, 20, 0, 20)
textLabel.BackgroundTransparency = 1
textLabel.TextColor3 = Color3.new(1, 1, 1)
textLabel.TextScaled = true
textLabel.Font = Enum.Font.SourceSansBold
textLabel.Text = "Velocidad: Esperando..."

-- Calcula la velocidad de una bala (cuando aparece)
Workspace.ChildAdded:Connect(function(child)
    if child:IsA("Part") and child.Name == "Bullet" then
        local startTime = tick()
        local startPos = child.Position

        -- Espera un corto tiempo para que la bala se mueva
        wait(0.1)

        if child and child.Parent then
            local endTime = tick()
            local endPos = child.Position

            local distance = (endPos - startPos).Magnitude
            local timeElapsed = endTime - startTime

            if timeElapsed > 0 then
                local speed = distance / timeElapsed
                textLabel.Text = string.format("Velocidad: %.2f studs/seg", speed)
            end
        end
    end
end)
