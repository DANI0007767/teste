-- SISTEMA DE EXIBIÇÃO DE HABILIDADE - ABILITY WARS
-- Autor: Sistema de Desenvolvimento
-- Objetivo: Mostrar habilidade do jogador acima da cabeça
--logicaHabilit.lua

local Players = game:GetService("Players")

-- Criar estrutura global para export
_G.HabilitWars = _G.HabilitWars or {}
_G.HabilitWars.Logic = _G.HabilitWars.Logic or {}

-- 🎨 Cores personalizadas das habilidades (NOMES REAIS EM INGLÊS)
local coresHabilidades = {
    -- 🔥 PODERES OFENSIVOS (VERMELHO)
    ["God Punch"] = Color3.fromRGB(255,0,0),
    ["Meteor"] = Color3.fromRGB(255,0,0),
    ["Explosion"] = Color3.fromRGB(255,0,0),
    ["Fury"] = Color3.fromRGB(255,0,0),
    ["Lightning"] = Color3.fromRGB(255,0,0),
    
    -- 🟡 PODERES DE CONTROLE/UTILIDADE (AMARELO - PLAMAS)
    ["Glue"] = Color3.fromRGB(255,255,0),
    ["Cards"] = Color3.fromRGB(255,255,0),
    ["Soul Stealer"] = Color3.fromRGB(255,255,0),
    ["Time"] = Color3.fromRGB(255,255,0),
    ["Quantum"] = Color3.fromRGB(255,255,0),
    ["Railgun"] = Color3.fromRGB(255,255,0),
    ["Plasma"] = Color3.fromRGB(255,255,0),
    ["Engineer"] = Color3.fromRGB(255,255,0),
    ["Alchemist"] = Color3.fromRGB(255,255,0),
    ["Teleport"] = Color3.fromRGB(255,255,0),
    ["Freeze"] = Color3.fromRGB(255,255,0),
    ["Stun"] = Color3.fromRGB(255,255,0),
    ["Slow"] = Color3.fromRGB(255,255,0),
    ["Magnet"] = Color3.fromRGB(255,255,0),
    ["Seat"] = Color3.fromRGB(255,255,0),
    
    -- 🔵 PODERES DE DEFESA (AZUL)
    ["Shield"] = Color3.fromRGB(0,100,255),
    ["Protection"] = Color3.fromRGB(0,100,255),
    ["Invisibility"] = Color3.fromRGB(0,100,255),
    ["Barrier"] = Color3.fromRGB(0,100,255),
    
    -- 🟢 PODERES DE CURA/SUPORTE (VERDE)
    ["Heal"] = Color3.fromRGB(0,255,0),
    ["Life"] = Color3.fromRGB(0,255,0),
    ["Regeneration"] = Color3.fromRGB(0,255,0),
    ["Support"] = Color3.fromRGB(0,255,0),
    
    -- 🟣 PODERES ESPECIAIS (ROXO)
    ["Fly"] = Color3.fromRGB(150,0,255),
    ["Super Jump"] = Color3.fromRGB(150,0,255),
    ["Speed"] = Color3.fromRGB(150,0,255),
    ["Strength"] = Color3.fromRGB(150,0,255),
    
    -- ⚫ PODERES NEUTROS/OUTROS (PRETO)
    ["Hold"] = Color3.fromRGB(0,0,0),
    ["Push"] = Color3.fromRGB(0,0,0),
    ["Basic"] = Color3.fromRGB(0,0,0),
    ["None"] = Color3.fromRGB(128,128,128) -- Cinza para habilidade vazia
}

-- Função otimizada para Ability Wars - Pega habilidade do leaderstats
local function pegarHabilidade(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return "None"
    end

    local ability = leaderstats:FindFirstChild("Ability")
    if ability then
        return tostring(ability.Value)
    end

    return "None"
end

-- Sistema de monitoramento com evento (mais eficiente que loop)
local function monitorarHabilidade(player, textLabel)

    local leaderstats = player:WaitForChild("leaderstats", 5)
    if not leaderstats then return end
    
    local ability = leaderstats:WaitForChild("Ability", 5)
    if not ability then return end

    local function atualizar()

        local habilidade = tostring(ability.Value)
        textLabel.Text = habilidade

        -- NORMALIZAÇÃO (ANTI BUG DE NOME)
        local habilidadeFormatada = string.lower(habilidade)
        habilidadeFormatada = habilidadeFormatada:gsub("%s+", "")
        habilidadeFormatada = habilidadeFormatada:gsub("%p+", "")

        local cor = nil

        for nome, corTabela in pairs(coresHabilidades) do
            local nomeFormatado = string.lower(nome)
            nomeFormatado = nomeFormatado:gsub("%s+", "")
            nomeFormatado = nomeFormatado:gsub("%p+", "")
            
            if nomeFormatado == habilidadeFormatada then
                cor = corTabela
                break
            end
        end

        if cor then
            textLabel.TextColor3 = cor
        else
            textLabel.TextColor3 = Color3.new(1,1,1)
        end

    end

    atualizar()

    ability:GetPropertyChangedSignal("Value"):Connect(atualizar)

end

-- Criar texto acima da cabeça
local function criarTextoHabilidade(player)

    -- Verificar se ESP está ativado pela GUI
    if getgenv().AbilityESP == false then
        return
    end

    local character = player.Character
    if not character then return end

    local head = character:FindFirstChild("Head")
    if not head then return end

    if head:FindFirstChild("AbilityDisplay") then return end

    local gui = Instance.new("BillboardGui")
    gui.Name = "AbilityDisplay"
    gui.Adornee = head
    gui.Size = UDim2.new(0,80,0,20)
    gui.StudsOffset = Vector3.new(0,2.5,0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 150
    gui.Parent = head

    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1,0,1,0)
    text.BackgroundTransparency = 1
    text.TextScaled = false
    text.TextSize = 11
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1,1,1)
    text.TextStrokeTransparency = 0
    text.TextStrokeColor3 = Color3.new(0,0,0)
    text.Text = pegarHabilidade(player)
    text.Parent = gui

    monitorarHabilidade(player,text)

end

-- Sistema principal
local function setupJogador(player)
    -- Configurar evento CharacterAdded primeiro
    player.CharacterAdded:Connect(function(character)
        task.wait(1) -- Esperar character carregar
        criarTextoHabilidade(player)
    end)

    -- Se já tem character, criar display
    if player.Character then
        criarTextoHabilidade(player)
    end
end

-- INICIALIZAÇÃO DO SISTEMA
print(" SISTEMA ABILITY WARS ATIVADO!")

-- Aplicar para todos os jogadores atuais (só se ESP estiver ativo)
if getgenv().AbilityESP then
    for _, player in pairs(Players:GetPlayers()) do
        setupJogador(player)
    end
end

-- Detectar novos jogadores
Players.PlayerAdded:Connect(function(player)
    task.wait(3) -- Esperar jogador carregar
    setupJogador(player)
end)

print(" Sistema pronto para uso!")
print(" Monitorando habilidades em tempo real...")

-- Exportar funções para uso externo
_G.HabilitWars.Logic.setupJogador = setupJogador
_G.HabilitWars.Logic.pegarHabilidade = pegarHabilidade
