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

-- Controle de loops
local HBELoopRunning = false

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
            if not HBELoopRunning then
                HBELoopRunning = true
                task.spawn(function()
                    while getgenv().HitboxStatus and HBELoopRunning do
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
                        task.wait(0.1) -- 🔥 reduz MUITO o peso no mobile
                    end
                    HBELoopRunning = false
                end)
            end
        else
            -- Reseta hitboxes
            for _, player in ipairs(game.Players:GetPlayers()) do
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
            -- REMOVE TODOS OS ESPs (do sistema da lógica)
            for _, player in pairs(game.Players:GetPlayers()) do
                local char = player.Character
                if char and char:FindFirstChild("Head") then
                    local head = char.Head
                    local esp = head:FindFirstChild("AbilityDisplay")
                    if esp then
                        esp:Destroy()
                    end
                end
            end
        else
            -- ATIVA USANDO SUA LÓGICA
            for _, player in pairs(game.Players:GetPlayers()) do
                if player ~= game.Players.LocalPlayer then
                    if _G.HabilitWars 
                    and _G.HabilitWars.Logic 
                    and _G.HabilitWars.Logic.setupJogador then
                        
                        _G.HabilitWars.Logic.setupJogador(player)
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
        task.wait(1)
        local success, err = pcall(function()
            loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua"))()
        end)
        if not success then
            warn("Erro ao carregar GUI:", err)
        end
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
-- 🔴 MOBILE UX - KEYBIND
-- =========================

-- Notificação de keybind
Rayfield:Notify({
    Title = "Habilit Wars",
    Content = "Pressione RightControl para abrir/fechar",
    Duration = 5
})

-- Keybind para toggle rápido
Rayfield:BindKey({
    Name = "Toggle UI",
    Keybind = Enum.KeyCode.RightControl,
    Hold = false,
    Callback = function()
        Rayfield:Toggle()
    end,
})

-- =========================
-- 🔴 EXPORTAR FUNÇÕES
-- =========================

-- Exportar funções para uso externo
_G.HabilitWars = _G.HabilitWars or {}
_G.HabilitWars.GUI = _G.HabilitWars.GUI or {}

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
