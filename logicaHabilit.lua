-- SISTEMA COMPLETO DE EXIBIÇÃO DE HABILIDADE
-- Autor: Sistema de Desenvolvimento
-- Objetivo: Mostrar habilidade do jogador acima da cabeça

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Palavras-chave para detectar habilidades automaticamente
local palavrasChave = {
    "ability", "skill", "power", "move", "current", "habilit", "poder", "habilidade"
}

-- Função para verificar se nome contém palavra-chave
local function contemPalavraChave(nome)
    local nomeLower = string.lower(nome)
    for _, palavra in pairs(palavrasChave) do
        if string.find(nomeLower, palavra) then
            return true
        end
    end
    return false
end

-- 🔧 Modificação 1 — Detectar Tool (habilidade) OTIMIZADO
local function pegarHabilidade(player)
    local character = player.Character
    if not character then return "Nenhuma" end
    
    -- Procurar Tools equipadas no Character
    for _, obj in pairs(character:GetChildren()) do
        if obj:IsA("Tool") then
            return obj.Name
        end
    end
    
    -- 2️⃣ Verificar Tools no Backpack (melhoria)
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, tool in pairs(backpack:GetChildren()) do
            if tool:IsA("Tool") then
                return tool.Name
            end
        end
    end
    
    -- Se não encontrar Tool, verificar Attributes
    local attrs = character:GetAttributes()
    for nomeAttr, valor in pairs(attrs) do
        if contemPalavraChave(nomeAttr) then
            return valor and tostring(valor) or "Nenhuma"
        end
    end
    
    -- 3️⃣ Verificar Values com segurança (bug fix)
    for _, filho in pairs(character:GetChildren()) do
        if filho:IsA("StringValue") or filho:IsA("ObjectValue") then
            if contemPalavraChave(filho.Name) then
                return filho.Value and tostring(filho.Value) or "Nenhuma"
            end
        end
    end
    
    return "Nenhuma"
end

-- PASSO 3: Detectar o personagem
-- PASSO 4: Criar o texto acima da cabeça (BillboardGui)
-- PASSO 5: Criar o texto da habilidade
local function criarTextoHabilidade(player)
    local character = player.Character
    if not character then return end
    
    local head = character:FindFirstChild("Head")
    if not head then return end
    
    -- Evitar criar duplicados
    if head:FindFirstChild("AbilityDisplay") then return end
    
    -- Criar BillboardGui com melhorias visuais
    local gui = Instance.new("BillboardGui")
    gui.Name = "AbilityDisplay"
    gui.Size = UDim2.new(0, 200, 0, 50) -- Aumentado altura para 2 linhas
    gui.StudsOffset = Vector3.new(0, 3.5, 0) -- Subiu um pouco
    gui.AlwaysOnTop = true
    gui.MaxDistance = 200 -- Dobrou distância de visão
    
    -- Criar TextLabel com melhorias
    local text = Instance.new("TextLabel")
    text.Size = UDim2.new(1, 0, 1, 0)
    text.BackgroundTransparency = 1
    text.TextScaled = true
    text.TextStrokeTransparency = 0
    text.Font = Enum.Font.GothamBold
    text.TextColor3 = Color3.new(1, 1, 1) -- Branco
    text.TextStrokeColor3 = Color3.new(0, 0, 0) -- Preto
    text.TextWrapped = true -- Habilitar multilinha
    
    -- � Melhor melhoria: Nome + Habilidade
    text.Text = player.Name .. "\n" .. pegarHabilidade(player)
    
    text.Parent = gui
    gui.Parent = head
    
    -- 1️⃣ Otimização: Loop mais rápido (0.5s)
    task.spawn(function()
        while gui and gui.Parent do
            text.Text = player.Name .. "\n" .. pegarHabilidade(player)
            task.wait(0.5) -- Atualiza a cada 0.5 segundos
        end
    end)
    
    print("✅ Display de habilidade criado para: " .. player.Name)
end

-- Sistema principal
local function setupJogador(player)
    -- Se já tem character, criar display
    if player.Character then
        criarTextoHabilidade(player)
    end
    
    -- Monitorar quando o character for adicionado/respawn
    player.CharacterAdded:Connect(function(character)
        task.wait(1) -- Esperar character carregar
        criarTextoHabilidade(player)
    end)
end

-- Sistema de exploração (PASSO 1 & 2)
local function explorarObjeto(objeto, nome, nivel)
    local indent = string.rep("  ", nivel)
    
    -- Detectar possíveis habilidades automaticamente
    if contemPalavraChave(nome) then
        print(indent .. "⚠️ POSSÍVEL HABILIDADE: " .. nome .. " (" .. objeto.ClassName .. ")")
    else
        print(indent .. "📁 " .. nome .. " (" .. objeto.ClassName .. ")")
    end
    
    -- Verificar Attributes (corrigido com next())
    local attrs = objeto:GetAttributes()
    if next(attrs) then
        print(indent .. "  🏷️ Attributes:")
        for nomeAttr, valor in pairs(attrs) do
            if contemPalavraChave(nomeAttr) then
                print(indent .. "    ⚠️ POSSÍVEL HABILIDADE - " .. nomeAttr .. ": " .. tostring(valor))
            else
                print(indent .. "    - " .. nomeAttr .. ": " .. tostring(valor))
            end
        end
    end
    
    -- Verificar Values importantes com detecção automática
    for _, filho in pairs(objeto:GetChildren()) do
        if filho:IsA("StringValue") or filho:IsA("IntValue") or filho:IsA("ObjectValue") then
            local prefix = contemPalavraChave(filho.Name) and "⚠️ POSSÍVEL HABILIDADE" or "💎"
            print(indent .. "  " .. prefix .. " " .. filho.Name .. " = " .. tostring(filho.Value))
        end
    end
    
    -- Explorar filhos recursivamente (com limite de profundidade)
    for _, filho in pairs(objeto:GetChildren()) do
        if nivel < 3 then -- Limite para evitar poluição
            explorarObjeto(filho, filho.Name, nivel + 1)
        end
    end
end

-- Função principal para explorar jogadores
local function explorarJogadores()
    print("🔍 INICIANDO EXPLORAÇÃO DO JOGO")
    print("=" .. string.rep("=", 50))
    
    for _, player in pairs(Players:GetPlayers()) do
        print("\n👤 JOGADOR: " .. player.Name)
        print("-" .. string.rep("-", 30))
        
        -- Explorar o Player
        explorarObjeto(player, "Player", 0)
        
        -- Explorar o Character se existir
        local character = player.Character
        if character then
            print("\n🎭 CHARACTER:")
            explorarObjeto(character, "Character", 0)
            
            -- Verificar Backpack (habilidades podem estar aqui)
            local backpack = player:FindFirstChild("Backpack")
            if backpack then
                print("\n🎒 BACKPACK:")
                explorarObjeto(backpack, "Backpack", 0)
            end
        end
        
        -- Verificar leaderstats
        local leaderstats = player:FindFirstChild("leaderstats")
        if leaderstats then
            print("\n📊 LEADERSTATS:")
            explorarObjeto(leaderstats, "leaderstats", 0)
        end
        
        -- Verificar PlayerGui (MUITO IMPORTANTE - habilidades podem estar aqui)
        local playerGui = player:FindFirstChild("PlayerGui")
        if playerGui then
            print("\n🖥️ PLAYERGUI:")
            explorarObjeto(playerGui, "PlayerGui", 0)
        end
    end
    
    -- Explorar ReplicatedStorage (pode ter sistemas de habilidade)
    print("\n🌐 REPLICATEDSTORAGE:")
    explorarObjeto(ReplicatedStorage, "ReplicatedStorage", 0)
end

-- INICIALIZAÇÃO DO SISTEMA

-- 1. Executar exploração inicial
explorarJogadores()

-- 2. Detectar novos jogadores automaticamente
Players.PlayerAdded:Connect(function(player)
    task.wait(3) -- Esperar 3 segundos para o jogador carregar completamente
    print("\n🆕 NOVO JOGADOR DETECTADO: " .. player.Name)
    explorarJogadores()
    setupJogador(player)
end)

-- 3. Aplicar para todos os jogadores atuais
for _, player in pairs(Players:GetPlayers()) do
    setupJogador(player)
end

print("\n✅ SISTEMA COMPLETO ATIVADO!")
print("📝 Procure por termos marcados com ⚠️ POSSÍVEL HABILIDADE")
print("🔄 Script monitorando novos jogadores e exibindo habilidades automaticamente...")
