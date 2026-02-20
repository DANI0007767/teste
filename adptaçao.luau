local Players = game:GetService("Players")
local player = Players.LocalPlayer

-- CONFIG
local LIMITE_VIDA = 0.6
local CUSTO_MANA = 30
local COOLDOWN = 1

local character
local humanoid
local botaoR

-- Atualiza tudo quando respawnar
local function atualizarTudo(char)
    character = char
    humanoid = char:WaitForChild("Humanoid")

    local abilityGui = player.PlayerGui:WaitForChild("Ability Buttons")
    botaoR = abilityGui:WaitForChild("R")
end

if player.Character then
    atualizarTudo(player.Character)
end

player.CharacterAdded:Connect(atualizarTudo)

-- Mana
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

-- SUA FUNÇÃO ORIGINAL (intocada)
local function ativarCura()
    print("🪄 Tentando curar...")

    local events = {"MouseButton1Click", "MouseButton1Down", "Activated"}
    for _, eventName in pairs(events) do
        if botaoR and botaoR[eventName] then
            for _, connection in pairs(getconnections(botaoR[eventName])) do
                connection:Fire()
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
end

-- Loop
while task.wait(0.5) do
    if humanoid and humanoid.Health > 0 then
        local vidaAtual = humanoid.Health
        local manaAtual = obterMana()

        if vidaAtual <= humanoid.MaxHealth * LIMITE_VIDA
        and manaAtual >= CUSTO_MANA then
            
            ativarCura()
            task.wait(COOLDOWN)
        end
    end
end
