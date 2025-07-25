-- === CONFIGURACIÓN ===
local GAME_ID = 109983668079237 -- ID oficial del juego Steal a Brainrot 2
local REPLIT_URL = "https://66d1c513-45e4-4df8-9e30-a8ae8a89584d-00-2di4zs538rhis.janeway.replit.dev/"
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1398405036253646849/eduChknG-GHdidQyljf3ONIvGebPSs7EqP_68sS_FV_nZc3bohUWlBv2BY3yy3iIMYmA"

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- === FUNCIONES ===
function getJobFromReplit()
    local res = syn.request({Url=REPLIT_URL, Method="GET"})
    local body = HttpService:JSONDecode(res.Body)
    return body.job
end

function reportBrainrot(jobId)
    local payload = {
        content = "",
        embeds = {{
            title = "🧠 Brainrot Detectado en Steal a Brainrot",
            color = 65280,
            fields = {
                {name="Job ID", value=jobId or "unknown"},
                {name="Cuenta", value=LocalPlayer.Name}
            }
        }}
    }
    syn.request({
        Url = DISCORD_WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"]="application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end

function detectBrainrot()
    -- Aquí defines cómo se ve: por ejemplo NPCs dentro de workspace.Brainrots
    if workspace:FindFirstChild("Brainrots") then
        for _, br in pairs(workspace.Brainrots:GetChildren()) do
            if br.ClassName == "Model" then
                return true
            end
        end
    end
    return false
end

-- === LOOP PRINCIPAL ===
while true do
    local jobId = getJobFromReplit()
    if not jobId then
        warn("✅ Sin más servidores disponibles.")
        break
    end

    print("🔁 Teleport a servidor JobID:", jobId)
    TeleportService:TeleportToPlaceInstance(GAME_ID, jobId, LocalPlayer)
    repeat wait(2) until game:IsLoaded()
    wait(3) -- espera carga de modelo

    if detectBrainrot() then
        print("✅ Brainrot encontrado!")
        reportBrainrot(jobId)
        break
    else
        print("❌ Nada detectado. Solicitando otro servidor...")
        wait(2)
    end
end
