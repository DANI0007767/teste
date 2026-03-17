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
    
    if not state then
        -- Resetar hitboxes de todos os jogadores
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                pcall(function()
                    local char = player.Character
                    if char and char:FindFirstChild("HumanoidRootPart") then
                        local hrp = char.HumanoidRootPart
                        hrp.Size = Vector3.new(2,2,1)
                        hrp.Transparency = 1
                        hrp.Material = Enum.Material.Plastic
                    end
                end)
            end
        end
    end
end)

-- Seção de ESP
local ESPSection = MainTab:NewSection("Ability ESP")

-- Botão para ligar/desligar ESP de habilidades
ESPSection:NewToggle("Ability ESP", "Mostra habilidades acima dos jogadores", function(state)
    getgenv().AbilityESP = state
    
    if state then
        for _, player in pairs(game.Players:GetPlayers()) do
            if player ~= game.Players.LocalPlayer then
                _G.HabilitWars.Logic.setupJogador(player)
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

-- Botão flutuante para reabrir GUI
-- Prevenir duplicação
if game.CoreGui:FindFirstChild("HabilitOpenButton") then
    game.CoreGui.HabilitOpenButton:Destroy()
end

local openButton = Instance.new("TextButton")
openButton.Name = "HabilitOpenButton"
openButton.Size = UDim2.new(0,50,0,50)
openButton.Position = UDim2.new(0,10,0.5,0)
openButton.Text = "☰"
openButton.BackgroundColor3 = Color3.fromRGB(0,0,0)
openButton.TextColor3 = Color3.new(1,1,1)
openButton.Font = Enum.Font.GothamBold
openButton.TextSize = 20
openButton.BorderSizePixel = 0
openButton.Parent = game.CoreGui

-- Sistema de arrastar (mobile + desktop)
local dragging = false
local dragInput, mousePos, framePos

openButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = openButton.Position
    end
end)

openButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging then
        local delta = input.Position - mousePos
        openButton.Position = UDim2.new(
            framePos.X.Scale,
            framePos.X.Offset + delta.X,
            framePos.Y.Scale,
            framePos.Y.Offset + delta.Y
        )
    end
end)

openButton.MouseButton1Click:Connect(function()
    Window:ToggleUI()
end)

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
print("📱 Botão ☰ adicionado para reabrir GUI")
