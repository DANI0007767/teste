local Players = game:GetService("Players")
local Log = "--- MAPEAMENTO PROFUNDO DE LÓGICA ---"

-- GUI para Copiar (Sempre no seu estilo)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_DeepScanner"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 100)
status.Text = "Clique para escanear Scripts e Módulos de Dano..."
status.TextColor3 = Color3.new(1, 0, 0)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 40)
scanBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
scanBtn.Text = "ESCANEAR TUDO"
scanBtn.BackgroundColor3 = Color3.fromRGB(50, 0, 0)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Parent = frame

local function deepScan()
    Log = "--- RESULTADOS DA BUSCA AVANÇADA ---\n"
    
    -- 1. Buscar em Scripts que rodam no Player
    local locais = {Players.LocalPlayer.PlayerScripts, Players.LocalPlayer.PlayerGui, Players.LocalPlayer.Character}
    
    for _, localizacao in pairs(locais) do
        if localizacao then
            for _, obj in pairs(localizacao:GetDescendants()) do
                if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                    local name = obj.Name:lower()
                    -- Filtros de palavras-chave que o jogo usaria para o Ragdoll ou Hit
                    if name:find("rag") or name:find("hit") or name:find("clien") or name:find("fight") or name:find("combat") or name:find("damage") then
                        Log = Log .. "[SCRIPT] " .. obj.Name .. " | Local: " .. obj.Parent.Name .. " (" .. obj.ClassName .. ")\n"
                    end
                end
            end
        end
    end

    -- 2. Buscar por "TouchInterest" (Colisão física de dano)
    for _, v in pairs(Players.LocalPlayer.Character:GetDescendants()) do
        if v:IsA("TouchInterest") then
            Log = Log .. "[TOUCH] Detectado em: " .. v.Parent.Name .. "\n"
        end
    end

    -- 3. Buscar valores ocultos de Range/Distância
    for _, v in pairs(game.ReplicatedStorage:GetDescendants()) do
        if v:IsA("NumberValue") or v:IsA("IntValue") then
            if v.Name:lower():find("range") or v.Name:lower():find("dist") then
                Log = Log .. "[VALOR] " .. v.Name .. ": " .. v.Value .. "\n"
            end
        end
    end

    if setclipboard then
        setclipboard(Log)
        status.Text = "TUDO COPIADO! Cole no chat."
    else
        status.Text = "Erro ao copiar automaticamente."
        print(Log)
    end
end

scanBtn.MouseButton1Click:Connect(deepScan)
