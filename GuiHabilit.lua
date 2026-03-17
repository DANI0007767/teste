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
getgenv().AutoTap = false
getgenv().AutoTapDistance = 15 -- distância para ativar
getgenv().AutoTapDelay = 0.05 -- velocidade dos cliques

-- TAB
local MainTab = Window:Tab("Main","rbxassetid://10888331510")

-- SEÇÃO HBE
MainTab:Section("Hitbox")

MainTab:TextBox("Hitbox Size", function(value)
    local num = tonumber(value)
    if num then
        getgenv().HitboxSize = num
    end
end)

MainTab:TextBox("Transparency", function(value)
    local num = tonumber(value)
    if num then
        getgenv().HitboxTransparency = num
    end
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

-- SEÇÃO COMBAT
MainTab:Section("Combat")

MainTab:Toggle("Auto Tap", function(state)
    getgenv().AutoTap = state
end)

MainTab:TextBox("Tap Distance", function(value)
    local num = tonumber(value)
    if num then
        getgenv().AutoTapDistance = num
    end
end)

MainTab:TextBox("Tap Speed", function(value)
    local num = tonumber(value)
    if num then
        getgenv().AutoTapDelay = num
    end
end)

-- =========================
-- 🔥 LÓGICA DO AUTO TAP
-- =========================

local Players = game:GetService("Players")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer

task.spawn(function()
    while task.wait(0.1) do
        if not getgenv().AutoTap then continue end

        local character = LocalPlayer.Character
        local hrp = character and character:FindFirstChild("HumanoidRootPart")

        if hrp then
            local targetPerto = false

            for _, player in ipairs(Players:GetPlayers()) do
                if player ~= LocalPlayer then
                    local char = player.Character
                    local enemyHRP = char and char:FindFirstChild("HumanoidRootPart")

                    if enemyHRP then
                        local distancia = (hrp.Position - enemyHRP.Position).Magnitude

                        if distancia <= getgenv().AutoTapDistance then
                            targetPerto = true
                            break
                        end
                    end
                end
            end

            if targetPerto then
                -- simular clique
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
                VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
            end
        end

        task.wait(getgenv().AutoTapDelay)
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
print("  - Auto Tap: " .. (getgenv().AutoTap and "ON" or "OFF"))
print("  - Tap Distance: " .. getgenv().AutoTapDistance)
print("  - Tap Speed: " .. getgenv().AutoTapDelay)
print("📱 UI Library - Delta/Mobile 100%")
