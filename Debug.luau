local Players = game:GetService("Players")
local VirtualUser = game:GetService("VirtualUser")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.AutoSlap = true -- Mude para false para desligar

-- GUI SIMPLES E BONITA
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbilityWarsAutoSlap"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true -- Você pode mover ela
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Ability Wars - Slap"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
title.Parent = frame

local statusBtn = Instance.new("TextButton")
statusBtn.Size = UDim2.new(0.8, 0, 0, 40)
statusBtn.Position = UDim2.new(0.1, 0, 0.45, 0)
statusBtn.Text = "STATUS: LIGADO"
statusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
statusBtn.TextColor3 = Color3.new(1, 1, 1)
statusBtn.Parent = frame

-- Lógica de Ligar/Desligar
statusBtn.MouseButton1Click:Connect(function()
    _G.AutoSlap = not _G.AutoSlap
    if _G.AutoSlap then
        statusBtn.Text = "STATUS: LIGADO"
        statusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0)
    else
        statusBtn.Text = "STATUS: DESLIGADO"
        statusBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    end
end)

-- LOOP DO TAPA (Sem bugar o Touch)
task.spawn(function()
    while true do
        if _G.AutoSlap then
            -- Simulando o clique via VirtualUser (Não interfere no touch manual)
            VirtualUser:CaptureController()
            VirtualUser:ClickButton1(Vector2.new(0, 0))
            
            -- Se o VirtualUser falhar no Delta, usamos a ativação forçada:
            local char = player.Character
            if char then
                local tool = char:FindFirstChildOfClass("Tool")
                if tool then
                    tool:Activate()
                end
            end
        end
        task.wait(0.1) -- Velocidade do tapa
    end
end)
