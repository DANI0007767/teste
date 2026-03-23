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

-- 70%
MagoTab:Toggle("Auto Heal 70%", function(state)
    getgenv().Heal70 = state
    
    if state then
        getgenv().Heal50 = false
        print("🟢 Heal 70% ON")
    else
        print("🔴 Heal 70% OFF")
    end
end)

-- 50%
MagoTab:Toggle("Auto Heal 50%", function(state)
    getgenv().Heal50 = state
    
    if state then
        getgenv().Heal70 = false
        print("🟢 Heal 50% ON")
    else
        print("🔴 Heal 50% OFF")
    end
end)

-- ==========================================
-- 🧠 AUTO HEAL (BASE ORIGINAL + TOGGLES)
-- ==========================================

local Players = game:GetService("Players")
local player = Players.LocalPlayer

local CUSTO_MANA = 30
local COOLDOWN = 1

local character
local humanoid
local botaoR

-- Atualiza ao respawn (IGUAL AO SEU)
local function atualizarTudo(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")

    local abilityGui = player.PlayerGui:FindFirstChild("Ability Buttons", true)

    if abilityGui then
        botaoR = abilityGui:FindFirstChild("R", true)
    end
end

if player.Character then
    atualizarTudo(player.Character)
end

player.CharacterAdded:Connect(atualizarTudo)

-- Mana (IGUAL AO SEU)
local function obterMana()
    local manaBar = player.PlayerGui:FindFirstChild("ManaBar", true)
    if manaBar then
        local texto = manaBar:FindFirstChildOfClass("TextLabel")
        if texto then
            return tonumber(texto.Text:match("%d+")) or 0
        end
    end
    return 100
end

-- Cura (ANTI-BUG PROFISSIONAL)
local function ativarCura()
    local abilityGui = player.PlayerGui:FindFirstChild("Ability Buttons", true)
    local botaoR = abilityGui and abilityGui:FindFirstChild("R", true)

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

    local remoteFolder = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes")
    if remoteFolder then
        local remote = remoteFolder:FindFirstChild("Ability")
        if remote then
            remote:FireServer("R")
        end
    end

    print("🪄 CURA ATIVADA")
end

-- ==========================================
-- 🔄 LOOP COM TOGGLES (AQUI É A MÁGICA)
-- ==========================================

task.spawn(function()
    while task.wait(0.5) do
        if character and humanoid and humanoid.Health > 0 then
            
            local vidaAtual = humanoid.Health
            local manaAtual = obterMana()

            local limite = nil

            -- DEFINE QUAL SISTEMA TÁ ATIVO
            if getgenv().Heal70 then
                limite = 0.7
            elseif getgenv().Heal50 then
                limite = 0.5
            end

            -- EXECUTA A LÓGICA ORIGINAL
            if limite 
            and vidaAtual <= humanoid.MaxHealth * limite
            and manaAtual >= CUSTO_MANA then
                
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
