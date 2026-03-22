local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.AutoSlap = true
local RANGE_DESEJADO = 12 -- Distância do tapa
local VELOCIDADE = 0.35 -- Cooldown padrão do jogo

local punchEvent = ReplicatedStorage:WaitForChild("Remote Events"):WaitForChild("Punch")

-- GUI (Limpa e funcional)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_GhostHit"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
frame.Draggable = true
frame.Active = true
frame.Parent = screenGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.Text = "GHOST HIT: ON"
btn.BackgroundColor3 = Color3.fromRGB(0, 150, 100)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    _G.AutoSlap = not _G.AutoSlap
    btn.Text = _G.AutoSlap and "GHOST HIT: ON" or "GHOST HIT: OFF"
    btn.BackgroundColor3 = _G.AutoSlap and Color3.fromRGB(0, 150, 100) or Color3.fromRGB(150, 0, 0)
end)

-- Loop de Ataque
task.spawn(function()
    while true do
        if _G.AutoSlap and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(Players:GetPlayers()) do
                if v ~= player and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                    local inimigo = v.Character
                    local dist = (player.Character.HumanoidRootPart.Position - inimigo.HumanoidRootPart.Position).Magnitude
                    
                    if dist <= RANGE_DESEJADO then
                        -- 1. Dispara o Remote de Soco (Animação/Aviso)
                        punchEvent:FireServer()
                        
                        -- 2. "GHOST TOUCH": Teleporta a mão pro inimigo por 0.01s
                        local hand = player.Character:FindFirstChild("RightHand") or player.Character:FindFirstChild("Right Arm")
                        if hand then
                            local originalPos = hand.CFrame
                            hand.CFrame = inimigo.HumanoidRootPart.CFrame -- Mão vai no inimigo
                            firetouchinterest(inimigo.HumanoidRootPart, hand, 0)
                            task.wait(0.01)
                            firetouchinterest(inimigo.HumanoidRootPart, hand, 1)
                            hand.CFrame = originalPos -- Mão volta
                        end
                        
                        task.wait(VELOCIDADE)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
