-- GUI HABILIT WARS - EDIÇÃO MAGO BATTLE (FIXED HEAL)
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

-- Variáveis globais de controle
getgenv().HitboxSize = 15
getgenv().HitboxStatus = false
getgenv().AntiVoid = false
getgenv().SpeedEnabled = false
getgenv().TargetSpeed = 20
getgenv().Heal70 = false 
getgenv().Heal50 = false
getgenv().AimlockStatus = false

local Camera = workspace.CurrentCamera
local LocalPlayer = game.Players.LocalPlayer 

-- ==========================================
-- 📂 ABAS
-- ==========================================
local MainTab = Window:Tab("Main", "rbxassetid://10888331510")
local MagoTab = Window:Tab("Mago", "rbxassetid://10888331510")

-- ==========================================
-- 🔥 ABA: MAIN
-- ==========================================
MainTab:Section("Combate & Segurança")
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
MainTab:Toggle("Ativar Anti Void", function(state) getgenv().AntiVoid = state end)

-- ==========================================
-- 🪄 ABA: MAGO
-- ==========================================
MagoTab:Section("Movimentação")
MagoTab:TextBox("Velocidade do Mago", function(v) getgenv().TargetSpeed = tonumber(v) or 20 end)
MagoTab:Toggle("Ativar Speed (Mago)", function(state) getgenv().SpeedEnabled = state end)

MagoTab:Section("Automação de Cura")

-- TOGGLE 70%
local T70 = MagoTab:Toggle("Auto Heal (Abaixo de 70%)", function(state)
    getgenv().Heal70 = state
    if state and getgenv().Heal50 then
        getgenv().Heal50 = false
        print("🪄 Mago: Modo 70% Ativo (50% desligado)")
    end
end)

-- TOGGLE 50%
local T50 = MagoTab:Toggle("Auto Heal (Abaixo de 50%)", function(state)
    getgenv().Heal50 = state
    if state and getgenv().Heal70 then
        getgenv().Heal70 = false
        print("🪄 Mago: Modo 50% Ativo (70% desligado)")
    end
end)

MagoTab:Section("Ataque à Distância")
MagoTab:Toggle("Ativar Botão Q (Aimlock)", function(state)
    getgenv().AimlockStatus = state
    local guiExistente = game.CoreGui:FindFirstChild("Q_ButtonGui")
    if state then
        if not guiExistente then
            local QGui = Instance.new("ScreenGui", game.CoreGui)
            QGui.Name = "Q_ButtonGui"
            local QBtn = Instance.new("TextButton", QGui)
            QBtn.Size = UDim2.new(0, 65, 0, 65)
            QBtn.Position = UDim2.new(0.8, 0, 0.4, 0)
            QBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
            QBtn.Text = "Q"
            QBtn.TextColor3 = Color3.new(1,1,1)
            QBtn.Draggable = true
            QBtn.Active = true
            QBtn.MouseButton1Click:Connect(function() dispararQ() end)
        end
    elseif guiExistente then guiExistente:Destroy() end
end)

-- ==========================================
-- 🧠 SISTEMA DE CURA BASE (INTEGRADO)
-- ==========================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local LIMITE_VIDA_70 = 0.7
local LIMITE_VIDA_50 = 0.5
local CUSTO_MANA = 30
local COOLDOWN = 1

local character
local humanoid
local botaoR

-- Atualiza ao respawn
local function atualizarTudo(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")

    local abilityGui = player.PlayerGui:WaitForChild("Ability Buttons")
    botaoR = abilityGui:WaitForChild("R")
end

if player.Character then
    atualizarTudo(player.Character)
end

player.CharacterAdded:Connect(atualizarTudo)

-- Mana
local function obterMana()
    local manaBar = player.PlayerGui:FindFirstChild("ManaBar", true)
    if manaBar then
        local texto = manaBar:FindFirstChildOfClass("TextLabel")
        if texto then
            return tonumber(texto.Text:match("%d+")) or 0
        end
    end
    return 0
end

-- Cura (ORIGINAL)
local function ativarCura()
    local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}

    for _, eventName in pairs(events) do
        if botaoR and botaoR[eventName] then
            for _, connection in pairs(getconnections(botaoR[eventName])) do
                connection:Fire()
            end
        end
    end

    local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remoteFolder then
        local remote = remoteFolder:FindFirstChild("Ability")
        if remote then
            remote:FireServer("R")
        end
    end
end

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
        if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("HumanoidRootPart") and p.Character.Humanoid.Health > 0 then
            local pos, onScreen = Camera:WorldToViewportPoint(p.Character.HumanoidRootPart.Position)
            if onScreen then
                local dist = (Vector2.new(pos.X, pos.Y) - (Camera.ViewportSize/2)).Magnitude
                if dist < shortestDist then target = p.Character.HumanoidRootPart shortestDist = dist end
            end
        end
    end
    if target then
        Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
-- ==========================================

task.spawn(function()
    while task.wait(0.3) do
        if humanoid and humanoid.Health > 0 then
            local vidaAtual = humanoid.Health
            local manaAtual = obterMana()

            local limite = nil

            if getgenv().Heal70 then
                limite = LIMITE_VIDA_70
            elseif getgenv().Heal50 then
                limite = LIMITE_VIDA_50
            end

            if limite and vidaAtual <= humanoid.MaxHealth * limite and manaAtual >= CUSTO_MANA then
                ativarCura()
                task.wait(COOLDOWN)
            end
        end
    end
end)

-- Loop Speed
task.spawn(function()
    while task.wait(0.4) do
        if getgenv().SpeedEnabled then
            pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().TargetSpeed end)
        end
    end
end)

-- Loop Anti-Void
task.spawn(function()
    while task.wait(0.3) do
        if getgenv().AntiVoid then
            pcall(function()
                local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < -20 then hrp.CFrame = CFrame.new(0, 50, 0) end
            end)
        end
    end
end)

print("✅ Mago Battle GUI Carregada com Trava de Cura!")
