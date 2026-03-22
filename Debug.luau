local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Log = "--- BUSCA DE REMOTES AW ---\n"

-- GUI Minimalista (Sem chance de travar o touch)
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AW_Finder"
screenGui.Parent = game.CoreGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0, 220, 0, 120)
frame.Position = UDim2.new(0.5, -110, 0.1, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
frame.Active = true -- Permite interação
frame.Draggable = true -- Ativa o movimento
frame.Parent = screenGui

local status = Instance.new("TextLabel")
status.Size = UDim2.new(1, 0, 0, 60)
status.Text = "Clique no botão para escanear os eventos do jogo"
status.TextColor3 = Color3.new(1, 1, 1)
status.BackgroundTransparency = 1
status.TextWrapped = true
status.Parent = frame

local scanBtn = Instance.new("TextButton")
scanBtn.Size = UDim2.new(0.9, 0, 0, 40)
scanBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
scanBtn.Text = "ESCANEAR E COPIAR"
scanBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
scanBtn.TextColor3 = Color3.new(1, 1, 1)
scanBtn.Parent = frame

-- Função para escanear sem travar o jogo
local function escanear()
    Log = "--- RESULTADOS DO ESCANEAMENTO ---\n"
    
    -- Procura no ReplicatedStorage (onde ficam os socos)
    local alvos = {"RemoteEvent", "RemoteFunction"}
    for _, tipo in pairs(alvos) do
        for _, obj in pairs(game:GetDescendants()) do -- Busca profunda
            if obj:IsA(tipo) then
                -- Filtra nomes suspeitos de serem o soco
                local n = obj.Name:lower()
                if n:find("hit") or n:find("punch") or n:find("slap") or n:find("click") or n:find("attack") or n:find("h") then
                    Log = Log .. "Encontrado: " .. obj.Name .. " em " .. obj.Parent.Name .. "\n"
                end
            end
        end
    end
    
    if setclipboard then
        setclipboard(Log)
        status.Text = "Copiado! Cole no chat."
    else
        status.Text = "Veja o console (F9)"
        print(Log)
    end
end

scanBtn.MouseButton1Click:Connect(escanear)
