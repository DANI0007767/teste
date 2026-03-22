local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.AutoSlap = true
local TAMANHO_HITBOX = Vector3.new(15, 15, 15) -- O quão longe o tapa alcança
local COOLDOWN = 0.4

local punchEvent = ReplicatedStorage:WaitForChild("Remote Events"):WaitForChild("Punch")

-- GUI
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_Reach_V6"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 0, 0)
frame.Draggable = true
frame.Active = true
frame.Parent = screenGui

local btn = Instance.new("TextButton")
btn.Size = UDim2.new(0.9, 0, 0, 40)
btn.Position = UDim2.new(0.05, 0, 0.3, 0)
btn.Text = "REACH: ATIVADO"
btn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
btn.TextColor3 = Color3.new(1, 1, 1)
btn.Parent = frame

btn.MouseButton1Click:Connect(function()
    _G.AutoSlap = not _G.AutoSlap
    btn.Text = _G.AutoSlap and "REACH: ATIVADO" or "REACH: DESATIVADO"
    btn.BackgroundColor3 = _G.AutoSlap and Color3.fromRGB(200, 0, 0) or Color3.fromRGB(50, 50, 50)
end)

-- Função para estender a mão
local function expandirMao()
    local char = player.Character
    if char then
        local hand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
        if hand then
            hand.Size = TAMANHO_HITBOX
            hand.Transparency = 0.8 -- Fica um pouco visível para você ver o alcance (mude para 1 para invisível)
            hand.CanCollide = false
            hand.Massless = true
        end
    end
end

-- Loop de Soco
task.spawn(function()
    while true do
        if _G.AutoSlap then
            expandirMao() -- Garante que a mão está grande
            
            -- Dispara o soco
            punchEvent:FireServer()
            
            -- Animação
            local hum = player.Character:FindFirstChild("Humanoid")
            if hum then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://8266542505"
                hum:LoadAnimation(anim):Play()
            end
            
            task.wait(COOLDOWN)
        else
            -- Reseta a mão se desligar
            local hand = player.Character and (player.Character:FindFirstChild("RightHand") or player.Character:FindFirstChild("Right Arm"))
            if hand then hand.Size = Vector3.new(1, 1, 1) hand.Transparency = 0 end
        end
        task.wait(0.1)
    end
end)
