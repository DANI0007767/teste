local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.Aura = true
local RANGE = 15 -- Distância do tapa
local COOLDOWN = 0.35 -- Velocidade permitida pelo jogo

-- Evento de soco que descobrimos
local punchEvent = ReplicatedStorage:WaitForChild("Remote Events"):WaitForChild("Punch")

-- GUI (Estável e Móvel)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_TrueHit"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.Text = "KILLAURA: LIGADO"
btn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    _G.Aura = not _G.Aura
    btn.Text = _G.Aura and "KILLAURA: LIGADO" or "KILLAURA: DESLIGADO"
    btn.BackgroundColor3 = _G.Aura and Color3.fromRGB(0, 180, 100) or Color3.fromRGB(150, 0, 0)
end)

-- Função para simular o toque (O segredo do Hit)
local function simulateTouch(targetPart)
    local myHand = player.Character:FindFirstChild("RightHand") or player.Character:FindFirstChild("Right Arm")
    if myHand and targetPart then
        -- Simula que a mão tocou no oponente e depois parou de tocar
        firetouchinterest(targetPart, myHand, 0)
        task.wait()
        firetouchinterest(targetPart, myHand, 1)
    end
end

-- Loop de Ataque
task.spawn(function()
    while true do
        if _G.Aura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    
                    if dist <= RANGE then
                        -- 1. Inicia o soco no servidor
                        punchEvent:FireServer()
                        
                        -- 2. Simula o toque físico em todas as partes do inimigo
                        simulateTouch(p.Character:FindFirstChild("HumanoidRootPart"))
                        simulateTouch(p.Character:FindFirstChild("Head"))
                        
                        -- 3. Animação local
                        local hum = player.Character:FindFirstChild("Humanoid")
                        if hum then
                            local anim = Instance.new("Animation")
                            anim.AnimationId = "rbxassetid://8266542505"
                            hum:LoadAnimation(anim):Play()
                        end
                        
                        task.wait(COOLDOWN)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
