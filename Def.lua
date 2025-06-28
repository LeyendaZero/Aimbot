-- Movimiento anti-predicción
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer

local active = true

RunService.RenderStepped:Connect(function(dt)
    local char = LocalPlayer.Character
    if not active or not char or not char:FindFirstChild("HumanoidRootPart") then return end

    local hrp = char.HumanoidRootPart
    -- Cambios sutiles en dirección para alterar predicción
    local randomVec = Vector3.new(math.random(-1,1), 0, math.random(-1,1)) * 5
    hrp.Velocity = hrp.Velocity + randomVec
end)
