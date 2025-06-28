local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local active = true -- puedes atarlo a un botón si quieres

RunService.Heartbeat:Connect(function()
    if not active then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Generar una "velocidad falsa" fluida
    local t = tick()
    local vx = math.sin(t * 1.2) * 300
    local vz = math.cos(t * 1.2) * 300
    local fakeVelocity = Vector3.new(vx, 0, vz)

    -- Aplicar sin moverte realmente
    hrp.Velocity = fakeVelocity
end)
