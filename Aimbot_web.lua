local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local AIMBOT_ENABLED = false
local TEAMCHECK_ENABLED = true

-- Configurações para mira ultra grudada
local SMOOTHNESS = 1        -- Mira gruda instantaneamente no alvo
local AIMBOT_FOV = 250      -- Área grande para troca de alvo

local screenGui
local toggleButton

local dragging = false
local dragInput
local dragStart
local startPos

local function isAlive(plr)
    local char = plr.Character
    if not char then return false end
    local humanoid = char:FindFirstChildOfClass("Humanoid")
    return humanoid and humanoid.Health > 0
end

local function isVisible(part)
    if not part then return false end
    local origin = Camera.CFrame.Position
    local direction = part.Position - origin
    if direction.Magnitude == 0 then return true end

    local raycastParams = RaycastParams.new()
    raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
    raycastParams.FilterType = Enum.RaycastFilterType.Blacklist

    local raycastResult = Workspace:Raycast(origin, direction.Unit * math.min(direction.Magnitude, 1000), raycastParams)
    if raycastResult then
        return raycastResult.Instance:IsDescendantOf(part.Parent)
    else
        return true
    end
end

local function getClosestEnemyToCenter()
    local closest = nil
    local shortestDist = AIMBOT_FOV -- Só considera se estiver dentro do FOV!
    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    for _, plr in pairs(Players:GetPlayers()) do
        if plr ~= LocalPlayer and (not TEAMCHECK_ENABLED or plr.Team ~= LocalPlayer.Team) then
            if isAlive(plr) and plr.Character and plr.Character:FindFirstChild("Head") then
                local head = plr.Character.Head
                local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)
                if onScreen and isVisible(head) then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist < shortestDist then
                        shortestDist = dist
                        closest = head
                    end
                end
            end
        end
    end
    return closest
end

local function buildGUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if screenGui then screenGui:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AimbotToggleGUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    toggleButton = Instance.new("TextButton")
    toggleButton.Size = UDim2.new(0, 150, 0, 50)
    toggleButton.Position = UDim2.new(1, -10, 0, 10)
    toggleButton.AnchorPoint = Vector2.new(1, 0)
    toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleButton.Font = Enum.Font.SourceSansBold
    toggleButton.TextSize = 18
    toggleButton.Text = "Aimbot: OFF"
    toggleButton.Parent = screenGui

    -- Permitir arrastar sem redimensionar
    toggleButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = toggleButton.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    toggleButton.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            toggleButton.Position = UDim2.new(
                math.clamp(startPos.X.Scale + delta.X / Camera.ViewportSize.X, 0, 1),
                startPos.X.Offset + delta.X,
                math.clamp(startPos.Y.Scale + delta.Y / Camera.ViewportSize.Y, 0, 1),
                startPos.Y.Offset + delta.Y
            )
        end
    end)

    toggleButton.MouseButton1Click:Connect(function()
        AIMBOT_ENABLED = not AIMBOT_ENABLED
        toggleButton.Text = "Aimbot: " .. (AIMBOT_ENABLED and "ON" or "OFF")
    end)
end

LocalPlayer.CharacterAdded:Connect(function()
    buildGUI()
end)

buildGUI()

RunService.RenderStepped:Connect(function()
    if AIMBOT_ENABLED then
        local targetHead = getClosestEnemyToCenter()
        if targetHead then
            -- Mira ultra grudada: snap instantâneo para o alvo!
            local currentCFrame = Camera.CFrame
            local desiredCFrame = CFrame.new(currentCFrame.Position, targetHead.Position)
            Camera.CFrame = currentCFrame:Lerp(desiredCFrame, SMOOTHNESS)
        end
    end
end)
