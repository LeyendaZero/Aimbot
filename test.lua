local Workspace = game:GetService("Workspace")

Workspace.ChildAdded:Connect(function(child)
    print("Nuevo objeto en Workspace: ", child.Name)
end)
