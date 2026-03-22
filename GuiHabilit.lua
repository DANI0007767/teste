-- GUI HABILIT WARS - UI LIBRARY CUSTOM
-- Versão mobile-friendly com botão flutuante
-- Autor: Sistema de Desenvolvimento
-- Biblioteca: MyUILib (Delta/Mobile compatível)

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

Toggle.MouseButton1Click:Connect(function()
    Library:ToggleUI()
end)

-- Variáveis globais de controle
getgenv().HitboxSize = 15
getgenv().HitboxTransparency = 0.9
getgenv().HitboxStatus = false
getgenv().AbilityESP = false
getgenv().AntiVoid = false

-- TAB
local MainTab = Window:Tab("Main","rbxassetid://10888331510")

-- SEÇÃO HBE
MainTab:Section("Hitbox")

MainTab:TextBox("Hitbox Size", function(value)
    getgenv().HitboxSize = tonumber(value)
end)

MainTab:TextBox("Transparency", function(value)
    getgenv().HitboxTransparency = tonumber(value)
end)

MainTab:Toggle("HBE", function(state)
    getgenv().HitboxStatus = state

    if state then
        task.spawn(function()
            while getgenv().HitboxStatus do
                for _, player in ipairs(game.Players:GetPlayers()) do
                    if player ~= game.Players.LocalPlayer then
                        pcall(function()
                            local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                            if hrp then
                                hrp.Size = Vector3.new(getgenv().HitboxSize, getgenv().HitboxSize, getgenv().HitboxSize)
                                hrp.Transparency = getgenv().HitboxTransparency
                                hrp.Material = Enum.Material.Neon
                                hrp.BrickColor = BrickColor.new("Really black")
                                hrp.CanCollide = false
                            end
                        end)
                    end
                end
                task.wait(0.1)
            end
        end)
    else
        for _, player in ipairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                pcall(function()
                    local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        hrp.Size = Vector3.new(2,2,1)
                        hrp.Transparency = 1
                    end
                end)
            end
        end
    end
end)

-- SEÇÃO ESP
MainTab:Section("Ability ESP")

MainTab:Toggle("Ability ESP", function(state)
    getgenv().AbilityESP = state

    if not state then
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
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                if _G.HabilitWars and _G.HabilitWars.Logic then
                    _G.HabilitWars.Logic.setupJogador(player)
                end
            end
        end
    end
end)

-- SEÇÃO ANTI VOID
MainTab:Section("Anti Void")

MainTab:Toggle("Anti Void", function(state)
    getgenv().AntiVoid = state
end)

-- SEÇÃO DE MOVIMENTAÇÃO
MainTab:Section("Movimentação")

-- Variáveis de controle
getgenv().SpeedEnabled = false
getgenv().TargetSpeed = 20 -- Valor inicial sugerido

-- Input de Velocidade
MainTab:TextBox("Definir Velocidade", function(value)
    local num = tonumber(value)
    if num then
        getgenv().TargetSpeed = num
        -- Se a box já estiver ligada, aplica na hora
        if getgenv().SpeedEnabled then
            local char = game.Players.LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid.WalkSpeed = num
            end
        end
    end
end)

-- A "Chave Mestre"
MainTab:Toggle("Ativar Modificador de Velocidade", function(state)
    getgenv().SpeedEnabled = state
    
    local char = game.Players.LocalPlayer.Character
    local hum = char and char:FindFirstChild("Humanoid")
    
    if not state then
        -- BOX DESLIGADA: Devolve o controle total ao jogo
        if hum then
            -- Aqui o ideal é 20, que é o padrão do Habilit Wars
            hum.WalkSpeed = 20 
        end
        print("🔌 Modificador de Velocidade: DESLIGADO")
    else
        -- BOX LIGADA: Aplica o valor do input imediatamente
        if hum then
            hum.WalkSpeed = getgenv().TargetSpeed
        end
        print("⚡ Modificador de Velocidade: ATIVADO (" .. getgenv().TargetSpeed .. ")")
    end
end)

-- Loop de Persistência (Só age se a Box estiver ON)
task.spawn(function()
    while true do
        task.wait(0.3) -- Checagem rápida para quando você morrer
        
        if getgenv().SpeedEnabled then
            pcall(function()
                local char = game.Players.LocalPlayer.Character
                local hum = char and char:FindFirstChild("Humanoid")
                
                -- Se a velocidade estiver diferente do que você quer, ele força o valor
                if hum and hum.WalkSpeed ~= getgenv().TargetSpeed then
                    hum.WalkSpeed = getgenv().TargetSpeed
                end
            end)
        end
    end
end)

-- =========================
-- 🔥 SISTEMA ANTI VOID
-- =========================

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local LIMITE_VOID = -10

local POSICOES = {
    Vector3.new(0, 10, 0),
    Vector3.new(20, 10, 20),
    Vector3.new(-25, 10, 15),
    Vector3.new(15, 10, -30),
    Vector3.new(-10, 10, -20)
}

task.spawn(function()
    while task.wait(0.1) do

        if not getgenv().AntiVoid then continue end

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            if hrp.Position.Y < LIMITE_VOID then
                
                local pos = POSICOES[math.random(1, #POSICOES)]

                -- 🔥 OFFSET PRA FICAR NATURAL
                local offset = Vector3.new(
                    math.random(-5,5),
                    0,
                    math.random(-5,5)
                )

                hrp.CFrame = CFrame.new(pos + offset)
            end
        end

    end
end)

-- Exportar funções para uso externo
_G.HabilitWars = _G.HabilitWars or {}
_G.HabilitWars.GUI = _G.HabilitWars.GUI or {}

-- Notificação de carregamento
pcall(function()
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Habilit Wars] UI Library carregada com sucesso!";
        Color = Color3.fromRGB(0, 255, 0);
        Font = Enum.Font.GothamBold;
    })
end)

print("✅ GUI Habilit Wars (UI Library) carregada!")
print("🎮 Controles disponíveis:")
print("  - Hitbox Size: " .. getgenv().HitboxSize)
print("  - Hitbox Transparency: " .. getgenv().HitboxTransparency)
print("  - HBE: " .. (getgenv().HitboxStatus and "ON" or "OFF"))
print("  - Ability ESP: " .. (getgenv().AbilityESP and "ON" or "OFF"))
print("  - Anti Void: " .. (getgenv().AntiVoid and "ON" or "OFF"))
print("📱 UI Library - Delta/Mobile 100%")
