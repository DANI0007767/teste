-- GUI HABILIT WARS - RAYFIELD UI
-- Versão melhorada com Rayfield para mobile e desktop
-- Autor: Sistema de Desenvolvimento
-- Biblioteca: Rayfield (mobile-friendly)

-- Carregar biblioteca Rayfield
local Rayfield = loadstring(game:HttpGet('https://raw.githubusercontent.com/shlexware/Rayfield/main/source'))()

-- Criar janela principal
local Window = Rayfield:CreateWindow({
    Name = "Habilit Wars",
    LoadingTitle = "Habilit Wars",
    LoadingSubtitle = "by Habilit System",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "HabilitWars",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
        Invite = "sirius",
        RememberJoins = false
    },
    KeySystem = false,
    KeySettings = {
        Title = "Habilit Wars",
        Subtitle = "Key System",
        Note = "No key needed",
        SaveKey = false,
        Key = "HabilitWars2024"
    }
})

-- Variáveis globais de controle
getgenv().HitboxSize = 15
getgenv().HitboxTransparency = 0.9
getgenv().HitboxStatus = false
getgenv().AbilityESP = false

-- Controle de conexões
local HBEConnection = nil
local ESPObjects = {}

-- =========================
-- 🟦 TAB PRINCIPAL
-- =========================

local MainTab = Window:CreateTab("Main", 4483362458)

-- Seção de Hitbox
local HitboxSection = MainTab:CreateSection("Hitbox Expander")

-- Slider para tamanho da hitbox
MainTab:CreateSlider({
    Name = "Hitbox Size",
    Range = {1, 50},
    Increment = 1,
    CurrentValue = 15,
    Flag = "HitboxSize",
    Callback = function(Value)
        getgenv().HitboxSize = Value
    end,
})

-- Slider para transparência
MainTab:CreateSlider({
    Name = "Hitbox Transparency",
    Range = {0, 1},
    Increment = 0.1,
    CurrentValue = 0.9,
    Flag = "HitboxTransparency",
    Callback = function(Value)
        getgenv().HitboxTransparency = Value
    end,
})

-- Toggle para HBE
MainTab:CreateToggle({
    Name = "Hitbox Expander",
    CurrentValue = false,
    Flag = "HBE",
    Callback = function(Value)
        getgenv().HitboxStatus = Value
        
        if Value then
            if not HBEConnection then
                HBEConnection = game:GetService("RunService").RenderStepped:Connect(function()
                    for _, player in pairs(game.Players:GetPlayers()) do
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
                end)
            end
        else
            -- Desliga loop
            if HBEConnection then
                HBEConnection:Disconnect()
                HBEConnection = nil
            end
            
            -- Reseta hitboxes
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    pcall(function()
                        local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.Size = Vector3.new(2,2,1)
                            hrp.Transparency = 1
                            hrp.Material = Enum.Material.Plastic
                        end
                    end)
                end
            end
        end
    end,
})

-- Seção de ESP
local ESPSection = MainTab:CreateSection("Ability ESP")

-- Toggle para ESP
MainTab:CreateToggle({
    Name = "Ability ESP",
    CurrentValue = false,
    Flag = "AbilityESP",
    Callback = function(Value)
        getgenv().AbilityESP = Value
        
        if not Value then
            -- Remove todos os ESPs
            for _, v in pairs(ESPObjects) do
                if v then v:Destroy() end
            end
            ESPObjects = {}
        else
            -- Ativa ESP para jogadores existentes
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    local char = player.Character
                    if char and char:FindFirstChild("Head") then
                        local billboard = Instance.new("BillboardGui")
                        billboard.Size = UDim2.new(0,100,0,40)
                        billboard.Adornee = char.Head
                        billboard.AlwaysOnTop = true
                        billboard.Parent = char
                        
                        local text = Instance.new("TextLabel")
                        text.Size = UDim2.new(1,0,1,0)
                        text.BackgroundTransparency = 1
                        text.TextScaled = false
                        text.TextSize = 14
                        text.Text = "Habilidade"
                        text.TextColor3 = Color3.new(1,1,1)
                        text.Parent = billboard
                        
                        table.insert(ESPObjects, billboard)
                    end
                end
            end
        end
    end,
})

-- =========================
-- 🟡 TAB CONFIGURAÇÕES
-- =========================

local SettingsTab = Window:CreateTab("Settings", 5012544693)

local SettingsSection = SettingsTab:CreateSection("Interface")

-- Botão para recarregar GUI
SettingsTab:CreateButton({
    Name = "Reload GUI",
    Callback = function()
        Rayfield:Destroy()
        wait(1)
        loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua"))()
    end,
})

-- Botão para fechar GUI
SettingsTab:CreateButton({
    Name = "Close GUI",
    Callback = function()
        Rayfield:Destroy()
    end,
})

-- =========================
-- 🔴 SISTEMA DE ESP AVANÇADO
-- =========================

-- Função para criar ESP para jogador
local function createESP(player)
    if not getgenv().AbilityESP then return end
    
    local char = player.Character
    if char and char:FindFirstChild("Head") then
        -- Remover ESP antigo corretamente
        for _, v in pairs(char:GetChildren()) do
            if v:IsA("BillboardGui") and v.Name == "AbilityESP" then
                v:Destroy()
            end
        end
        
        -- Criar novo ESP
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "AbilityESP"
        billboard.Size = UDim2.new(0,100,0,40)
        billboard.Adornee = char.Head
        billboard.AlwaysOnTop = true
        billboard.Parent = char
        
        local text = Instance.new("TextLabel")
        text.Size = UDim2.new(1,0,1,0)
        text.BackgroundTransparency = 1
        text.TextScaled = false
        text.TextSize = 14
        text.Text = "Habilidade"
        text.TextColor3 = Color3.new(1,1,1)
        text.Parent = billboard
        
        table.insert(ESPObjects, billboard)
    end
end

-- Conectar eventos de jogador
game.Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        task.wait(1)
        if getgenv().AbilityESP then
            createESP(player)
        end
    end)
end)

-- Conectar jogadores existentes
for _, player in ipairs(game.Players:GetPlayers()) do
    if player ~= game.Players.LocalPlayer then
        player.CharacterAdded:Connect(function()
            task.wait(1)
            if getgenv().AbilityESP then
                createESP(player)
            end
        end)
    end
end

-- Exportar funções para uso externo
_G.HabilitWars = _G.HabilitWars or {}
_G.HabilitWars.GUI = _G.HabilitWars.GUI or {}
_G.HabilitWars.GUI.createESP = createESP

-- Notificação de carregamento
pcall(function()
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Habilit Wars] Rayfield UI carregada com sucesso!";
        Color = Color3.fromRGB(0, 255, 0);
        Font = Enum.Font.GothamBold;
    })
end)

print("✅ GUI Habilit Wars (Rayfield) carregada!")
print("🎮 Controles disponíveis:")
print("  - Hitbox Size: " .. getgenv().HitboxSize)
print("  - Hitbox Transparency: " .. getgenv().HitboxTransparency)
print("  - HBE: " .. (getgenv().HitboxStatus and "ON" or "OFF"))
print("  - Ability ESP: " .. (getgenv().AbilityESP and "ON" or "OFF"))
print("📱 Rayfield UI - Mobile e Desktop 100%")
