-- SISTEMA DE EXIBIÇÃO DE HABILIDADE - ABILITY WARS
-- Autor: Sistema de Desenvolvimento
-- Objetivo: Mostrar habilidade do jogador acima da cabeça

local Players = game:GetService("Players")

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

-- 🔧 Sistema de monitoramento com evento (mais eficiente que loop)
local function monitorarHabilidade(player, textLabel)
    local leaderstats = player:WaitForChild("leaderstats", 5)
    if not leaderstats then return end
    
    local ability = leaderstats:WaitForChild("Ability", 5)
    if not ability then return end

    -- Atualizar texto inicial
    textLabel.Text = ability.Value

    -- Monitorar mudanças na habilidade
    ability:GetPropertyChangedSignal("Value"):Connect(function()
        textLabel.Text = ability.Value
    end)
end

-- Criar texto acima da cabeça
local function criarTextoHabilidade(player)
    local character = player.Character
    if not character then return end
    
    local head = character:WaitForChild("Head", 5)
    if not head then return end
    
    -- Evitar duplicados
    if head:FindFirstChild("AbilityDisplay") then return end
    
    -- Criar BillboardGui
    local gui = Instance.new("BillboardGui")
    gui.Name = "AbilityDisplay"
    gui.Size = UDim2.new(0, 80, 0, 20)
    gui.StudsOffset = Vector3.new(0, 3.5, 0)
    gui.AlwaysOnTop = true
    gui.MaxDistance = 200
    
    -- Criar TextLabel
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = false
    text.TextSize = 12
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1)
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextWrapped = true
    text.Text = pegarHabilidade(player)
    
    text.Parent = gui
    gui.Parent = head
    
    -- Iniciar monitoramento com evento
    monitorarHabilidade(player, text)
    
    print("✅ Display de habilidade criado para: " .. player.Name)
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
print("� SISTEMA ABILITY WARS ATIVADO!")

-- Aplicar para todos os jogadores atuais
for _, player in pairs(Players:GetPlayers()) do
    setupJogador(player)
end

-- Detectar novos jogadores
Players.PlayerAdded:Connect(function(player)
    task.wait(3) -- Esperar jogador carregar
    setupJogador(player)
end)

print("✅ Sistema pronto para uso!")
print("🔄 Monitorando habilidades em tempo real...")
