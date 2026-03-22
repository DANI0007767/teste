local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIG
_G.Aura = true
local RANGE = 12
local COOLDOWN = 0.4 -- Tempo original do jogo para evitar detecção

local punchEvent = ReplicatedStorage:WaitForChild("Remote Events"):WaitForChild("Punch")

-- GUI (Mantendo o seu estilo)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_VelocityAura"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.Text = "VELOCITY AURA: ON"
btn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    _G.Aura = not _G.Aura
    btn.Text = _G.Aura and "VELOCITY AURA: ON" or "OFF"
    btn.BackgroundColor3 = _G.Aura and Color3.fromRGB(0, 120, 255) or Color3.fromRGB(150, 0, 0)
end)

-- Loop de Hit Real
task.spawn(function()
    while true do
        if _G.Aura and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= player and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                    local target = p.Character
                    local dist = (player.Character.HumanoidRootPart.Position - target.HumanoidRootPart.Position).Magnitude
                    
                    if dist <= RANGE then
                        -- 1. Inicia o soco
                        punchEvent:FireServer()
                        
                        -- 2. O segredo: Empurra o seu personagem levemente para o alvo
                        -- Isso faz a física do Roblox "esfregar" sua mão no inimigo
                        local direction = (target.HumanoidRootPart.Position - player.Character.HumanoidRootPart.Position).Unit
                        player.Character.HumanoidRootPart.Velocity = direction * 30
                        
                        -- 3. Força o toque físico
                        local hand = player.Character:FindFirstChild("RightHand") or player.Character:FindFirstChild("Right Arm")
                        if hand then
                            firetouchinterest(target.HumanoidRootPart, hand, 0)
                            task.wait(0.05)
                            firetouchinterest(target.HumanoidRootPart, hand, 1)
                        end
                        
                        task.wait(COOLDOWN)
                    end
                end
            end
        end
        task.wait(0.1)
    end
end)
