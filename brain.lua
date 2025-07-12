local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local hrp = character:WaitForChild("HumanoidRootPart")

-- Crear texto en pantalla
local coordsText = Drawing.new("Text")
coordsText.Size = 18
coordsText.Color = Color3.fromRGB(0, 255, 0)
coordsText.Position = Vector2.new(20, 40)
coordsText.Visible = true
coordsText.Center = false
coordsText.Outline = true
coordsText.Font = 2 -- UI font

-- Actualizar coordenadas en cada frame
RunService.RenderStepped:Connect(function()
    local pos = hrp.Position
    coordsText.Text = string.format("Coordenadas:\nX: %.2f\nY: %.2f\nZ: %.2f", pos.X, pos.Y, pos.Z)
end)
