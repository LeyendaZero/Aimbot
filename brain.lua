local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local char = player.Character or player.CharacterAdded:Wait()
local humanoid = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")

local height = 75

local function teleportOnFreefall()
    print("Esperando estado Freefall...")

    local connection
    connection = RunService.RenderStepped:Connect(function()
        if humanoid:GetState() == Enum.HumanoidStateType.Freefall then
            -- Desconectar para evitar múltiples teleports
            connection:Disconnect()

            -- Esperar un poco para asegurar sincronía
            wait(0.15)

            -- Teleport mientras estás cayendo
            hrp.CFrame = hrp.CFrame + Vector3.new(0, height, 0)
            print("✅ Teleport ejecutado durante caída")
        end
    end)

    -- Hacer que el personaje salte (caída garantizada)
    humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
end

teleportOnFreefall()
