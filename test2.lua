local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local active = true -- Puedes cambiarlo con un botón si quieres
local fakeVelocityMagnitude = 100 -- Cambia esto para más o menos predicción

RunService.Heartbeat:Connect(function()
    if not active then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end

    -- Solo aplicar anti-predicción si estás completamente quieto
    if humanoid.MoveDirection.Magnitude == 0 then
        local t = tick()
        local vx = math.sin(t * 1.2) * fakeVelocityMagnitude
        local vz = math.cos(t * 1.2) * fakeVelocityMagnitude

        -- Aplicar fake solo horizontalmente sin alterar tu control
        hrp.Velocity = Vector3.new(vx, hrp.Velocity.Y, vz)
    end
end)
