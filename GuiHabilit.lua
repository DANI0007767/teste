-- GUI HABILIT WARS - EDIÇÃO MAGO BATTLE
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Vcsk/UI-Library/main/Source/MyUILib(Unamed).lua"))()
local Window = Library:Create("Habilit Wars")

-- Botão flutuante (mobile)
local ToggleGui = Instance.new("ScreenGui")
local Toggle = Instance.new("TextButton")
ToggleGui.Parent = game.CoreGui
Toggle.Parent = ToggleGui
Toggle.BackgroundColor3 = Color3.fromRGB(24,24,24)
Toggle.BackgroundTransparency = 0.6
Toggle.Position = UDim2.new(0,0,0.4,0)
Toggle.Size = UDim2.new(0,80,0,40)
Toggle.Text = "Open"
Toggle.TextScaled = true
Toggle.Active = true
Toggle.Draggable = true
Toggle.MouseButton1Click:Connect(function() Library:ToggleUI() end)

-- Variáveis globais
getgenv().HitboxSize = 15
getgenv().HitboxStatus = false
getgenv().AntiVoid = false
getgenv().SpeedEnabled = false
getgenv().TargetSpeed = 20
getgenv().AutoHeal = false 
getgenv().PercentualCura = 0.7 
getgenv().AimlockStatus = false

-- Variáveis para o Aimlock
local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer 

-- ==========================================
-- 📂 ABAS
-- ==========================================
local MainTab = Window:Tab("Main", "rbxassetid://10888331510")
local MagoTab = Window:Tab("Mago", "rbxassetid://10888331510")

-- ==========================================
-- 🔥 ABA: MAIN (Apenas Hitbox e Anti-Void agora)
-- ==========================================
MainTab:Section("Combate Geral")
MainTab:TextBox("Hitbox Size", function(v) getgenv().HitboxSize = tonumber(v) end)
MainTab:Toggle("Ativar HBE", function(state)
    getgenv().HitboxStatus = state
    if state then
        task.spawn(function()
            while getgenv().HitboxStatus do
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= game.Players.LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                        pcall(function()
                            p.Character.HumanoidRootPart.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                            p.Character.HumanoidRootPart.Transparency = 0.9
                            p.Character.HumanoidRootPart.CanCollide = false
                        end)
                    end
                end
                task.wait(0.5)
            end
        end)
    end
end)

MainTab:Section("Segurança")
MainTab:Toggle("Ativar Anti Void", function(state) getgenv().AntiVoid = state end)

-- ==========================================
-- 🪄 ABA: MAGO (Tudo do Mago + Speed aqui)
-- ==========================================
MagoTab:Section("Movimentação do Mago")

MagoTab:TextBox("Velocidade do Mago", function(v) 
    getgenv().TargetSpeed = tonumber(v) or 20 
end)

MagoTab:Toggle("Ativar Speed (Mago)", function(state)
    getgenv().SpeedEnabled = state
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then 
        hum.WalkSpeed = state and getgenv().TargetSpeed or 20 
    end
end)

MagoTab:Section("Automação de Cura")

MagoTab:Label("Ajuste de Vida: (Ex: 50 = 50%)")

MagoTab:TextBox("Curar com % de vida", function(v)
    local num = tonumber(v)
    if num and num > 0 and num <= 100 then
        getgenv().PercentualCura = num / 100
    end
end)

MagoTab:Toggle("Auto Heal (Tecla R)", function(state)
    getgenv().AutoHeal = state
end)

MagoTab:Section("Ataque à Distância")

MagoTab:Toggle("Ativar Botão Q (Aimlock)", function(state)
    getgenv().AimlockStatus = state
    
    local guiExistente = game.CoreGui:FindFirstChild("Q_ButtonGui")
    if state then
        if not guiExistente then
            local QGui = Instance.new("ScreenGui")
            local QBtn = Instance.new("TextButton")
            QGui.Name = "Q_ButtonGui"
            QGui.Parent = game.CoreGui
            
            QBtn.Parent = QGui
            QBtn.Size = UDim2.new(0, 60, 0, 60)
            QBtn.Position = UDim2.new(0.8, 0, 0.5, 0)
            QBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
            QBtn.Text = "Q"
            QBtn.TextColor3 = Color3.new(1,1,1)
            QBtn.Active = true
            QBtn.Draggable = true
            
            QBtn.MouseButton1Click:Connect(function()
                dispararQ()
            end)
        end
    else
        if guiExistente then guiExistente:Destroy() end
    end
end)

-- ==========================================
-- ❄️ FUNÇÕES DO AIM-LOCK
-- ==========================================

local function getClosestPlayer()
    local target = nil
    local shortestDistance = math.huge
    local mousePos = Camera.ViewportSize / 2

    for _, p in pairs(game.Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local distance = (Vector2.new(pos.X, pos.Y) - mousePos).Magnitude
                if distance < shortestDistance then
                    target = p.Character.HumanoidRootPart
                    shortestDistance = distance
                end
            end
        end
    end
    return target
end

local function dispararQ()
    local alvo = getClosestPlayer()
    
    if alvo then
        local oldCFrame = Camera.CFrame
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, alvo.Position)
        
        local abilityGui = LocalPlayer.PlayerGui:FindFirstChild("Ability Buttons", true)
        local botaoQ = abilityGui and abilityGui:FindFirstChild("Q")
        
        if botaoQ then
            for _, connection in pairs(getconnections(botaoQ.Activated)) do connection:Fire() end
        end
        
        local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and 
                       game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Ability")
        if remote then
            remote:FireServer("Q")
        end
        
        print("❄️ Cristal disparado em: " .. alvo.Parent.Name)
    end
end

-- ==========================================
-- 🛠️ FUNÇÕES TÉCNICAS (BACKEND)
-- ==========================================

local function obterMana()
    local manaBar = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ManaBar", true)
    if manaBar then
        local texto = manaBar:FindFirstChildOfClass("TextLabel")
        if texto then
            return tonumber(texto.Text:match("%d+")) or 0
        end
    end
    return 0
end

local function ativarCura()
    local player = game.Players.LocalPlayer
    local abilityGui = player.PlayerGui:FindFirstChild("Ability Buttons", true)
    local botaoR = abilityGui and abilityGui:FindFirstChild("R")

    if botaoR then
        local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
        for _, eventName in pairs(events) do
            if botaoR[eventName] then
                for _, connection in pairs(getconnections(botaoR[eventName])) do
                    connection:Fire()
                end
            end
        end
    end

    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and 
                   game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Ability")
    if remote then
        remote:FireServer("R")
    end
end

-- ==========================================
-- 🔄 LOOPS DE SISTEMA
-- ==========================================

-- Loop de Cura (Reação Rápida)
task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AutoHeal then
            local char = game.Players.LocalPlayer.Character
            local hum = char and char:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                if hum.Health <= (hum.MaxHealth * getgenv().PercentualCura) and obterMana() >= 30 then
                    ativarCura()
                end
            end
        end
    end
end)

-- Loop de Velocidade Persistente
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().SpeedEnabled then
            pcall(function() 
                game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().TargetSpeed 
            end)
        end
    end
end)

-- Loop Anti-Void
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().AntiVoid then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -15 then
                hrp.CFrame = CFrame.new(0, 30, 0)
            end
        end
    end
end)

print("✅ Mago Battle GUI Carregada!")
