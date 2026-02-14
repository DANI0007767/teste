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
	WALL_CHECK = false
}

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimbotHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = LP:WaitForChild("PlayerGui")

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
	
	-- Smooth aim com verificação adicional
	if AIMBOT_SETTINGS.SMOOTHNESS >= 1 then
		camera.CFrame = targetCFrame
	else
		camera.CFrame = currentCFrame:Lerp(targetCFrame, AIMBOT_SETTINGS.SMOOTHNESS)
	end
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
