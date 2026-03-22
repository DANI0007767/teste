local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = game.Players.LocalPlayer

-- CONFIGURAÇÃO
_G.AutoSlap = true
local VELOCIDADE = 0.15 -- Ajuste aqui (0.1 é muito rápido, 0.2 é mais seguro)

-- Localizando o Evento de Soco que você encontrou
local remoteEvents = ReplicatedStorage:WaitForChild("Remote Events")
local punchEvent = remoteEvents:WaitForChild("Punch")

-- GUI SIMPLES (Mesmo estilo, mas sem travar)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_Final_Punch"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 180, 0, 90)
frame.Position = UDim2.new(0.5, -90, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local statusBtn = Instance.new("TextButton")
statusBtn.Size = UDim2.new(0.9, 0, 0, 40)
statusBtn.Position = UDim2.new(0.05, 0, 0.3, 0)
statusBtn.Text = "AUTO-PUNCH: ON"
statusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
statusBtn.TextColor3 = Color3.new(1, 1, 1)
statusBtn.Parent = frame

-- Alternar Ligar/Desligar
statusBtn.MouseButton1Click:Connect(function()
    _G.AutoSlap = not _G.AutoSlap
    statusBtn.Text = _G.AutoSlap and "AUTO-PUNCH: ON" or "AUTO-PUNCH: OFF"
    statusBtn.BackgroundColor3 = _G.AutoSlap and Color3.fromRGB(0, 150, 80) or Color3.fromRGB(150, 0, 0)
end)

-- LOOP DE DISPARO DIRETO
task.spawn(function()
    while true do
        if _G.AutoSlap then
            -- Dispara o soco diretamente pro servidor
            punchEvent:FireServer()
            
            -- Opcional: Tocar a animação localmente apenas para você ver o braço mexer
            -- Se bugar, podemos remover essa linha
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") then
                local anim = Instance.new("Animation")
                anim.AnimationId = "rbxassetid://8266542505"
                char.Humanoid:LoadAnimation(anim):Play()
            end
        end
        task.wait(VELOCIDADE)
    end
end)
