local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

-- Encuentra al enemigo más cercano
local function GetClosestEnemy()
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return nil end
    local myPos = character.HumanoidRootPart.Position

    local closest = nil
    local minDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local enemyHRP = player.Character.HumanoidRootPart
            local distance = (enemyHRP.Position - myPos).Magnitude
            local humanoid = player.Character:FindFirstChildOfClass("Humanoid")

            if humanoid and humanoid.Health > 0 and distance < minDistance then
                minDistance = distance
                closest = player
            end
        end
    end

    return closest
end

-- Loop para apuntar al enemigo
RunService.RenderStepped:Connect(function()
    local enemy = GetClosestEnemy()
    if enemy and enemy.Character and enemy.Character:FindFirstChild("HumanoidRootPart") then
        local targetPos = enemy.Character.HumanoidRootPart.Position
        workspace.CurrentCamera.CFrame = CFrame.new(workspace.CurrentCamera.CFrame.Position, targetPos)
    end
end)
