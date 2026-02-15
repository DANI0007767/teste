--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local LP = Players.LocalPlayer

--// CAMERA SETUP
local Camera = Workspace.CurrentCamera
local function updateCamera()
    Camera = Workspace.CurrentCamera
end
Workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(updateCamera)

--// UTILITÁRIOS
local function getScreenDistance(screenPos)
    local viewportSize = Camera.ViewportSize
    local center = Vector2.new(viewportSize.X/2, viewportSize.Y/2)
    return (screenPos - center).Magnitude
end

--// O MOTOR DE DETECÇÃO
local function getClosestPlayer()
    local closestPlayer = nil
    local closestDistance = math.huge
    local hub = _G.AimbotHub -- Acessa a ponte global

    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LP and player.Character then
            local targetPart = player.Character:FindFirstChild(hub.TARGET_PART or "Head")
            if not targetPart then continue end

            -- 1. Verificar se o Alvo está Vivo
            local humanoid = player.Character:FindFirstChild("Humanoid")
            if not humanoid or humanoid.Health <= 0 then continue end

            -- 2. Team Check Simplificado
            if hub.TEAM_CHECK then
                if player.Team == LP.Team then
                    continue -- Se estiver no mesmo time que eu, pula ele (ignora)
                end
            end

            -- 3. Wall Check (Verificar se há paredes no caminho)
            if hub.WALL_CHECK then
                local rayOrigin = Camera.CFrame.Position
                local rayDirection = (targetPart.Position - rayOrigin).Unit * 1000
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {LP.Character, Camera}
                params.IgnoreWater = true -- Segurança extra para mapas com água
                
                local result = Workspace:Raycast(rayOrigin, rayDirection, params)
                if result and not result.Instance:IsDescendantOf(player.Character) then
                    continue
                end
            end

            -- 4. Global Aim vs FOV Check (A LÓGICA PRINCIPAL)
            if hub.GLOBAL_AIM then
                -- MODO GLOBAL AIM: Ignora FOV e direção da câmera
                -- Sistema inteligente: distância + ângulo
                local camDir = Camera.CFrame.LookVector
                local dirToTarget = (targetPart.Position - Camera.CFrame.Position).Unit
                local angleWeight = camDir:Dot(dirToTarget) -- -1 a 1 (mais alinhado = maior valor)
                
                local distance = (Camera.CFrame.Position - targetPart.Position).Magnitude
                local score = distance - (angleWeight * 50) -- Prioriza alinhamento
                
                if score < closestDistance then
                    closestDistance = score
                    closestPlayer = player
                end
            else
                -- MODO NORMAL: Verifica FOV e se está na tela
                local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
                if onScreen then
                    local distance = getScreenDistance(Vector2.new(screenPos.X, screenPos.Y))
                    if distance < closestDistance and distance <= (hub.FOV or 250) then
                        closestDistance = distance
                        closestPlayer = player
                    end
                end
            end
        end
    end
    return closestPlayer
end

--// LÓGICA DE MIRA
local function aimAtTarget(target)
    if not target or not target.Character then return end
    local hub = _G.AimbotHub
    local targetPart = target.Character:FindFirstChild(hub.TARGET_PART or "Head")
    if not targetPart then return end

    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    local smoothness = math.clamp((hub.AIM_FORCE or 16) / 60, 0.05, 1)

    Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, smoothness)
end

--// CONTROLE DO LOOP
local Logic = {}
local aimbotConnection

function Logic.startAimbot()
    if aimbotConnection then aimbotConnection:Disconnect() end
    
    aimbotConnection = RunService.RenderStepped:Connect(function()
        if not _G.AimbotHub.AIMBOT_ENABLED then return end
        if not LP.Character or not LP.Character:FindFirstChild("Humanoid") then return end
        if LP.Character.Humanoid.Health <= 0 then return end

        local target = getClosestPlayer()
        if target then
            aimAtTarget(target)
        end
    end)
end

function Logic.stopAimbot()
    if aimbotConnection then
        aimbotConnection:Disconnect()
        aimbotConnection = nil
    end
end

--// SISTEMA ESP (Simples e Eficiente)
local ESP_CACHE = {} -- Cache para armazenar ESP de cada player

local function getEspColor(player)
    -- Regra: Inimigo = vermelho, Aliado = azul
    if _G.AimbotHub.TEAM_CHECK then
        if player.Team == LP.Team then
            return Color3.fromRGB(0, 100, 255) -- Azul (aliado)
        else
            return Color3.fromRGB(255, 0, 0) -- Vermelho (inimigo)
        end
    else
        return Color3.fromRGB(255, 0, 0) -- Vermelho (inimigo)
    end
end

local function createEsp(player)
	if ESP_CACHE[player] then return end
	if not player.Character then return end
	
	-- Opcional: ignorar NPCs
	if not Players:GetPlayerFromCharacter(player.Character) then return end

	local highlight = Instance.new("Highlight")
	highlight.Name = "ESP_Highlight"
	highlight.Adornee = player.Character
	highlight.FillColor = getEspColor(player)
	highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
	highlight.FillTransparency = 0.3
	highlight.OutlineTransparency = 1 -- Leve e clean
	highlight.Parent = Workspace -- Mais seguro contra Character reset
	
	ESP_CACHE[player] = highlight
end

local function updateEsp(player)
    if ESP_CACHE[player] then
        ESP_CACHE[player].FillColor = getEspColor(player)
    end
end

local function removeEsp(player)
    if ESP_CACHE[player] then
        ESP_CACHE[player]:Destroy()
        ESP_CACHE[player] = nil
    end
end

local function isPlayerValid(player)
    -- Condições mínimas para ESP
    return player ~= LP 
        and player.Character 
        and player.Character:FindFirstChild("Humanoid") 
        and player.Character.Humanoid.Health > 0
end

-- Loop principal do ESP
local espConnection
function Logic.startEspLoop()
	if espConnection then return end -- Evita conexões duplicadas
	
	local lastUpdate = 0
	espConnection = RunService.Heartbeat:Connect(function()
		-- Otimização: não atualizar todo frame
		if os.clock() - lastUpdate < 0.1 then return end
		lastUpdate = os.clock()
		
		-- Se ESP desligado, remove tudo
		if not _G.AimbotHub.ESP_ENABLED then
			for player, esp in pairs(ESP_CACHE) do
				removeEsp(player)
			end
			return
		end
		
		-- Para cada player
		for _, player in pairs(Players:GetPlayers()) do
			if isPlayerValid(player) then
				-- Se ESP não existe, cria
				if not ESP_CACHE[player] then
					createEsp(player)
				end
				-- Atualiza cor
				updateEsp(player)
			else
				-- Remove ESP de player inválido
				removeEsp(player)
			end
		end
	end)
end

function Logic.stopEspLoop()
    if espConnection then
        espConnection:Disconnect()
        espConnection = nil
    end
    
    -- Limpa todos os ESPs
    for player, esp in pairs(ESP_CACHE) do
        removeEsp(player)
    end
end

-- Limpeza quando player sai (corrigido - PlayerRemoving passa Player object)
Players.PlayerRemoving:Connect(function(player)
    removeEsp(player)
end)

return Logic
