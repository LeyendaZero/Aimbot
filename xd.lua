warn(string.char(76, 111, 97, 100, 101, 100) .. " " .. string.char(84, 117, 114, 114, 101, 116) .. " " .. string.char(65, 117, 116, 111) .. " " .. string.char(65, 105, 109))
local a = game:GetService("Players")
local b = a.LocalPlayer
local c = 800 -- bullet velocity you can put between 799-800
local function d()
    local e = b.Character
    return e and e:FindFirstChild("HumanoidRootPart") and (function()
        local f = e.HumanoidRootPart.Position
        local g, h = nil, math.huge
        for _, i in ipairs(a:GetPlayers()) do
            if i ~= b and i.Team ~= b.Team and i.Character and i.Character:FindFirstChild("HumanoidRootPart") then
                local j = (i.Character.HumanoidRootPart.Position - f).Magnitude
                if j < h then
                    local k = i.Character:FindFirstChildOfClass("Humanoid")
                    if k and k.Health > 0 then
                        h = j
                        g = i
                    end
                end
            end
        end
        return g
    end)()
end
local function l(m, n)
    if not m then return m.Position end
    local o = m.Velocity
    return m.Position + (o * n)
end
local function p(q)
    local r = b.Character
    if not r or not r:FindFirstChild("HumanoidRootPart") then return 0 end
    local s = r.HumanoidRootPart.Position
    local t = (q - s).Magnitude
    return t / c
end
game:GetService("RunService").Heartbeat:Connect(function()
    local u = d()
    if u then
        local v = u.Character:FindFirstChild("HumanoidRootPart")
        if v then
            local w = p(v.Position)
            local x = l(v, w)
            game:GetService("ReplicatedStorage"):WaitForChild("Event"):FireServer("aim", {x})
        end
    end
end)
