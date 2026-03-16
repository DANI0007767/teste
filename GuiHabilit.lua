-- GUI HABILIT WARS - SISTEMA DE CONTROLE
--GuiHabilit.lua
-- Autor: Sistema de Desenvolvimento
-- Biblioteca: Kavo (UI moderna)

-- Carregar biblioteca Kavo
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/xHeptc/Kavo-UI-Library/main/source.lua"))()

-- Criar janela principal
local Window = Library.CreateLib("Habilit Wars", "Ocean")

-- Variáveis globais de controle
getgenv().HitboxSize = 15
getgenv().HitboxTransparency = 0.9
getgenv().HitboxStatus = false
getgenv().AbilityESP = false

-- Aba principal
local MainTab = Window:NewTab("Main")

-- Seção de Hitbox
local HitboxSection = MainTab:NewSection("Hitbox Expander")

-- Input de tamanho da hitbox
HitboxSection:NewTextBox("Hitbox Size", "Tamanho da hitbox", function(value)
    getgenv().HitboxSize = tonumber(value) or 15
end)

-- Input de transparência
HitboxSection:NewTextBox("Hitbox Transparency", "Transparência da hitbox", function(value)
    getgenv().HitboxTransparency = tonumber(value) or 0.9
end)

-- Botão para ligar/desligar HBE
HitboxSection:NewToggle("HBE", "Ativa/Desativa Hitbox Expander", function(state)
    getgenv().HitboxStatus = state
end)

-- Seção de ESP
local ESPSection = MainTab:NewSection("Ability ESP")

-- Botão para ligar/desligar ESP de habilidades
ESPSection:NewToggle("Ability ESP", "Mostra habilidades acima dos jogadores", function(state)
    getgenv().AbilityESP = state
    
    if state then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                setupJogador(player)
            end
        end
    end
end)

-- Sistema de Hitbox Expander
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

RunService.RenderStepped:Connect(function()
    if not getgenv().HitboxStatus then
        return
    end
    
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= Players.LocalPlayer then
            pcall(function()
                local char = player.Character
                if char and char:FindFirstChild("HumanoidRootPart") then
                    local hrp = char.HumanoidRootPart
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

-- Função setupJogador para ESP (será chamada pela GUI)
local function setupJogador(player)
    -- Chamar função da lógica
    if _G.HabilitWars and _G.HabilitWars.Logic and _G.HabilitWars.Logic.setupJogador then
        _G.HabilitWars.Logic.setupJogador(player)
    end
end

-- Exportar funções para uso externo
_G.HabilitWars = _G.HabilitWars or {}
_G.HabilitWars.GUI = _G.HabilitWars.GUI or {}
_G.HabilitWars.GUI.setupJogador = setupJogador

-- Notificação de carregamento (segura)
pcall(function()
    game.StarterGui:SetCore("ChatMakeSystemMessage", {
        Text = "[Habilit Wars] GUI carregada com sucesso!";
        Color = Color3.fromRGB(0, 255, 0);
        Font = Enum.Font.GothamBold;
    })
end)

print("✅ GUI Habilit Wars carregada!")
print("🎮 Controles disponíveis:")
print("  - Hitbox Size: " .. getgenv().HitboxSize)
print("  - Hitbox Transparency: " .. getgenv().HitboxTransparency)
print("  - HBE: " .. (getgenv().HitboxStatus and "ON" or "OFF"))
print("  - Ability ESP: " .. (getgenv().AbilityESP and "ON" or "OFF"))
