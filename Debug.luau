local Players = game:GetService("Players")
local player = Players.LocalPlayer
local Log = "--- BUSCA DE HITBOX REAL ---\n"

-- GUI Estilizada
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_HitHunter"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 250, 0, 150)
frame.Position = UDim2.new(0.5, -125, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 100)
status.Text = "Aguardando Hit... Bata em alguém manualmente AGORA!"
status.TextColor3 = Color3.new(1, 1, 0)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
copyBtn.Text = "COPIAR DADOS DE IMPACTO"
copyBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Parent = frame

-- Função para registrar achados
local function addLog(msg)
    Log = Log .. "\n[" .. os.date("%X") .. "] " .. msg
    status.Text = "DETECTADO: " .. msg
    print(msg)
end

-- 1. Monitorar o braço (Right Arm / Right Hand)
task.spawn(function()
    while true do
        local char = player.Character
        if char then
            local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
            if hand then
                -- Verifica se surgiu algum "TouchInterest" ou "Remote" dentro da mão
                for _, obj in pairs(hand:GetChildren()) do
                    if obj:IsA("RemoteEvent") or obj:IsA("BindableEvent") then
                        addLog("Evento na Mão: " .. obj.Name)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

-- 2. Monitorar mudanças globais no momento do hit
game:GetService("RunService").Stepped:Connect(function()
    -- Se um Remote chamado 'Hit' ou algo assim aparecer em qualquer lugar, a gente pega
    for _, v in pairs(game:GetService("ReplicatedStorage"):GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("hit") or v.Name:lower():find("damage")) then
            -- Só loga se for algo novo
            if not Log:find(v.Name) then
                addLog("Novo Remote Detectado: " .. v.Name .. " em " .. v.Parent.Name)
            end
        end
    end
end)

copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Log)
        copyBtn.Text = "COPIADO!"
        task.wait(2)
        copyBtn.Text = "COPIAR DADOS"
    end
end)
