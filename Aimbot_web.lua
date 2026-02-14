-- ⚡ Advanced Hack UI for Roblox - Web Version
-- Modern UI with mobile support and expandable modules
-- Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/refs/heads/main/Aimbot_web.lua"))()

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- UI State
local isMinimized = false
local isDragging = false
local dragStart = nil
local startPos = nil
local dragInput = nil

-- Main UI Elements
local screenGui = nil
local mainFrame = nil
local headerFrame = nil
local contentFrame = nil
local minimizeButton = nil

-- Module Storage
local _modules = {}

-- Colors Theme
local COLORS = {
    PRIMARY = Color3.fromRGB(25, 25, 35),
    SECONDARY = Color3.fromRGB(40, 40, 55),
    ACCENT = Color3.fromRGB(100, 200, 255),
    SUCCESS = Color3.fromRGB(40, 200, 40),
    DANGER = Color3.fromRGB(200, 40, 40),
    WARNING = Color3.fromRGB(255, 165, 0),
    TEXT = Color3.fromRGB(255, 255, 255),
    TEXT_MUTED = Color3.fromRGB(180, 180, 180)
}

-- Mobile Detection
local isMobile = UserInputService.TouchEnabled

-- Utility Functions
local function createTween(obj, info, goal)
    return TweenService:Create(obj, info, goal)
end

local function _lerp(a, b, t)
    return a + (b - a) * t
end

-- Dragging System (Mobile & Desktop Compatible)
local function setupDragging(frame)
    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or 
           input.UserInputType == Enum.UserInputType.Touch then
            
            isDragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    isDragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or 
           input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and isDragging then
            local delta = input.Position - dragStart
            local viewportSize = Camera.ViewportSize
            
            frame.Position = UDim2.new(
                math.clamp(startPos.X.Scale + delta.X / viewportSize.X, 0, 1),
                startPos.X.Offset + delta.X,
                math.clamp(startPos.Y.Scale + delta.Y / viewportSize.Y, 0, 1),
                startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Create Modern Button
local function createModernButton(name, text, size, position, parent)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = size
    button.Position = position
    button.BackgroundColor3 = COLORS.SECONDARY
    button.BorderSizePixel = 0
    button.Text = text
    button.TextColor3 = COLORS.TEXT
    button.Font = isMobile and Enum.Font.SourceSans or Enum.Font.Gotham
    button.TextSize = isMobile and 14 or 16
    button.Parent = parent
    
    -- Hover/Touch Effects
    local hoverTween = createTween(button, TweenInfo.new(0.2), {
        BackgroundColor3 = COLORS.ACCENT
    })
    
    local normalTween = createTween(button, TweenInfo.new(0.2), {
        BackgroundColor3 = COLORS.SECONDARY
    })
    
    if isMobile then
        button.TouchLongPress:Connect(function()
            hoverTween:Play()
        end)
        
        button.TouchEnded:Connect(function()
            normalTween:Play()
        end)
    else
        button.MouseEnter:Connect(function()
            hoverTween:Play()
        end)
        
        button.MouseLeave:Connect(function()
            normalTween:Play()
        end)
    end
    
    return button
end

-- Create Toggle Switch
local function createToggle(name, defaultValue, parent)
    local container = Instance.new("Frame")
    container.Name = name
    container.Size = UDim2.new(1, 0, 0, 30)
    container.BackgroundTransparency = 1
    container.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 0, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = name
    label.TextColor3 = COLORS.TEXT
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Font = isMobile and Enum.Font.SourceSans or Enum.Font.Gotham
    label.TextSize = isMobile and 12 or 14
    label.Parent = container
    
    local toggleFrame = Instance.new("TextButton")
    toggleFrame.Name = "ToggleFrame"
    toggleFrame.Size = UDim2.new(0, 40, 0, 20)
    toggleFrame.Position = UDim2.new(1, -40, 0.5, -10)
    toggleFrame.BackgroundColor3 = COLORS.SECONDARY
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Text = ""
    toggleFrame.Parent = container
    
    local toggleButton = Instance.new("Frame")
    toggleButton.Name = "ToggleButton"
    toggleButton.Size = UDim2.new(0, 16, 0, 16)
    toggleButton.Position = UDim2.new(0, 2, 0, 2)
    toggleButton.BackgroundColor3 = COLORS.TEXT_MUTED
    toggleButton.BorderSizePixel = 0
    toggleButton.Parent = toggleFrame
    
    -- Corner rounding
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 10)
    corner.Parent = toggleFrame
    
    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 8)
    buttonCorner.Parent = toggleButton
    
    local state = defaultValue
    local onToggle = nil
    
    local function updateVisual()
        if state then
            createTween(toggleFrame, TweenInfo.new(0.3), {
                BackgroundColor3 = COLORS.SUCCESS
            }):Play()
            createTween(toggleButton, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 22, 0, 2)
            }):Play()
        else
            createTween(toggleFrame, TweenInfo.new(0.3), {
                BackgroundColor3 = COLORS.SECONDARY
            }):Play()
            createTween(toggleButton, TweenInfo.new(0.3), {
                Position = UDim2.new(0, 2, 0, 2)
            }):Play()
        end
    end
    
    local function toggle()
        state = not state
        updateVisual()
        if onToggle then onToggle(state) end
    end
    
    -- Input handling
    toggleFrame.MouseButton1Click:Connect(toggle)
    toggleFrame.TouchTap:Connect(toggle)
    
    updateVisual()
    
    return {
        SetState = function(newState) 
            state = newState
            updateVisual()
        end,
        GetState = function() return state end,
        OnToggle = function(callback) onToggle = callback end,
        Container = container
    }
end

-- Aimbot Module
local function createAimbotModule(parent)
    local moduleFrame = Instance.new("Frame")
    moduleFrame.Name = "AimbotModule"
    moduleFrame.Size = UDim2.new(1, 0, 0, 200)
    moduleFrame.BackgroundTransparency = 1
    moduleFrame.Parent = parent
    
    -- Module Header
    local header = Instance.new("TextLabel")
    header.Name = "Header"
    header.Size = UDim2.new(1, 0, 0, 30)
    header.Position = UDim2.new(0, 0, 0, 0)
    header.BackgroundColor3 = COLORS.ACCENT
    header.BorderSizePixel = 0
    header.Text = "🎯 AIMBOT"
    header.TextColor3 = COLORS.TEXT
    header.Font = isMobile and Enum.Font.SourceSansBold or Enum.Font.GothamBold
    header.TextSize = isMobile and 16 or 18
    header.Parent = moduleFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = header
    
    -- Content Frame
    local content = Instance.new("Frame")
    content.Name = "Content"
    content.Size = UDim2.new(1, -20, 1, -40)
    content.Position = UDim2.new(0, 10, 0, 40)
    content.BackgroundTransparency = 1
    content.Parent = moduleFrame
    
    -- Aimbot Toggle
    local aimbotToggle = createToggle("Aimbot Ativado", false, content)
    aimbotToggle.Container.Position = UDim2.new(0, 0, 0, 10)
    
    -- Team Check Toggle
    local teamCheckToggle = createToggle("Verificar Time", true, content)
    teamCheckToggle.Container.Position = UDim2.new(0, 0, 0, 50)
    
    -- Settings
    local settingsLabel = Instance.new("TextLabel")
    settingsLabel.Size = UDim2.new(1, 0, 0, 20)
    settingsLabel.Position = UDim2.new(0, 0, 0, 90)
    settingsLabel.BackgroundTransparency = 1
    settingsLabel.Text = "Configurações: FOV=250, Smooth=1"
    settingsLabel.TextColor3 = COLORS.TEXT_MUTED
    settingsLabel.Font = isMobile and Enum.Font.SourceSans or Enum.Font.Gotham
    settingsLabel.TextSize = isMobile and 11 or 12
    settingsLabel.TextXAlignment = Enum.TextXAlignment.Left
    settingsLabel.Parent = content
    
    -- Aimbot Variables
    local AIMBOT_ENABLED = false
    local TEAMCHECK_ENABLED = true
    local SMOOTHNESS = 1
    local AIMBOT_FOV = 250
    local UPDATE_RATE = 0.016
    
    -- Cache System
    local playerCache = {}
    local lastUpdateTime = 0
    
    -- Aimbot Functions
    local function isAlive(plr)
        local char = plr.Character
        if not char then return false end
        local humanoid = char:FindFirstChildOfClass("Humanoid")
        return humanoid and humanoid.Health > 0
    end
    
    local function isVisible(part)
        if not part then return false end
        
        local cacheKey = part:GetFullName()
        local currentTime = tick()
        if playerCache[cacheKey] and currentTime - playerCache[cacheKey].time < 0.1 then
            return playerCache[cacheKey].visible
        end
        
        local origin = Camera.CFrame.Position
        local direction = part.Position - origin
        if direction.Magnitude == 0 then 
            playerCache[cacheKey] = {visible = true, time = currentTime}
            return true 
        end

        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
        raycastParams.FilterType = Enum.RaycastFilterType.Exclude
        raycastParams.IgnoreWater = true

        local raycastResult = Workspace:Raycast(origin, direction.Unit * math.min(direction.Magnitude, 1000), raycastParams)
        local isVisible = false
        
        if raycastResult then
            isVisible = raycastResult.Instance:IsDescendantOf(part.Parent)
        else
            isVisible = true
        end
        
        playerCache[cacheKey] = {visible = isVisible, time = currentTime}
        return isVisible
    end
    
    local function getClosestEnemyToCenter()
        local closest = nil
        local shortestDist = AIMBOT_FOV
        local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
        local currentTime = tick()

        -- Clear old cache
        for key, data in pairs(playerCache) do
            if currentTime - data.time > 1 then
                playerCache[key] = nil
            end
        end

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
    
    -- Connect toggles
    aimbotToggle.OnToggle(function(enabled)
        AIMBOT_ENABLED = enabled
    end)
    
    teamCheckToggle.OnToggle(function(enabled)
        TEAMCHECK_ENABLED = enabled
    end)
    
    -- Aimbot Loop
    local aimbotConnection
    local function startAimbot()
        if aimbotConnection then aimbotConnection:Disconnect() end
        
        aimbotConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if AIMBOT_ENABLED then
                local currentTime = tick()
                if currentTime - lastUpdateTime >= UPDATE_RATE then
                    local targetHead = getClosestEnemyToCenter()
                    if targetHead then
                        local currentCFrame = Camera.CFrame
                        local desiredCFrame = CFrame.new(currentCFrame.Position, targetHead.Position)
                        Camera.CFrame = currentCFrame:Lerp(desiredCFrame, SMOOTHNESS)
                    end
                    lastUpdateTime = currentTime
                end
            end
        end)
    end
    
    startAimbot()
    
    return moduleFrame
end

-- Main UI Creation
local function createMainUI()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    if screenGui then screenGui:Destroy() end

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "AdvancedHackUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui

    -- Main Frame
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, isMobile and 300 or 350, 0, 400)
    mainFrame.Position = UDim2.new(1, -360, 0, 100)
    mainFrame.BackgroundColor3 = COLORS.PRIMARY
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = screenGui
    
    -- Corner rounding
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 12)
    mainCorner.Parent = mainFrame
    
    -- Shadow effect
    local shadow = Instance.new("Frame")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 4, 1, 4)
    shadow.Position = UDim2.new(0, 2, 0, 2)
    shadow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.8
    shadow.BorderSizePixel = 0
    shadow.ZIndex = mainFrame.ZIndex - 1
    shadow.Parent = mainFrame
    
    local shadowCorner = Instance.new("UICorner")
    shadowCorner.CornerRadius = UDim.new(0, 12)
    shadowCorner.Parent = shadow
    
    -- Header Frame
    headerFrame = Instance.new("Frame")
    headerFrame.Name = "HeaderFrame"
    headerFrame.Size = UDim2.new(1, 0, 0, 40)
    headerFrame.Position = UDim2.new(0, 0, 0, 0)
    headerFrame.BackgroundColor3 = COLORS.SECONDARY
    headerFrame.BorderSizePixel = 0
    headerFrame.Parent = mainFrame
    
    local headerCorner = Instance.new("UICorner")
    headerCorner.CornerRadius = UDim.new(0, 12)
    headerCorner.Parent = headerFrame
    
    -- Title
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Size = UDim2.new(0.7, 0, 1, 0)
    titleLabel.Position = UDim2.new(0, 10, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "⚡ Advanced Hack"
    titleLabel.TextColor3 = COLORS.ACCENT
    titleLabel.Font = isMobile and Enum.Font.SourceSansBold or Enum.Font.GothamBold
    titleLabel.TextSize = isMobile and 18 or 20
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = headerFrame
    
    -- Minimize Button
    minimizeButton = createModernButton("MinimizeButton", "−", UDim2.new(0, 30, 0, 30), UDim2.new(1, -35, 0, 5), headerFrame)
    
    local minimizeCorner = Instance.new("UICorner")
    minimizeCorner.CornerRadius = UDim.new(0, 6)
    minimizeCorner.Parent = minimizeButton
    
    -- Content Frame
    contentFrame = Instance.new("ScrollingFrame")
    contentFrame.Name = "ContentFrame"
    contentFrame.Size = UDim2.new(1, -20, 1, -50)
    contentFrame.Position = UDim2.new(0, 10, 0, 45)
    contentFrame.BackgroundTransparency = 1
    contentFrame.BorderSizePixel = 0
    contentFrame.ScrollBarThickness = isMobile and 6 or 8
    contentFrame.Parent = mainFrame
    
    local contentLayout = Instance.new("UIListLayout")
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Padding = UDim.new(0, 10)
    contentLayout.Parent = contentFrame
    
    -- Setup dragging
    setupDragging(headerFrame)
    
    -- Minimize functionality
    local function toggleMinimize()
        isMinimized = not isMinimized
        
        if isMinimized then
            minimizeButton.Text = "+"
            createTween(contentFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, -20, 0, 0)
            }):Play()
            createTween(mainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, isMobile and 300 or 350, 0, 40)
            }):Play()
        else
            minimizeButton.Text = "−"
            createTween(contentFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(1, -20, 1, -50)
            }):Play()
            createTween(mainFrame, TweenInfo.new(0.3), {
                Size = UDim2.new(0, isMobile and 300 or 350, 0, 400)
            }):Play()
        end
    end
    
    minimizeButton.MouseButton1Click:Connect(toggleMinimize)
    minimizeButton.TouchTap:Connect(toggleMinimize)
    
    -- Add Aimbot Module
    local aimbotModule = createAimbotModule(contentFrame)
    aimbotModule.LayoutOrder = 1
    
    -- Update content size
    contentFrame.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 20)
end

-- Initialize
LocalPlayer.CharacterAdded:Connect(function()
    createMainUI()
end)

createMainUI()

-- Auto-resize content when modules are added
game:GetService("Workspace").ChildAdded:Connect(function()
    if contentFrame and contentFrame:FindFirstChild("UIListLayout") then
        local layout = contentFrame.UIListLayout
        contentFrame.CanvasSize = UDim2.new(0, 0, 1, layout.AbsoluteContentSize.Y + 20)
    end
end)

print("⚡ Advanced Hack UI Loaded Successfully!")
print("🎯 Aimbot ready to use!")
print("📱 Mobile compatible!")
