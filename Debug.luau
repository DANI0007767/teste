local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer

-- CONFIGURAÇÃO
_G.AutoSlap = true

-- GUI (Mantendo o estilo que você gostou)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AbilityWarsFinal"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 200, 0, 100)
frame.Position = UDim2.new(0.5, -100, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local statusBtn = Instance.new("TextButton")
statusBtn.Size = UDim2.new(0.9, 0, 0, 40)
statusBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
statusBtn.Text = "AUTO-SLAP: LIGADO"
statusBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 50)
statusBtn.TextColor3 = Color3.new(1, 1, 1)
statusBtn.Parent = frame

statusBtn.MouseButton1Click:Connect(function()
    _G.AutoSlap = not _G.AutoSlap
    statusBtn.Text = _G.AutoSlap and "AUTO-SLAP: LIGADO" or "AUTO-SLAP: DESLIGADO"
    statusBtn.BackgroundColor3 = _G.AutoSlap and Color3.fromRGB(0, 180, 50) or Color3.fromRGB(180, 0, 0)
end)

-- FUNÇÃO QUE DISPARA O TAPA REAL
local function darTapaReal()
    local char = player.Character
    if not char then return end

    -- 1. Forçar a Animação que vimos nos logs (Isso engana o sistema de anti-cheat)
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        local anim = Instance.new("Animation")
        anim.AnimationId = "rbxassetid://8266542505"
        local load = hum:LoadAnimation(anim)
        load:Play()
    end

    -- 2. Disparar o Remote que o Ability Wars usa para socar
    -- No Ability Wars, o remote geralmente fica em ReplicatedStorage.Remotes.Punch ou dentro da Tool
    local remote = ReplicatedStorage:FindFirstChild("Punch", true) or 
                   ReplicatedStorage:FindFirstChild("Click", true) or
                   ReplicatedStorage:FindFirstChild("Attack", true)
    
    if remote and remote:IsA("RemoteEvent") then
        remote:FireServer()
    end

    -- 3. Se o jogo usar ativação de ferramenta (tentativa secundária silenciosa)
    local tool = char:FindFirstChildOfClass("Tool")
    if tool then
        tool:Activate()
    end
end

-- LOOP PRINCIPAL
task.spawn(function()
    while true do
        if _G.AutoSlap then
            darTapaReal()
        end
        task.wait(0.15) -- Intervalo seguro para não bugar o celular
    end
end)
