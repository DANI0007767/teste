local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = "--- INVESTIGAÇÃO DE REDE AB ---\n"

-- GUI (Segura e sem bugs de foco)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_Investigator"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 180)
frame.Position = UDim2.new(0.5, -140, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "AW - Localizador de Hitbox"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 90)
status.Position = UDim2.new(0.05, 0, 0.2, 0)
status.Text = "Dê tapas em ALGUÉM na arena para capturar o evento de dano..."
status.TextColor3 = Color3.fromRGB(255, 200, 0)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
copyBtn.Text = "COPIAR DADOS DE HIT"
copyBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 150)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Parent = frame

-- Função de Log
local function addLog(msg)
    Log = Log .. "\n" .. msg
    status.Text = "CAPTURADO: " .. msg
    print(msg)
end

-- HOOK DE METAMÉTODO (O mais avançado para executores mobile)
-- Ele "grampeia" a conexão do jogo com o servidor
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Se o jogo tentar enviar uma mensagem de "Ataque" ou "Hit" para o servidor
    if (method == "FireServer" or method == "InvokeServer") then
        local name = tostring(self)
        
        -- Filtramos apenas o que interessa para o tapa
        -- No Ability Wars costuma ser 'Hit', 'H' ou algo dentro de uma pasta de 'Remotes'
        addLog("Remote: " .. name .. " | Args: " .. #args)
        
        -- Se houver argumentos (como o jogador que você bateu), vamos detalhar
        for i, v in pairs(args) do
            addLog("Arg["..i.."]: " .. tostring(v) .. " (" .. type(v) .. ")")
        end
    end
    
    return oldNamecall(self, ...)
end)

-- Botão Copiar
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Log)
        copyBtn.Text = "LOG COPIADO!"
        task.wait(2)
        copyBtn.Text = "COPIAR DADOS DE HIT"
    else
        status.Text = "Use o console do Delta para copiar."
    end
end)
