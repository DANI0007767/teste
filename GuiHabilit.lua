-- GUI HABILIT WARS - UI LIBRARY CUSTOM
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
getgenv().AutoHeal = false -- Controle do Mago
getgenv().PercentualCura = 0.7 -- Padrão 70% de vida

-- ==========================================
-- 📂 CRIAÇÃO DAS ABAS (TABS)
-- ==========================================
local MainTab = Window:Tab("Main", "rbxassetid://10888331510")
local MagoTab = Window:Tab("Mago", "rbxassetid://10888331510") -- Nova aba logo abaixo

-- ==========================================
-- 🔥 CONTEÚDO DA ABA: MAIN
-- ==========================================
MainTab:Section("Hitbox")
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

MainTab:Section("Movimentação")
MainTab:TextBox("Velocidade (Normal: 20)", function(v) 
    getgenv().TargetSpeed = tonumber(v) or 20 
end)
MainTab:Toggle("Ativar Speed Mod", function(state)
    getgenv().SpeedEnabled = state
    local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
    if hum then hum.WalkSpeed = state and getgenv().TargetSpeed or 20 end
end)

MainTab:Section("Anti Void")
MainTab:Toggle("Ativar Anti Void", function(state) getgenv().AntiVoid = state end)

-- ==========================================
-- 🪄 CONTEÚDO DA ABA: MAGO
-- ==========================================
MagoTab:Section("Configurações de Cura")

-- Label explicativo para o usuário
MagoTab:Label("Ajuste de Vida: (Ex: 50 = metade da vida)")

MagoTab:TextBox("Curar com % de vida", function(v)
    local num = tonumber(v)
    if num and num > 0 and num <= 100 then
        -- Converte o número (ex: 70) para decimal (0.7)
        getgenv().PercentualCura = num / 100
        print("🪄 Mago: Cura ajustada para " .. num .. "% de vida.")
    else
        print("❌ Digite um valor entre 1 e 100")
    end
end)

MagoTab:Toggle("Auto Heal (Tecla R)", function(state)
    getgenv().AutoHeal = state
end)

-- Funções auxiliares do Mago
local function obterMana()
    local manaBar = game.Players.LocalPlayer.PlayerGui:FindFirstChild("ManaBar", true)
    if manaBar then
        local texto = manaBar:FindFirstChildOfClass("TextLabel")
        if texto then return tonumber(texto.Text:match("%d+")) or 0 end
    end
    return 100
end

local function usarCura()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Ability")
    if remote then remote:FireServer("R") end
end

-- Loop do Mago Atualizado com a Nova Variável
task.spawn(function()
    while task.wait(0.5) do
        if getgenv().AutoHeal then
            local hum = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid")
            if hum and hum.Health > 0 then
                -- Usa a variável getgenv().PercentualCura que o usuário definiu no TextBox
                if hum.Health <= (hum.MaxHealth * getgenv().PercentualCura) then
                    if obterMana() >= 30 then
                        usarCura()
                        task.wait(1.2) -- Cooldown interno
                    end
                end
            end
        end
    end
end)

-- ==========================================
-- � LOOPS DE SISTEMA (BACKGROUND)
-- ==========================================

-- Loop de Velocidade
task.spawn(function()
    while task.wait(0.4) do
        if getgenv().SpeedEnabled then
            pcall(function() game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().TargetSpeed end)
        end
    end
end)

-- Loop Anti-Void
task.spawn(function()
    while task.wait(0.2) do
        if getgenv().AntiVoid then
            local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < -15 then
                hrp.CFrame = CFrame.new(0, 20, 0) -- Teleporta pro centro do mapa
            end
        end
    end
end)

print("✅ GUI Atualizada: Abas 'Main' e 'Mago' prontas!")
