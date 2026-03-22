local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.AutoSlap = true
local DISTANCIA_HIT = 12 -- Distância para o soco pegar (Range)
local COOLDOWN = 0.35 -- Tempo entre socos (Aumentado para o servidor aceitar)

-- Localizando o Evento
local remoteEvents = ReplicatedStorage:WaitForChild("Remote Events")
local punchEvent = remoteEvents:WaitForChild("Punch")

-- Função para achar o inimigo mais próximo
local function getClosestPlayer()
    local closest = nil
    local dist = DISTANCIA_HIT
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            local d = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                closest = p.Character
            end
        end
    end
    return closest
end

-- GUI (Mesmo estilo, funcional e móvel)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_Killaura_V4"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local statusBtn = Instance.new("TextButton")
statusBtn.Size = UDim2.new(0.9, 0, 0, 40)
statusBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
statusBtn.Text = "KILLAURA: ON"
statusBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
statusBtn.TextColor3 = Color3.new(1, 1, 1)
statusBtn.Parent = frame

statusBtn.MouseButton1Click:Connect(function()
    _G.AutoSlap = not _G.AutoSlap
    statusBtn.Text = _G.AutoSlap and "KILLAURA: ON" or "KILLAURA: OFF"
    statusBtn.BackgroundColor3 = _G.AutoSlap and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(150, 0, 0)
end)

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        if _G.AutoSlap and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local target = getClosestPlayer()
            
            -- Se tiver alguém perto, a gente ataca
            if target then
                -- 1. Dispara o soco (O servidor agora deve validar pois tem um alvo perto)
                -- Tentamos disparar o Punch passando o alvo, caso o jogo peça isso
                punchEvent:FireServer(target.HumanoidRootPart) 
                punchEvent:FireServer() -- E dispara puro também por garantia
                
                -- 2. Animação Visual
                local hum = player.Character:FindFirstChild("Humanoid")
                if hum then
                    local anim = Instance.new("Animation")
                    anim.AnimationId = "rbxassetid://8266542505"
                    hum:LoadAnimation(anim):Play()
                end
                
                task.wait(COOLDOWN) -- Espera o tempo do soco terminar
            end
        end
        task.wait(0.1) -- Procura inimigos 10 vezes por segundo
    end
end)
