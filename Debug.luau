local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.Aura = true
local RANGE = 15 -- Alcance do hit
local COOLDOWN = 0.3 -- Velocidade que o servidor aceita

local punchEvent = ReplicatedStorage:WaitForChild("Remote Events"):WaitForChild("Punch")

-- GUI (Estilo que você prefere)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_SecretHit"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.Text = "SECRET AURA: ON"
btn.BackgroundColor3 = Color3.fromRGB(100, 0, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    _G.Aura = not _G.Aura
    btn.Text = _G.Aura and "SECRET AURA: ON" or "OFF"
    btn.BackgroundColor3 = _G.Aura and Color3.fromRGB(100, 0, 255) or Color3.fromRGB(50, 50, 50)
end)

-- Função para o Hit Invisível
local function hitInvisivel(targetChar)
    local hand = player.Character:FindFirstChild("RightHand") or player.Character:FindFirstChild("Right Arm")
    local targetPart = targetChar:FindFirstChild("HumanoidRootPart")
    
    if hand and targetPart then
        -- O SEGREDO: Dispara o soco e o toque ao mesmo tempo
        punchEvent:FireServer()
        
        -- firetouchinterest simula o impacto físico
        -- Tentamos em múltiplas partes para garantir o ragdoll
        firetouchinterest(targetPart, hand, 0)
        task.wait()
        firetouchinterest(targetPart, hand, 1)
        
        local head = targetChar:FindFirstChild("Head")
        if head then
            firetouchinterest(head, hand, 0)
            firetouchinterest(head, hand, 1)
        end
    end
end

-- Loop Principal
task.spawn(function()
    while true do
        if _G.Aura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local closest = nil
            local lastDist = RANGE
            
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local dist = (player.Character.HumanoidRootPart.Position - p.Character.HumanoidRootPart.Position).Magnitude
                    if dist < lastDist then
                        lastDist = dist
                        closest = p.Character
                    end
                end
            end
            
            if closest then
                hitInvisivel(closest)
                task.wait(COOLDOWN)
            end
        end
        task.wait(0.1)
    end
end)
