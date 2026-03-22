-- SISTEMA DE EXIBIÇÃO DE HABILIDADE - ABILITY WARS
-- Autor: Sistema de Desenvolvimento
-- Objetivo: Mostrar habilidade do jogador acima da cabeça
--logicaHabilit.lua

local Players = game:GetService("Players")

-- Criar estrutura global para export
_G.HabilitWars = _G.HabilitWars or {}
_G.HabilitWars.Logic = _G.HabilitWars.Logic or {}

-- 🎨 Cores personalizadas das habilidades (ORGANIZADO POR CATEGORIA)
local coresHabilidades = {
    -- 🔥 PODERES OFENSIVOS (VERMELHO)
    ["Golpe de Deus"] = Color3.fromRGB(255,0,0),
    ["Meteoro"] = Color3.fromRGB(255,0,0),
    ["Explosão"] = Color3.fromRGB(255,0,0),
    ["Fúria"] = Color3.fromRGB(255,0,0),
    ["Raio"] = Color3.fromRGB(255,0,0),
    
    -- 🟡 PODERES DE CONTROLE/UTILIDADE (AMARELO - PLAMAS)
    ["Cola"] = Color3.fromRGB(255,255,0),
    ["Cartões"] = Color3.fromRGB(255,255,0),
    ["Devorador de Almas"] = Color3.fromRGB(255,255,0),
    ["Tempo"] = Color3.fromRGB(255,255,0),
    ["Quântico"] = Color3.fromRGB(255,255,0),
    ["Canhão ferroviário"] = Color3.fromRGB(255,255,0),
    ["Plasma"] = Color3.fromRGB(255,255,0),
    ["Engenheiro"] = Color3.fromRGB(255,255,0),
    ["Alquimista"] = Color3.fromRGB(255,255,0),
    ["Teleporte"] = Color3.fromRGB(255,255,0),
    ["Congelamento"] = Color3.fromRGB(255,255,0),
    ["Stun"] = Color3.fromRGB(255,255,0),
    ["Slow"] = Color3.fromRGB(255,255,0),
    
    -- 🔵 PODERES DE DEFESA (AZUL)
    ["Escudo"] = Color3.fromRGB(0,100,255),
    ["Proteção"] = Color3.fromRGB(0,100,255),
    ["Invisibilidade"] = Color3.fromRGB(0,100,255),
    ["Barreira"] = Color3.fromRGB(0,100,255),
    
    -- 🟢 PODERES DE CURA/SUPORTE (VERDE)
    ["Cura"] = Color3.fromRGB(0,255,0),
    ["Vida"] = Color3.fromRGB(0,255,0),
    ["Regeneração"] = Color3.fromRGB(0,255,0),
    ["Suporte"] = Color3.fromRGB(0,255,0),
    
    -- 🟣 PODERES ESPECIAIS (ROXO)
    ["Vôo"] = Color3.fromRGB(150,0,255),
    ["Super Pulo"] = Color3.fromRGB(150,0,255),
    ["Velocidade"] = Color3.fromRGB(150,0,255),
    ["Força"] = Color3.fromRGB(150,0,255),
    
    -- ⚫ PODERES NEUTROS/OUTROS (PRETO)
    ["Segurar"] = Color3.fromRGB(0,0,0),
    ["Empurrão"] = Color3.fromRGB(0,0,0),
    ["Básico"] = Color3.fromRGB(0,0,0),
    ["Nenhuma"] = Color3.fromRGB(128,128,128) -- Cinza para habilidade vazia
}

-- 🔧 Função otimizada para Ability Wars - Pega habilidade do leaderstats
local function pegarHabilidade(player)
    local leaderstats = player:FindFirstChild("leaderstats")
    if not leaderstats then
        return "Nenhuma"
    end

    local ability = leaderstats:FindFirstChild("Ability")
    if ability then
        return tostring(ability.Value)
    end

    return "Nenhuma"
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
        local habilidadeFormatada = string.lower(habilidade):gsub("%s+", "")

        local cor = nil

        for nome, corTabela in pairs(coresHabilidades) do
            if string.lower(nome):gsub("%s+", "") == habilidadeFormatada then
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
