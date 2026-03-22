local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local Log = "--- INICIANDO SCANNER V2 ---\n"

-- Reaproveitando sua GUI favorita
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "DebugScannerV2"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 280, 0, 180)
frame.Position = UDim2.new(0.5, -140, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
frame.BorderSizePixel = 0
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 35)
title.Text = "Scanner de Mecânicas"
title.TextColor3 = Color3.new(1, 1, 1)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
title.Parent = frame

local status = Instance.new("TextLabel")
status.Size = UDim2.new(0.9, 0, 0, 80)
status.Position = UDim2.new(0.05, 0, 0.25, 0)
status.Text = "Aguardando tapa/clique..."
status.TextColor3 = Color3.fromRGB(0, 200, 255)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local copyBtn = Instance.new("TextButton")
copyBtn.Size = UDim2.new(0.9, 0, 0, 35)
copyBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
copyBtn.Text = "COPIAR RESULTADOS"
copyBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
copyBtn.TextColor3 = Color3.new(1, 1, 1)
copyBtn.Parent = frame

-- Função de Log
local function addLog(tipo, info)
    local linha = string.format("[%s] %s: %s", os.date("%X"), tipo, info)
    Log = Log .. "\n" .. linha
    status.Text = linha
    print(linha)
end

-- 1. Monitorar Ferramenta (Tool)
task.spawn(function()
    while true do
        local char = Players.LocalPlayer.Character
        if char then
            local tool = char:FindFirstChildOfClass("Tool")
            if tool then
                tool.Activated:Connect(function()
                    addLog("TOOL", "Ativada: " .. tool.Name)
                end)
            end
        end
        task.wait(1)
    end
end)

-- 2. Monitorar Toque (Input)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        addLog("INPUT", "Tipo: " .. tostring(input.UserInputType) .. " | GUI: " .. tostring(gameProcessed))
    end
end)

-- 3. Monitorar Animações (Muitos jogos usam isso para dar o tapa)
task.spawn(function()
    local char = Players.LocalPlayer.Character or Players.LocalPlayer.CharacterAdded:Wait()
    local hum = char:WaitForChild("Humanoid")
    hum.AnimationPlayed:Connect(function(track)
        addLog("ANIM", "ID: " .. track.Animation.AnimationId)
    end)
end)

-- Botão Copiar
copyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(Log)
        copyBtn.Text = "COPIADO!"
        task.wait(2)
        copyBtn.Text = "COPIAR RESULTADOS"
    else
        status.Text = "Erro: setclipboard não disponível."
    end
end)
