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

            -- 2. Team Check (Baseado na sua lista de times permitidos)
            local hasAnyTeamEnabled = false
            for _, enabled in pairs(hub.AllowedTeams) do
                if enabled then hasAnyTeamEnabled = true; break end
            end

            if hasAnyTeamEnabled and player.Team and not hub.AllowedTeams[player.Team.Name] then
                continue
            end

            -- 3. Wall Check (Verificar se há paredes no caminho)
            if hub.WALL_CHECK then
                local rayOrigin = Camera.CFrame.Position
                local rayDirection = (targetPart.Position - rayOrigin)
                local params = RaycastParams.new()
                params.FilterType = Enum.RaycastFilterType.Exclude
                params.FilterDescendantsInstances = {LP.Character}
                
                local result = Workspace:Raycast(rayOrigin, rayDirection, params)
                if result and not result.Instance:IsDescendantOf(player.Character) then
                    continue
                end
            end

            -- 4. FOV Check (Verificar se está dentro do círculo)
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
    return closestPlayer
end

--// LÓGICA DE MIRA
local function aimAtTarget(target)
    if not target or not target.Character then return end
    local hub = _G.AimbotHub
    local targetPart = target.Character:FindFirstChild(hub.TARGET_PART or "Head")
    if not targetPart then return end

    local targetCFrame = CFrame.new(Camera.CFrame.Position, targetPart.Position)
    local smoothness = math.clamp((hub.AIM_FORCE or 16) / 100, 0.01, 1)

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

return Logic
