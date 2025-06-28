local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Fake velocity para engañar predicción
    local fakeDirection = Vector3.new(math.random(-1,1), 0, math.random(-1,1)).Unit
    hrp.Velocity = fakeDirection * 200 -- No te mueve, pero scripts enemigos sí lo ven
end)
