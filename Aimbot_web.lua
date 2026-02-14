local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Configurações do Aimbot
local AIMBOT_ENABLED = false
local TEAMCHECK_ENABLED = true
local SMOOTHNESS = 1
local AIMBOT_FOV = 250
local UPDATE_RATE = 0.016

-- Sistema de cache
local playerCache = {}
local lastUpdateTime = 0

-- UI Library
local Library = {}
Library.Windows = {}

function Library:Create(name)
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = name
    ScreenGui.Parent = game:GetService("CoreGui")
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Parent = ScreenGui
    MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    MainFrame.BorderSizePixel = 0
    MainFrame.Position = UDim2.new(0.5, -200, 0.5, -150)
    MainFrame.Size = UDim2.new(0, 400, 0, 300)
    MainFrame.Visible = false
    
    Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)
    
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.Parent = MainFrame
    TitleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 45)
    TitleBar.BorderSizePixel = 0
    TitleBar.Position = UDim2.new(0, 0, 0, 0)
    TitleBar.Size = UDim2.new(1, 0, 0, 30)
    
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 8)
    TitleCorner.Parent = TitleBar
    
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TitleBar
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 0)
    Title.Size = UDim2.new(1, -40, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = name
    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
    Title.TextSize = 14
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local CloseButton = Instance.new("TextButton")
    CloseButton.Name = "CloseButton"
    CloseButton.Parent = TitleBar
    CloseButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    CloseButton.BackgroundTransparency = 1
    CloseButton.Position = UDim2.new(1, -30, 0, 0)
    CloseButton.Size = UDim2.new(0, 30, 1, 0)
    CloseButton.Font = Enum.Font.GothamBold
    CloseButton.Text = "×"
    CloseButton.TextColor3 = Color3.fromRGB(255, 100, 100)
    CloseButton.TextSize = 18
    
    local TabFrame = Instance.new("Frame")
    TabFrame.Name = "TabFrame"
    TabFrame.Parent = MainFrame
    TabFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
    TabFrame.BorderSizePixel = 0
    TabFrame.Position = UDim2.new(0, 0, 0, 30)
    TabFrame.Size = UDim2.new(0, 100, 1, -30)
    
    Instance.new("UICorner", TabFrame).CornerRadius = UDim.new(0, 8)
    
    local ContentFrame = Instance.new("Frame")
    ContentFrame.Name = "ContentFrame"
    ContentFrame.Parent = MainFrame
    ContentFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
    ContentFrame.BorderSizePixel = 0
    ContentFrame.Position = UDim2.new(0, 100, 0, 30)
    ContentFrame.Size = UDim2.new(1, -100, 1, -30)
    
    Instance.new("UICorner", ContentFrame).CornerRadius = UDim.new(0, 8)
    
    local ContentListLayout = Instance.new("UIListLayout")
    ContentListLayout.Parent = ContentFrame
    ContentListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ContentListLayout.Padding = UDim.new(0, 5)
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = MainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    CloseButton.MouseButton1Click:Connect(function()
        MainFrame.Visible = false
    end)
    
    local window = {
        ScreenGui = ScreenGui,
        MainFrame = MainFrame,
        TabFrame = TabFrame,
        ContentFrame = ContentFrame,
        Tabs = {},
        CurrentTab = nil
    }
    
    table.insert(Library.Windows, window)
    
    function window:ToggleUI()
        MainFrame.Visible = not MainFrame.Visible
    end
    
    function window:Tab(name, icon)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name .. "Tab"
        TabButton.Parent = TabFrame
        TabButton.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
        TabButton.BorderSizePixel = 0
        TabButton.Position = UDim2.new(0, 0, 0, #self.Tabs * 35)
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.Font = Enum.Font.Gotham
        TabButton.Text = name
        TabButton.TextColor3 = Color3.fromRGB(200, 200, 200)
        TabButton.TextSize = 12
        
        Instance.new("UICorner", TabButton).CornerRadius = UDim.new(0, 4)
        
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Parent = ContentFrame
        TabContent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.Position = UDim2.new(0, 0, 0, 0)
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.Visible = false
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
        
        local TabListLayout = Instance.new("UIListLayout")
        TabListLayout.Parent = TabContent
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        TabListLayout.Padding = UDim.new(0, 8)
        
        TabButton.MouseButton1Click:Connect(function()
            if self.CurrentTab then
                self.CurrentTab.Content.Visible = false
                self.CurrentTab.Button.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                self.CurrentTab.Button.TextColor3 = Color3.fromRGB(200, 200, 200)
            end
            
            TabContent.Visible = true
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            self.CurrentTab = {
                Content = TabContent,
                Button = TabButton
            }
        end)
        
        local tab = {
            Content = TabContent,
            Button = TabButton
        }
        
        table.insert(self.Tabs, tab)
        
        if #self.Tabs == 1 then
            TabButton.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabContent.Visible = true
            self.CurrentTab = tab
        end
        
        return {
            Section = function(self, title)
                local SectionFrame = Instance.new("Frame")
                SectionFrame.Name = title .. "Section"
                SectionFrame.Parent = TabContent
                SectionFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
                SectionFrame.BorderSizePixel = 0
                SectionFrame.Position = UDim2.new(0, 10, 0, 0)
                SectionFrame.Size = UDim2.new(1, -20, 0, 25)
                SectionFrame.LayoutOrder = #TabContent:GetChildren()
                
                Instance.new("UICorner", SectionFrame).CornerRadius = UDim.new(0, 4)
                
                local SectionLabel = Instance.new("TextLabel")
                SectionLabel.Name = "SectionLabel"
                SectionLabel.Parent = SectionFrame
                SectionLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                SectionLabel.BackgroundTransparency = 1
                SectionLabel.Position = UDim2.new(0, 8, 0, 0)
                SectionLabel.Size = UDim2.new(1, -16, 1, 0)
                SectionLabel.Font = Enum.Font.GothamBold
                SectionLabel.Text = title
                SectionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
                SectionLabel.TextSize = 12
                SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
                
                return {
                    Toggle = function(self, text, callback)
                        local ToggleFrame = Instance.new("Frame")
                        ToggleFrame.Name = text .. "Toggle"
                        ToggleFrame.Parent = TabContent
                        ToggleFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        ToggleFrame.BackgroundTransparency = 1
                        ToggleFrame.Position = UDim2.new(0, 10, 0, 0)
                        ToggleFrame.Size = UDim2.new(1, -20, 0, 30)
                        ToggleFrame.LayoutOrder = #TabContent:GetChildren()
                        
                        local ToggleLabel = Instance.new("TextLabel")
                        ToggleLabel.Name = "ToggleLabel"
                        ToggleLabel.Parent = ToggleFrame
                        ToggleLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        ToggleLabel.BackgroundTransparency = 1
                        ToggleLabel.Position = UDim2.new(0, 0, 0, 0)
                        ToggleLabel.Size = UDim2.new(1, -50, 1, 0)
                        ToggleLabel.Font = Enum.Font.Gotham
                        ToggleLabel.Text = text
                        ToggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                        ToggleLabel.TextSize = 12
                        ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local ToggleButton = Instance.new("TextButton")
                        ToggleButton.Name = "ToggleButton"
                        ToggleButton.Parent = ToggleFrame
                        ToggleButton.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                        ToggleButton.BorderSizePixel = 0
                        ToggleButton.Position = UDim2.new(1, -40, 0.5, -10)
                        ToggleButton.Size = UDim2.new(0, 35, 0, 20)
                        ToggleButton.Font = Enum.Font.Gotham
                        ToggleButton.Text = ""
                        ToggleButton.TextSize = 12
                        
                        Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 10)
                        
                        local ToggleDot = Instance.new("Frame")
                        ToggleDot.Name = "ToggleDot"
                        ToggleDot.Parent = ToggleButton
                        ToggleDot.BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                        ToggleDot.BorderSizePixel = 0
                        ToggleDot.Position = UDim2.new(0, 2, 0.5, -6)
                        ToggleDot.Size = UDim2.new(0, 12, 0, 12)
                        
                        Instance.new("UICorner", ToggleDot).CornerRadius = UDim.new(0, 6)
                        
                        local toggleState = false
                        
                        ToggleButton.MouseButton1Click:Connect(function()
                            toggleState = not toggleState
                            callback(toggleState)
                            
                            if toggleState then
                                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                                    BackgroundColor3 = Color3.fromRGB(100, 200, 100)
                                }):Play()
                                TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
                                    Position = UDim2.new(1, -14, 0.5, -6),
                                    BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                                }):Play()
                            else
                                TweenService:Create(ToggleButton, TweenInfo.new(0.2), {
                                    BackgroundColor3 = Color3.fromRGB(60, 60, 70)
                                }):Play()
                                TweenService:Create(ToggleDot, TweenInfo.new(0.2), {
                                    Position = UDim2.new(0, 2, 0.5, -6),
                                    BackgroundColor3 = Color3.fromRGB(200, 200, 200)
                                }):Play()
                            end
                        end)
                        
                        return ToggleFrame
                    end,
                    
                    Slider = function(self, text, min, max, default, callback)
                        local SliderFrame = Instance.new("Frame")
                        SliderFrame.Name = text .. "Slider"
                        SliderFrame.Parent = TabContent
                        SliderFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        SliderFrame.BackgroundTransparency = 1
                        SliderFrame.Position = UDim2.new(0, 10, 0, 0)
                        SliderFrame.Size = UDim2.new(1, -20, 0, 50)
                        SliderFrame.LayoutOrder = #TabContent:GetChildren()
                        
                        local SliderLabel = Instance.new("TextLabel")
                        SliderLabel.Name = "SliderLabel"
                        SliderLabel.Parent = SliderFrame
                        SliderLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        SliderLabel.BackgroundTransparency = 1
                        SliderLabel.Position = UDim2.new(0, 0, 0, 0)
                        SliderLabel.Size = UDim2.new(1, 0, 0, 20)
                        SliderLabel.Font = Enum.Font.Gotham
                        SliderLabel.Text = text .. ": " .. default
                        SliderLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                        SliderLabel.TextSize = 12
                        SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local SliderBar = Instance.new("Frame")
                        SliderBar.Name = "SliderBar"
                        SliderBar.Parent = SliderFrame
                        SliderBar.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
                        SliderBar.BorderSizePixel = 0
                        SliderBar.Position = UDim2.new(0, 0, 0, 30)
                        SliderBar.Size = UDim2.new(1, 0, 0, 8)
                        
                        Instance.new("UICorner", SliderBar).CornerRadius = UDim.new(0, 4)
                        
                        local SliderFill = Instance.new("Frame")
                        SliderFill.Name = "SliderFill"
                        SliderFill.Parent = SliderBar
                        SliderFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
                        SliderFill.BorderSizePixel = 0
                        SliderFill.Position = UDim2.new(0, 0, 0, 0)
                        SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
                        
                        Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)
                        
                        local SliderButton = Instance.new("TextButton")
                        SliderButton.Name = "SliderButton"
                        SliderButton.Parent = SliderBar
                        SliderButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        SliderButton.BorderSizePixel = 0
                        SliderButton.Position = UDim2.new((default - min) / (max - min), -6, 0.5, -6)
                        SliderButton.Size = UDim2.new(0, 12, 0, 12)
                        SliderButton.Font = Enum.Font.Gotham
                        SliderButton.Text = ""
                        SliderButton.TextSize = 12
                        
                        Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(0, 6)
                        
                        local sliding = false
                        
                        SliderButton.MouseButton1Down:Connect(function()
                            sliding = true
                        end)
                        
                        UserInputService.InputEnded:Connect(function(input)
                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                sliding = false
                            end
                        end)
                        
                        UserInputService.InputChanged:Connect(function(input)
                            if sliding and input.UserInputType == Enum.UserInputType.MouseMovement then
                                local mousePos = UserInputService:GetMouseLocation()
                                local barPos = SliderBar.AbsolutePosition
                                local barSize = SliderBar.AbsoluteSize
                                
                                local percent = math.clamp((mousePos.X - barPos.X) / barSize.X, 0, 1)
                                local value = min + (max - min) * percent
                                
                                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                                SliderButton.Position = UDim2.new(percent, -6, 0.5, -6)
                                SliderLabel.Text = text .. ": " .. math.floor(value)
                                
                                callback(value)
                            end
                        end)
                        
                        return SliderFrame
                    end,
                    
                    TextBox = function(self, text, callback)
                        local TextBoxFrame = Instance.new("Frame")
                        TextBoxFrame.Name = text .. "TextBox"
                        TextBoxFrame.Parent = TabContent
                        TextBoxFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        TextBoxFrame.BackgroundTransparency = 1
                        TextBoxFrame.Position = UDim2.new(0, 10, 0, 0)
                        TextBoxFrame.Size = UDim2.new(1, -20, 0, 30)
                        TextBoxFrame.LayoutOrder = #TabContent:GetChildren()
                        
                        local TextBoxLabel = Instance.new("TextLabel")
                        TextBoxLabel.Name = "TextBoxLabel"
                        TextBoxLabel.Parent = TextBoxFrame
                        TextBoxLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                        TextBoxLabel.BackgroundTransparency = 1
                        TextBoxLabel.Position = UDim2.new(0, 0, 0, 0)
                        TextBoxLabel.Size = UDim2.new(0, 100, 1, 0)
                        TextBoxLabel.Font = Enum.Font.Gotham
                        TextBoxLabel.Text = text
                        TextBoxLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
                        TextBoxLabel.TextSize = 12
                        TextBoxLabel.TextXAlignment = Enum.TextXAlignment.Left
                        
                        local TextBoxInput = Instance.new("TextBox")
                        TextBoxInput.Name = "TextBoxInput"
                        TextBoxInput.Parent = TextBoxFrame
                        TextBoxInput.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
                        TextBoxInput.BorderSizePixel = 0
                        TextBoxInput.Position = UDim2.new(0, 110, 0.5, -12)
                        TextBoxInput.Size = UDim2.new(1, -120, 0, 24)
                        TextBoxInput.Font = Enum.Font.Gotham
                        TextBoxInput.PlaceholderText = "Enter value..."
                        TextBoxInput.Text = ""
                        TextBoxInput.TextColor3 = Color3.fromRGB(255, 255, 255)
                        TextBoxInput.TextSize = 12
                        
                        Instance.new("UICorner", TextBoxInput).CornerRadius = UDim.new(0, 4)
                        
                        TextBoxInput.FocusLost:Connect(function(enterPressed)
                            if enterPressed then
                                callback(TextBoxInput.Text)
                            end
                        end)
                        
                        return TextBoxFrame
                    end
                }
            end
        }
    end
    
    return window
end

-- Funções do Aimbot
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

-- Criar UI
local Window = Library:Create("Aimbot Pro")
local HomeTab = Window:Tab("Home", "rbxassetid://10888331510")
local SettingsTab = Window:Tab("Settings", "rbxassetid://12296135476")

-- Home Tab
HomeTab:Section("Main Controls")
HomeTab:Toggle("Aimbot Status", function(state)
    AIMBOT_ENABLED = state
end)

HomeTab:Toggle("Team Check", function(state)
    TEAMCHECK_ENABLED = state
end)

-- Settings Tab
SettingsTab:Section("Aimbot Settings")
SettingsTab:Slider("Smoothness", 0.1, 1, SMOOTHNESS, function(value)
    SMOOTHNESS = value
end)

SettingsTab:Slider("FOV", 50, 500, AIMBOT_FOV, function(value)
    AIMBOT_FOV = value
end)

SettingsTab:TextBox("Update Rate", function(value)
    local num = tonumber(value)
    if num and num > 0 then
        UPDATE_RATE = num
    end
end)

-- Botão Toggle Flutuante
local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "ToggleGui_Aimbot"
ToggleGui.Parent = game:GetService("CoreGui")

local ToggleButton = Instance.new("TextButton")
ToggleButton.Name = "Toggle"
ToggleButton.Parent = ToggleGui
ToggleButton.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
ToggleButton.BackgroundTransparency = 0.1
ToggleButton.BorderSizePixel = 0
ToggleButton.Position = UDim2.new(0, 10, 0.5, -25)
ToggleButton.Size = UDim2.new(0, 60, 0, 50)
ToggleButton.Font = Enum.Font.GothamBold
ToggleButton.Text = "AIM"
ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleButton.TextSize = 14
ToggleButton.Draggable = true

Instance.new("UICorner", ToggleButton).CornerRadius = UDim.new(0, 8)

ToggleButton.MouseButton1Click:Connect(function()
    Window:ToggleUI()
end)

-- Main Loop
RunService.RenderStepped:Connect(function(deltaTime)
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

-- Keybind para toggle UI
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and input.KeyCode == Enum.KeyCode.F then
        Window:ToggleUI()
    end
end)
