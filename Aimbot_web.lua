--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LP = Players.LocalPlayer

--// CAMERA SETUP
local Camera = workspace.CurrentCamera
while not Camera do
	task.wait()
	Camera = workspace.CurrentCamera
end

--// GLOBAL STATE
local AIMBOT_ENABLED = false
local AIMBOT_SETTINGS = {
	FOV = 250,
	SMOOTHNESS = 0.15,
	TARGET_PART = "Head",
	TEAM_CHECK = true,
	WALL_CHECK = true
}

--// FOV STATE
local FOV_ENABLED = false

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimbotHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

--// SILENT CIRCLE SETUP
local SilentRadius = 200
local SilentCircle = Instance.new("Frame")
SilentCircle.Name = "SilentCircle"
SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
SilentCircle.Position = UDim2.fromScale(0.5, 0.5)
SilentCircle.AnchorPoint = Vector2.new(0.5, 0.5)
SilentCircle.BackgroundTransparency = 1
SilentCircle.Parent = ScreenGui
SilentCircle.ZIndex = 1
SilentCircle.Visible = false

-- Deixar redondo
local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = SilentCircle

-- Contorno bonito
local circleStroke = Instance.new("UIStroke")
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(0, 170, 255)
circleStroke.Transparency = 0.2
circleStroke.Parent = SilentCircle

--// FLOATING TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.fromScale(0.12, 0.08)
ToggleBtn.Position = UDim2.fromScale(0.05, 0.45)
ToggleBtn.Text = "≡"
ToggleBtn.TextScaled = true
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Parent = ScreenGui
ToggleBtn.Active = true
ToggleBtn.ZIndex = 10

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0.4,0)

--// MAIN WINDOW
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.7, 0.6)
Main.Position = UDim2.fromScale(0.15, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Visible = false
Main.Parent = ScreenGui
Main.Active = true
Main.ZIndex = 2

Instance.new("UICorner", Main).CornerRadius = UDim.new(0.03,0)

local Stroke = Instance.new("UIStroke")
Stroke.Thickness = 1.5
Stroke.Color = Color3.fromRGB(60,60,60)
Stroke.Parent = Main

--// HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.fromScale(1, 0.12)
Header.BackgroundColor3 = Color3.fromRGB(28,28,28)
Header.Parent = Main
Header.Active = true
Header.ZIndex = 3

Instance.new("UICorner", Header).CornerRadius = UDim.new(0.03,0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(0.75,1)
Title.Position = UDim2.fromScale(0.05,0)
Title.Text = "Aimbot Hub"
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.Parent = Header
Title.ZIndex = 4

--// MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromScale(0.12, 0.7)
MinBtn.Position = UDim2.fromScale(0.86, 0.15)
MinBtn.Text = "–"
MinBtn.TextScaled = true
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Parent = Header
MinBtn.ZIndex = 4

Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0.3,0)

MinBtn.MouseButton1Click:Connect(function()
	Main.Visible = false
end)

--// CONTENT
local Content = Instance.new("Frame")
Content.Position = UDim2.fromScale(0,0.12)
Content.Size = UDim2.fromScale(1,0.88)
Content.BackgroundTransparency = 1
Content.Parent = Main
Content.ZIndex = 3

--// AIMBOT TOGGLE FRAME
local AimbotFrame = Instance.new("Frame")
AimbotFrame.Size = UDim2.fromScale(0.9, 0.15)
AimbotFrame.Position = UDim2.fromScale(0.05, 0.05)
AimbotFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
AimbotFrame.Parent = Content
AimbotFrame.ZIndex = 4

Instance.new("UICorner", AimbotFrame).CornerRadius = UDim.new(0.2,0)

local AimbotLabel = Instance.new("TextLabel")
AimbotLabel.Size = UDim2.fromScale(0.6,1)
AimbotLabel.Text = "Aimbot"
AimbotLabel.TextScaled = true
AimbotLabel.BackgroundTransparency = 1
AimbotLabel.TextColor3 = Color3.new(1,1,1)
AimbotLabel.Font = Enum.Font.Gotham
AimbotLabel.Parent = AimbotFrame
AimbotLabel.ZIndex = 5

local Switch = Instance.new("TextButton")
Switch.Size = UDim2.fromScale(0.25,0.6)
Switch.Position = UDim2.fromScale(0.7,0.2)
Switch.Text = "OFF"
Switch.TextScaled = true
Switch.BackgroundColor3 = Color3.fromRGB(120,40,40)
Switch.TextColor3 = Color3.new(1,1,1)
Switch.Font = Enum.Font.GothamBold
Switch.Parent = AimbotFrame
Switch.ZIndex = 5

Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

--// AIM FORCE CONTROL
local AimForce = 16 -- valor inicial (você usa depois na lógica)

local ForceFrame = Instance.new("Frame")
ForceFrame.Size = UDim2.fromScale(0.9, 0.15)
ForceFrame.Position = UDim2.fromScale(0.05, 0.25)
ForceFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
ForceFrame.Parent = Content
ForceFrame.ZIndex = 4

Instance.new("UICorner", ForceFrame).CornerRadius = UDim.new(0.2,0)

-- LABEL
local ForceLabel = Instance.new("TextLabel")
ForceLabel.Size = UDim2.fromScale(0.45,1)
ForceLabel.Position = UDim2.fromScale(0.03,0)
ForceLabel.Text = "Aim Force"
ForceLabel.TextScaled = true
ForceLabel.BackgroundTransparency = 1
ForceLabel.TextColor3 = Color3.new(1,1,1)
ForceLabel.Font = Enum.Font.Gotham
ForceLabel.Parent = ForceFrame
ForceLabel.ZIndex = 5

-- MINUS BUTTON
local MinusBtn = Instance.new("TextButton")
MinusBtn.Size = UDim2.fromScale(0.15,0.6)
MinusBtn.Position = UDim2.fromScale(0.52,0.2)
MinusBtn.Text = "-"
MinusBtn.TextScaled = true
MinusBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
MinusBtn.TextColor3 = Color3.new(1,1,1)
MinusBtn.Font = Enum.Font.GothamBold
MinusBtn.Parent = ForceFrame
MinusBtn.ZIndex = 5

Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(1,0)

-- VALUE DISPLAY
local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.fromScale(0.12,0.6)
ValueLabel.Position = UDim2.fromScale(0.69,0.2)
ValueLabel.Text = tostring(AimForce)
ValueLabel.TextScaled = true
ValueLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
ValueLabel.TextColor3 = Color3.new(1,1,1)
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.Parent = ForceFrame
ValueLabel.ZIndex = 5

Instance.new("UICorner", ValueLabel).CornerRadius = UDim.new(1,0)

-- PLUS BUTTON
local PlusBtn = Instance.new("TextButton")
PlusBtn.Size = UDim2.fromScale(0.15,0.6)
PlusBtn.Position = UDim2.fromScale(0.83,0.2)
PlusBtn.Text = "+"
PlusBtn.TextScaled = true
PlusBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
PlusBtn.TextColor3 = Color3.new(1,1,1)
PlusBtn.Font = Enum.Font.GothamBold
PlusBtn.Parent = ForceFrame
PlusBtn.ZIndex = 5

Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(1,0)

--// AIM FORCE INTERAÇÃO
MinusBtn.MouseButton1Click:Connect(function()
	AimForce = math.clamp(AimForce - 1, 1, 100)
	ValueLabel.Text = tostring(AimForce)
end)

PlusBtn.MouseButton1Click:Connect(function()
	AimForce = math.clamp(AimForce + 1, 1, 100)
	ValueLabel.Text = tostring(AimForce)
end)

--// FOV CIRCLE CONTROL
local FovFrame = Instance.new("Frame")
FovFrame.Size = UDim2.fromScale(0.9, 0.15)
FovFrame.Position = UDim2.fromScale(0.05, 0.45)
FovFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
FovFrame.Parent = Content
FovFrame.ZIndex = 4

Instance.new("UICorner", FovFrame).CornerRadius = UDim.new(0.2,0)

-- LABEL
local FovLabel = Instance.new("TextLabel")
FovLabel.Size = UDim2.fromScale(0.25,1)
FovLabel.Position = UDim2.fromScale(0.03,0)
FovLabel.Text = "FOV Circle"
FovLabel.TextScaled = true
FovLabel.BackgroundTransparency = 1
FovLabel.TextColor3 = Color3.new(1,1,1)
FovLabel.Font = Enum.Font.Gotham
FovLabel.Parent = FovFrame
FovLabel.ZIndex = 5

-- TOGGLE BUTTON
local FovToggleBtn = Instance.new("TextButton")
FovToggleBtn.Size = UDim2.fromScale(0.12, 0.6)
FovToggleBtn.Position = UDim2.fromScale(0.32, 0.2)
FovToggleBtn.Text = "OFF"
FovToggleBtn.TextScaled = true
FovToggleBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
FovToggleBtn.TextColor3 = Color3.new(1,1,1)
FovToggleBtn.Font = Enum.Font.GothamBold
FovToggleBtn.Parent = FovFrame
FovToggleBtn.ZIndex = 5

Instance.new("UICorner", FovToggleBtn).CornerRadius = UDim.new(1,0)

-- MINUS BUTTON
local FovMinusBtn = Instance.new("TextButton")
FovMinusBtn.Size = UDim2.fromScale(0.12,0.6)
FovMinusBtn.Position = UDim2.fromScale(0.47,0.2)
FovMinusBtn.Text = "-"
FovMinusBtn.TextScaled = true
FovMinusBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
FovMinusBtn.TextColor3 = Color3.new(1,1,1)
FovMinusBtn.Font = Enum.Font.GothamBold
FovMinusBtn.Parent = FovFrame
FovMinusBtn.ZIndex = 5

Instance.new("UICorner", FovMinusBtn).CornerRadius = UDim.new(1,0)

-- VALUE DISPLAY
local FovValueLabel = Instance.new("TextLabel")
FovValueLabel.Size = UDim2.fromScale(0.12,0.6)
FovValueLabel.Position = UDim2.fromScale(0.62,0.2)
FovValueLabel.Text = tostring(SilentRadius)
FovValueLabel.TextScaled = true
FovValueLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
FovValueLabel.TextColor3 = Color3.new(1,1,1)
FovValueLabel.Font = Enum.Font.GothamBold
FovValueLabel.Parent = FovFrame
FovValueLabel.ZIndex = 5

Instance.new("UICorner", FovValueLabel).CornerRadius = UDim.new(1,0)

-- PLUS BUTTON
local FovPlusBtn = Instance.new("TextButton")
FovPlusBtn.Size = UDim2.fromScale(0.12,0.6)
FovPlusBtn.Position = UDim2.fromScale(0.77,0.2)
FovPlusBtn.Text = "+"
FovPlusBtn.TextScaled = true
FovPlusBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
FovPlusBtn.TextColor3 = Color3.new(1,1,1)
FovPlusBtn.Font = Enum.Font.GothamBold
FovPlusBtn.Parent = FovFrame
FovPlusBtn.ZIndex = 5

Instance.new("UICorner", FovPlusBtn).CornerRadius = UDim.new(1,0)

--// FOV CIRCLE INTERAÇÃO
FovToggleBtn.MouseButton1Click:Connect(function()
	FOV_ENABLED = not FOV_ENABLED
	
	if FOV_ENABLED then
		FovToggleBtn.Text = "ON"
		FovToggleBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)
		SilentCircle.Visible = true
		AIMBOT_SETTINGS.FOV = SilentRadius
	else
		FovToggleBtn.Text = "OFF"
		FovToggleBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
		SilentCircle.Visible = false
		AIMBOT_SETTINGS.FOV = 0
	end
end)

FovMinusBtn.MouseButton1Click:Connect(function()
	SilentRadius = math.clamp(SilentRadius - 10, 50, 600)
	SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
	if FOV_ENABLED then
		AIMBOT_SETTINGS.FOV = SilentRadius
	end
	FovValueLabel.Text = tostring(SilentRadius)
end)

FovPlusBtn.MouseButton1Click:Connect(function()
	SilentRadius = math.clamp(SilentRadius + 10, 50, 600)
	SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
	if FOV_ENABLED then
		AIMBOT_SETTINGS.FOV = SilentRadius
	end
	FovValueLabel.Text = tostring(SilentRadius)
end)

--// TOGGLE MAIN WINDOW
ToggleBtn.MouseButton1Click:Connect(function()
	Main.Visible = not Main.Visible
end)

--// DRAG SYSTEM (MOBILE + PC)
local dragging, dragStart, startPos

local function enableDrag(frame)
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and (
			input.UserInputType == Enum.UserInputType.Touch or
			input.UserInputType == Enum.UserInputType.MouseMovement
		) then
			local delta = input.Position - dragStart
			frame.Position = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
		end
	end)

	UIS.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = false
		end
	end)
end

enableDrag(Main)
enableDrag(ToggleBtn)

--// AIMBOT FUNCTIONS
local function getClosestPlayer()
	local closestPlayer = nil
	local closestDistance = math.huge
	
	for _, player in pairs(Players:GetPlayers()) do
		if player ~= LP and player.Character and player.Character:FindFirstChild(AIMBOT_SETTINGS.TARGET_PART) then
			-- Team check
			if AIMBOT_SETTINGS.TEAM_CHECK and player.Team and player.Team == LP.Team then
				continue
			end
			
			-- Verificar se alvo está vivo
			local targetHumanoid = player.Character:FindFirstChild("Humanoid")
			if not targetHumanoid or targetHumanoid.Health <= 0 then
				continue
			end
			
			-- Wall check
			if AIMBOT_SETTINGS.WALL_CHECK then
				local targetPart = player.Character[AIMBOT_SETTINGS.TARGET_PART]
				local rayOrigin = Camera.CFrame.Position
				local rayDirection = (targetPart.Position - rayOrigin).Unit * 1000
				
				local params = RaycastParams.new()
				params.FilterType = Enum.RaycastFilterType.Exclude
				params.FilterDescendantsInstances = {LP.Character}
				
				local raycastResult = workspace:Raycast(rayOrigin, rayDirection, params)
				
				if raycastResult and not raycastResult.Instance:IsDescendantOf(player.Character) then
					continue
				end
			end
			
			local targetPart = player.Character[AIMBOT_SETTINGS.TARGET_PART]
			local screenPos, onScreen = Camera:WorldToViewportPoint(targetPart.Position)
			
			if not onScreen then continue end
			
			local distance = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude
			
			if distance < closestDistance and distance <= AIMBOT_SETTINGS.FOV then
				closestDistance = distance
				closestPlayer = player
			end
		end
	end
	
	return closestPlayer
end

local function aimAtTarget(target)
	if not target or not target.Character then return end
	
	local targetPart = target.Character:FindFirstChild(AIMBOT_SETTINGS.TARGET_PART)
	if not targetPart then return end
	
	local camera = Camera
	local currentCFrame = camera.CFrame
	local targetCFrame = CFrame.new(camera.CFrame.Position, targetPart.Position)
	
	-- Smooth aim direto e previsível
	local forceMultiplier = AimForce / 100
	local adjustedSmoothness = math.clamp(forceMultiplier, 0.01, 1)
	
	camera.CFrame = currentCFrame:Lerp(targetCFrame, adjustedSmoothness)
end

--// AIMBOT LOOP
local aimbotConnection
local function startAimbot()
	if aimbotConnection then
		aimbotConnection:Disconnect()
	end

	aimbotConnection = RunService.RenderStepped:Connect(function()
		if not AIMBOT_ENABLED then return end
		if not LP.Character then return end

		local humanoid = LP.Character:FindFirstChild("Humanoid")
		if not humanoid or humanoid.Health <= 0 then return end

		local target = getClosestPlayer()
		if target then
			-- Verificação adicional de tela
			local _, onScreen = Camera:WorldToViewportPoint(
				target.Character[AIMBOT_SETTINGS.TARGET_PART].Position
			)
			if not onScreen then return end
			
			aimAtTarget(target)
		end
	end)
end

local function stopAimbot()
	if aimbotConnection then
		aimbotConnection:Disconnect()
		aimbotConnection = nil
	end
end

--// UPDATE TOGGLE FUNCTION
Switch.MouseButton1Click:Connect(function()
	AIMBOT_ENABLED = not AIMBOT_ENABLED

	if AIMBOT_ENABLED then
		Switch.Text = "ON"
		Switch.BackgroundColor3 = Color3.fromRGB(40,120,40)
		startAimbot()
	else
		Switch.Text = "OFF"
		Switch.BackgroundColor3 = Color3.fromRGB(120,40,40)
		stopAimbot()
	end
end)
