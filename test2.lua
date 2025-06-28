local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local active = true -- Puedes conectar esto a un botón GUI si quieres

RunService.Heartbeat:Connect(function()
    if not active then return end

    local char = LocalPlayer.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") then return end
    local hrp = char.HumanoidRootPart

    -- Movimiento falso suave en plano horizontal
    local t = tick()
    local vx = math.sin(t * 1.2) * 100  -- velocidad horizontal suave
    local vz = math.cos(t * 1.2) * 100
    local fakeVelocity = Vector3.new(vx, 0, vz)

    -- Aplicar solo en XZ (sin afectar altura)
    local currentY = hrp.Velocity.Y
    hrp.Velocity = Vector3.new(fakeVelocity.X, currentY, fakeVelocity.Z)
end)
