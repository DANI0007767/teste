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
getgenv().HitboxColor = "Really black"
getgenv().HitboxTransparency = 0.9
getgenv().AntiVoid = false
getgenv().SpeedEnabled = false
getgenv().TargetSpeed = 20
getgenv().Heal70 = false 
getgenv().Heal50 = false
getgenv().AimlockStatus = false
getgenv().AbilityESP = false

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
MainTab:TextBox("Transparency", function(v) getgenv().HitboxTransparency = tonumber(v) end)
MainTab:TextBox("Cor do Hitbox", function(v) getgenv().HitboxColor = v end)
MainTab:Toggle("Ativar HBE", function(state)
    getgenv().HitboxStatus = state

    if state then
        task.spawn(function()
            while getgenv().HitboxStatus do
                for _, p in ipairs(game.Players:GetPlayers()) do
                    if p ~= game.Players.LocalPlayer then
                        pcall(function()
                            local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                                hrp.Transparency = getgenv().HitboxTransparency
                                hrp.Material = Enum.Material.Neon
                                hrp.BrickColor = BrickColor.new(getgenv().HitboxColor)
                                hrp.CanCollide = false
                            end
                        end)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        -- RESET IGUAL AO ANTIGO
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= game.Players.LocalPlayer then
                pcall(function()
                    local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2,2,1)
                        hrp.Transparency = 1
                        hrp.Material = Enum.Material.Plastic
                    end
                end)
            end
        end
    end
end)
MainTab:Toggle("Ativar Anti Void", function(state) getgenv().AntiVoid = state end)

-- ==========================================
-- 👁️ ESP DE HABILIDADES
-- ==========================================
MainTab:Section("Ability ESP")

MainTab:Toggle("Ability ESP", function(state)
    getgenv().AbilityESP = state

    if not state then
        -- REMOVE ESP
        for _, player in pairs(game.Players:GetPlayers()) do
            local char = player.Character
            if char and char:FindFirstChild("Head") then
                local esp = char.Head:FindFirstChild("AbilityDisplay")
                if esp then
                    esp:Destroy()
                end
            end
        end
    else
        -- ATIVA ESP (CORREÇÃO PROFISSIONAL)
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if player.Character then
                    _G.HabilitWars.Logic.setupJogador(player)
                else
                    player.CharacterAdded:Wait()
                    _G.HabilitWars.Logic.setupJogador(player)
                end
            end
        end
    end
end)

-- 🔥 BÔNUS: PEGA PLAYERS QUE ENTRAM DEPOIS
game.Players.PlayerAdded:Connect(function(player)
    if getgenv().AbilityESP then
        player.CharacterAdded:Connect(function()
            task.wait(1)
            _G.HabilitWars.Logic.setupJogador(player)
        end)
    end
end)

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
-- 🔄 LOOP COM TOGGLES (ULTRA RÁPIDO + ESTÁVEL)
-- ==========================================

local ultimoUso = 0

task.spawn(function()
    while task.wait(0.03) do -- 🔥 REFLEXO INSANO
        if character and humanoid and humanoid.Health > 0 then
            
            local vidaAtual = humanoid.Health
            local manaAtual = obterMana()

            local limite = nil

            if getgenv().Heal70 then
                limite = 0.7
            elseif getgenv().Heal50 then
                limite = 0.5
            end

            if limite
            and vidaAtual <= humanoid.MaxHealth * limite
            and manaAtual >= CUSTO_MANA
            and tick() - ultimoUso >= COOLDOWN then
                
                ultimoUso = tick()
                ativarCura()
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

-- ==========================================
-- 🛡️ ANTI VOID PROFISSIONAL
-- ==========================================

local POSICOES_SEGURAS = {
    Vector3.new(0, 5, 0),
    Vector3.new(20, 5, 20),
    Vector3.new(-25, 5, 15),
    Vector3.new(15, 5, -30),
    Vector3.new(-10, 5, -20)
}

task.spawn(function()
    while task.wait(0.1) do
        if getgenv().AntiVoid then
            pcall(function()
                local char = LocalPlayer.Character
                local hrp = char and char:FindFirstChild("HumanoidRootPart")

                if hrp and hrp.Position.Y < 15 then
                    -- 🔥 escolhe posição aleatória
                    local destino = POSICOES_SEGURAS[math.random(1, #POSICOES_SEGURAS)]

                    -- 🔥 EXTRA: offset humano (não cair sempre no mesmo lugar)
                    local offset = Vector3.new(
                        math.random(-5,5),
                        0,
                        math.random(-5,5)
                    )

                    -- 🔥 para TUDO (queda, rotação, impulso) - MELHOR QUE Velocity
                    hrp.AssemblyLinearVelocity = Vector3.zero
                    hrp.AssemblyAngularVelocity = Vector3.zero

                    -- 🔥 UPGRADE INSANO: micro delay para teleporte humano
                    task.wait() -- 1 frame de pausa

                    -- 🔥 teleporte LIMPO (sem efeito "snap" bruto)
                    hrp.CFrame = CFrame.new(destino + offset)
                end
            end)
        end
    end
end)

print("✅ Mago Battle GUI Carregada com Trava de Cura!")
