local mt = getrawmetatable(game)
setreadonly(mt, false)
local old = mt.__namecall

mt.__namecall = function(self, ...)
    local args = {...}
    if tostring(self) == "ChatEvent" and getnamecallmethod() == "FireServer" then
        print("Interceptado mensaje:", args[1]) -- args[1] podría ser el mensaje
    end
    return old(self, unpack(args))
end
