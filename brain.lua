-- ⚙️ CONFIGURACIÓN
local GAME_ID = 109983668079237
local JOB_LIST_URL = "https://leyendazero.github.io/StealBrainrot/joblist.json" -- 🔁 Pega aquí tu link
local DISCORD_WEBHOOK = "https://discord.com/api/webhooks/1398405036253646849/eduChknG-GHdidQyljf3ONIvGebPSs7EqP_68sS_FV_nZc3bohUWlBv2BY3yy3iIMYmA"

local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- 📡 FUNCIONES

-- 🔐 Selección automática de función de request
local requestFunc = (syn and syn.request) or (http and http.request) or (http_request) or (fluxus and fluxus.request)
if not requestFunc then
    warn("❌ Tu ejecutor no soporta funciones HTTP.")
    return
end

function getJobsFromGitHub()
    local response = requestFunc({
        Url = JOB_LIST_URL,
        Method = "GET"
    })
    local data = game:GetService("HttpService"):JSONDecode(response.Body)
    return data.jobs
end
-- ////////)/)final///////
function reportBrainrot(jobId, position)
    local payload = {
        content = "",
        embeds = {{
            title = "🧠 Brainrot Detectado Cerca",
            description = "¡Se encontró un Brainrot dentro de 20 studs!",
            color = 65280,
            fields = {
                { name = "Job ID", value = jobId },
                { name = "Cuenta", value = LocalPlayer.Name },
                { name = "Posición", value = tostring(position) }
            }
        }}
    }

    syn.request({
        Url = DISCORD_WEBHOOK,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode(payload)
    })
end

function detectNearbyBrainrot(radius)
    if not workspace:FindFirstChild("Brainrots") then return false end
    local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not root then return false end

    for _, br in pairs(workspace.Brainrots:GetChildren()) do
        if br:IsA("Model") and br:FindFirstChild("HumanoidRootPart") then
            local dist = (br.HumanoidRootPart.Position - root.Position).Magnitude
            if dist <= radius then
                return true, br.HumanoidRootPart.Position
            end
        end
    end
    return false
end

-- 🔁 LOOP PRINCIPAL

local jobs = getJobsFromGitHub()
for _, jobId in ipairs(jobs) do
    print("🔁 Saltando a JobID:", jobId)
    TeleportService:TeleportToPlaceInstance(GAME_ID, jobId, LocalPlayer)
    repeat wait(2) until game:IsLoaded()
    wait(3)

    local found, pos = detectNearbyBrainrot(20)
    if found then
        print("✅ Brainrot cercano detectado.")
        reportBrainrot(jobId, pos)
        break
    else
        print("❌ No hay brainrots cerca. Continuando...")
        wait(2)
    end
end

