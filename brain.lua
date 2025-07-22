local player = game.Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local root = char:WaitForChild("HumanoidRootPart")

-- Altura por encima del techo (ajústala si el techo es más alto)
local safeHeight = 200

-- Posición deseada encima del jugador
local targetPos = root.Position + Vector3.new(0, 50, 0)

-- Paso 1: teleportarse muy alto
root.CFrame = CFrame.new(targetPos.X, targetPos.Y + safeHeight, targetPos.Z)

-- Paso 2: dejar caer naturalmente (el servidor piensa que caíste desde arriba)
char.Humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
