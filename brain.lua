local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Crear BodyVelocity
local bv = Instance.new("BodyVelocity")
bv.Velocity = Vector3.new(0, 100, 0) -- Velocidad hacia arriba
bv.MaxForce = Vector3.new(0, 1e6, 0)
bv.P = 1e4
bv.Parent = root

-- Esperar hasta alcanzar la altura
task.wait(0.5) -- ajusta según resultado

-- Eliminar para evitar caída infinita
bv:Destroy()
