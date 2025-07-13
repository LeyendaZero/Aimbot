-- Asumiendo que la parte se llama "TeleportButton"
local teleportPart = workspace:WaitForChild("TeleportButton") -- reemplaza con el nombre correcto

local alreadyTouched = false -- para evitar spam de toques

teleportPart.Touched:Connect(function(hit)
    if not getgenv().autoTP then return end -- solo si AutoTP está activado

    local character = player.Character
    if character and hit:IsDescendantOf(character) and not alreadyTouched then
        alreadyTouched = true

        -- Teletransportar
        pcall(function()
            local hrp = getHRP()
            hrp.CFrame = CFrame.new(getgenv().coords)
            showNotify("¡Teletransportado por botón!", Color3.fromRGB(255, 100, 0))
        end)

        task.delay(2, function()
            alreadyTouched = false
        end)
    end
end)
