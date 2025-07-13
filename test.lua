local Players = game:GetService("Players")
local player = Players.LocalPlayer
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

if not hrp then
    warn("No se encontró HumanoidRootPart")
    return
end

local nearbyParts = workspace:GetPartBoundsInBox(hrp.CFrame, Vector3.new(4, 2, 4))

print("=== PARTES DEBAJO DEL JUGADOR ===")
for _, part in pairs(nearbyParts) do
    if part:IsA("BasePart") then
        print("Nombre:", part.Name)
        print("Clase:", part.ClassName)
        print("Color:", part.Color)
        print("Transparencia:", part.Transparency)
        print("Material:", part.Material)
        print("Padre:", part.Parent and part.Parent.Name)
        
        -- Si tiene texto (como SurfaceGui o BillboardGui con TextLabel)
        for _, gui in pairs(part:GetDescendants()) do
            if gui:IsA("TextLabel") or gui:IsA("TextBox") then
                print("Texto:", gui.Text)
            end
        end

        print("------------------------")
    end
end
