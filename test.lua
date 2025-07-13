local player = game:GetService("Players").LocalPlayer
local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")

if not hrp then
    warn("No se encontró HumanoidRootPart")
    return
end

for _, part in pairs(workspace:GetDescendants()) do
    if part:IsA("BasePart") then
        local dist = (hrp.Position - part.Position).Magnitude
        if dist < 5 then -- partes cercanas (ajusta si es necesario)
            print("Parte cercana: ", part.Name, "| Distancia:", math.floor(dist))
        end
    end
end
