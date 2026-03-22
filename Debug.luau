local LPH_NO_VIRTUALIZE = function(...) return ... end
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = ""

-- GUI Simples
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugScanner"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Scanner de Slap/Remotes"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundTransparency = 1
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 70)
status.Position = UDim2.new(0, 0, 0, 30)
status.Text = "Dê alguns tapas no jogo..."
status.TextColor3 = Color3.fromRGB(0, 255, 100)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 30)
copyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
copyBtn.Text = "COPIAR LOGS"
copyBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Parent = frame

-- Função para registrar logs
local function addLog(msg)
    Log = Log .. "\n[" .. os.date("%X") .. "] " .. msg
    status.Text = "Capturado: " .. msg
    print(msg)
end

-- Hook para detectar disparos de Remotes
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", LPH_NO_VIRTUALIZE(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") then
        local remoteName = tostring(self)
        -- Filtra coisas comuns pra não poluir, foca em ataque/clique
        if remoteName:lower():find("click") or remoteName:lower():find("slap") or remoteName:lower():find("punch") or remoteName:lower():find("attack") or remoteName:lower():find("hit") then
            addLog("Remote: " .. remoteName .. " | Args: " .. #args)
        end
    end
    return oldNamecall(self, ...)
end))

-- Botão de copiar
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Log)
        copyBtn.Text = "COPIADO!"
        task.wait(2)
        copyBtn.Text = "COPIAR LOGS"
    else
        status.Text = "Seu executor não suporta setclipboard!"
    end
end)

addLog("Scanner Iniciado. Aguardando input...")
