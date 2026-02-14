--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--// GLOBAL STATE
getgenv().AIMBOT_ENABLED = false

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

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0.4,0)

--// MAIN WINDOW
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.7, 0.6)
Main.Position = UDim2.fromScale(0.15, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Visible = false
Main.Parent = ScreenGui
Main.Active = true

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

Instance.new("UICorner", Header).CornerRadius = UDim.new(0.03,0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(0.8,1)
Title.Position = UDim2.fromScale(0.05,0)
Title.Text = "Aimbot Hub"
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Font = Enum.Font.GothamBold
Title.Parent = Header

--// MINIMIZE BUTTON
local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.fromScale(0.12, 0.7)
MinBtn.Position = UDim2.fromScale(0.86, 0.15)
MinBtn.Text = "–"
MinBtn.TextScaled = true
MinBtn.BackgroundColor3 = Color3.fromRGB(40,40,40)
MinBtn.TextColor3 = Color3.new(1,1,1)
MinBtn.Parent = Header

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

--// AIMBOT TOGGLE
local AimbotFrame = Instance.new("Frame")
AimbotFrame.Size = UDim2.fromScale(0.9, 0.15)
AimbotFrame.Position = UDim2.fromScale(0.05, 0.05)
AimbotFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
AimbotFrame.Parent = Content

Instance.new("UICorner", AimbotFrame).CornerRadius = UDim.new(0.2,0)

local AimbotLabel = Instance.new("TextLabel")
AimbotLabel.Size = UDim2.fromScale(0.6,1)
AimbotLabel.Text = "Aimbot"
AimbotLabel.TextScaled = true
AimbotLabel.BackgroundTransparency = 1
AimbotLabel.TextColor3 = Color3.new(1,1,1)
AimbotLabel.Font = Enum.Font.Gotham
AimbotLabel.Parent = AimbotFrame

local Switch = Instance.new("TextButton")
Switch.Size = UDim2.fromScale(0.25,0.6)
Switch.Position = UDim2.fromScale(0.7,0.2)
Switch.Text = "OFF"
Switch.TextScaled = true
Switch.BackgroundColor3 = Color3.fromRGB(120,40,40)
Switch.TextColor3 = Color3.new(1,1,1)
Switch.Font = Enum.Font.GothamBold
Switch.Parent = AimbotFrame

Instance.new("UICorner", Switch).CornerRadius = UDim.new(1,0)

Switch.MouseButton1Click:Connect(function()
	AIMBOT_ENABLED = not AIMBOT_ENABLED

	if AIMBOT_ENABLED then
		Switch.Text = "ON"
		Switch.BackgroundColor3 = Color3.fromRGB(40,120,40)
	else
		Switch.Text = "OFF"
		Switch.BackgroundColor3 = Color3.fromRGB(120,40,40)
	end
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
