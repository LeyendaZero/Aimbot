RunService.RenderStepped:Connect(function()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        print("Mi velocidad actual:", hrp.Velocity.Magnitude)
    end
end)
