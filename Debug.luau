-- MINI GUI DE TESTE (AUTO-MAGO)
local ScreenGui = Instance.new("ScreenGui")
local Toggle = Instance.new("TextButton")

ScreenGui.Parent = game.CoreGui
Toggle.Parent = ScreenGui
Toggle.BackgroundColor3 = Color3.fromRGB(80, 0, 200)
Toggle.Position = UDim2.new(0, 100, 0, 150)
Toggle.Size = UDim2.new(0, 120, 0, 40)
Toggle.Text = "Auto-Heal: OFF"
Toggle.TextColor3 = Color3.new(1,1,1)
Toggle.Draggable = true

local Ativado = false

-- CONFIGURAÇÃO
local LIMITE_VIDA_PERCENT = 0.7 -- 70%
local MANA_MINIMA = 30

local player = game.Players.LocalPlayer

-- FUNÇÃO PARA PEGAR O PRIMEIRO NÚMERO DA BARRA AZUL
local function checarMana()
    local mana = 0
    pcall(function()
        -- Procura a barra de mana em toda a PlayerGui
        for _, v in pairs(player.PlayerGui:GetDescendants()) do
            if v:IsA("TextLabel") and (v.Text:find("Mana") or v.Parent.Name:find("Mana")) then
                -- Pega o primeiro conjunto de números que aparecer (Ex: "100" de "100/100")
                local valor = v.Text:match("(%d+)")
                if valor then
                    mana = tonumber(valor)
                end
            end
        end
    end)
    return mana
end

-- FUNÇÃO PARA USAR A HABILIDADE
local function usarR()
    local remote = game:GetService("ReplicatedStorage"):FindFirstChild("Remotes") 
                   and game:GetService("ReplicatedStorage").Remotes:FindFirstChild("Ability")
    
    if remote then
        remote:FireServer("R")
    end
end

-- LOGICA PRINCIPAL
Toggle.MouseButton1Click:Connect(function()
    Ativado = not Ativado
    Toggle.Text = Ativado and "Auto-Heal: ON" or "Auto-Heal: OFF"
    Toggle.BackgroundColor3 = Ativado and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

task.spawn(function()
    while task.wait(0.5) do
        if Ativado then
            local char = player.Character
            local hum = char and char:FindFirstChild("Humanoid")
            
            if hum and hum.Health > 0 then
                local manaAtual = checarMana()
                local vidaPercent = hum.Health / hum.MaxHealth
                
                -- REGRA DE OURO: Mana em primeiro lugar
                if manaAtual >= MANA_MINIMA then
                    -- Se tem mana, verifica a vida
                    if vidaPercent <= LIMITE_VIDA_PERCENT then
                        usarR()
                        task.wait(1) -- Cooldown para não spammar
                    end
                else
                    -- Se tiver menos de 30, ele ignora a vida e não faz nada
                    print("Mana muito baixa para curar: " .. manaAtual)
                end
            end
        end
    end
end)
