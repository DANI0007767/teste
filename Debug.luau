local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = "--- MAPEAMENTO DE SISTEMA AW ---\n"

-- GUI (Padrão que você gosta)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_Architect"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 260, 0, 160)
frame.Position = UDim2.new(0.5, -130, 0.2, 0)
frame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
frame.Active = true
frame.Draggable = true
frame.Parent = screenGui

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 100)
status.Text = "Clique para mapear a lógica de Hit/Dano..."
status.TextColor3 = Color3.new(0, 1, 0.5)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 40)
scanBtn.Position = UDim2.new(0.05, 0, 0.7, 0)
scanBtn.Text = "MAPEAR SISTEMA"
scanBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Parent = frame

local function mapear()
    Log = "--- RESULTADOS DO MAPEAMENTO ---\n"
    
    -- 1. Procurar Scripts de Combate no Personagem
    local char = Players.LocalPlayer.Character
    if char then
        for _, obj in pairs(char:GetDescendants()) do
            if obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
                if obj.Name:lower():find("combat") or obj.Name:lower():find("mão") or obj.Name:lower():find("hit") or obj.Name:lower():find("attack") then
                    Log = Log .. "[CHAR] Script: " .. obj.Name .. " (Caminho: " .. obj:GetFullName() .. ")\n"
                end
            end
        end
    end
    
    -- 2. Procurar pastas de "Remotes" ou "Systems" no ReplicatedStorage
    for _, obj in pairs(ReplicatedStorage:GetChildren()) do
        if obj.Name:lower():find("remot") or obj.Name:lower():find("syst") or obj.Name:lower():find("comba") then
            Log = Log .. "[REP] Pasta: " .. obj.Name .. "\n"
            for _, sub in pairs(obj:GetChildren()) do
                Log = Log .. "   -> " .. sub.Name .. " (" .. sub.ClassName .. ")\n"
            end
        end
    end

    if setclipboard then
        setclipboard(Log)
        status.Text = "MAPEADO! Cole o texto aqui no chat."
    else
        status.Text = "Erro ao copiar. Veja o F9."
        print(Log)
    end
end

scanBtn.MouseButton1Click:Connect(mapear)
