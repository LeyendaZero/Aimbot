-- Pequeñas variaciones aleatorias en dirección del avión
RunService.Heartbeat:Connect(function()
    if not LocalPlayer.Character then return end
    local plane = LocalPlayer.Character:FindFirstChild("Plane") -- o el modelo del avión
    if not plane then return end

    local bodyVelocity = plane:FindFirstChildOfClass("BodyVelocity") or Instance.new("BodyVelocity", plane)
    bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)

    local offset = Vector3.new(
        math.random(-1,1),
        math.random(-1,1),
        math.random(-1,1)
    ) * 20 -- cambiar fuerza según tu juego

    bodyVelocity.Velocity = plane.Velocity + offset
end)
