local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = "--- SCANNER DE IMPACTO V4 ---\n"

-- GUI Pro (Mantendo o estilo que você gosta)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_ImpactSniffer"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.15, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "AW - Localizador de Dano"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 80)
status.Position = UDim2.new(0.05, 0, 0.25, 0)
status.Text = "Bata em alguém MANUALMENTE até dar dano/ragdoll..."
status.TextColor3 = Color3.fromRGB(255, 255, 0)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
copyBtn.Text = "COPIAR DADOS CAPTURADOS"
copyBtn.BackgroundColor3 = Color3.fromRGB(70, 30, 120)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Parent = frame

-- Função de Log
local function addLog(tipo, info)
    local txt = string.format("[%s] %s: %s", os.date("%X"), tipo, info)
    Log = Log .. "\n" .. txt
    status.Text = "CAPTURA: " .. txt
    print(txt)
end

-- 1. Monitorar Remotes no momento exato (Scanner de disparos)
local oldNamecall
oldNamecall = hookmetamethod(game, "__namecall", function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if (method == "FireServer" or method == "InvokeServer") then
        local name = tostring(self)
        -- Se não for o 'Punch' que já conhecemos, pode ser o de dano
        if name ~= "Punch" then
            addLog("REMOTE", name .. " | Args: " .. #args)
            for i, v in pairs(args) do
                addLog("ARG["..i.."]", tostring(v) .. " (" .. type(v) .. ")")
            end
        end
    end
    return oldNamecall(self, ...)
end)

-- 2. Monitorar o que acontece no inimigo (Ragdoll/Dano)
task.spawn(function()
    while true do
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= Players.LocalPlayer and p.Character then
                -- Se o inimigo cair ou mudar de estado, o jogo mandou algo
                p.Character.ChildAdded:Connect(function(child)
                    if child.Name:lower():find("ragdoll") or child.Name:lower():find("hit") then
                        addLog("EFEITO", "Detectado no inimigo: " .. child.Name)
                    end
                end)
            end
        end
        task.wait(2)
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Log)
        copyBtn.Text = "COPIADO COM SUCESSO!"
        task.wait(2)
        copyBtn.Text = "COPIAR DADOS CAPTURADOS"
    end
end)
