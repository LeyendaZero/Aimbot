local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Esperar a que el personaje esté cargado
if not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChildOfClass("Tool") then
    LocalPlayer.CharacterAdded:Wait()
end

local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")

if tool then
    tool.Activated:Connect(function()
        -- Buscar el proyectil tras disparar
        task.delay(0.05, function() -- pequeño retardo para dar tiempo a que aparezca
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") and obj.Name:lower():find("bullet") then
                    print("Bullet velocity:", obj.Velocity.Magnitude)
                end
            end
        end)
    end)
else
    warn("No hay arma equipada (Tool) en el personaje.")
end
