local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")
local workspace = game:GetService("Workspace")

-- Posición deseada encima del personaje (ajustar si hay techo)
local basePos = root.Position + Vector3.new(0, 50, 0)
local fallHeight = 100  -- Cuánto más alto caerás desde
local dropPos = basePos + Vector3.new(0, fallHeight, 0)

-- Crear plataforma invisible en destino
local platform = Instance.new("Part")
platform.Size = Vector3.new(5, 1, 5)
platform.Anchored = true
platform.CanCollide = true
platform.Transparency = 1  -- Invisible
platform.Position = basePos
platform.Parent = workspace

-- Teleportarte arriba
task.wait(0.1)
root.CFrame = CFrame.new(dropPos)
char.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)

-- Esperar a que "caigas" sobre la plataforma
task.wait(0.6) -- Ajusta si el retardo del anticheat es más corto/largo

-- Destruir plataforma (opcional)
platform:Destroy()
