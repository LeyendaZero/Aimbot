local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool")
local bullet = nil

tool.Activated:Connect(function()
    bullet = workspace:FindFirstChild("Bullet") -- o el nombre real
    if bullet then
        print("Bullet velocity:", bullet.Velocity.Magnitude)
    end
end)
