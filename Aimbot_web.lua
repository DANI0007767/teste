--// SERVICES
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local LP = Players.LocalPlayer

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileHub"
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

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0.4,0)

--// MAIN WINDOW
local Main = Instance.new("Frame")
Main.Size = UDim2.fromScale(0.7, 0.6)
Main.Position = UDim2.fromScale(0.15, 0.2)
Main.BackgroundColor3 = Color3.fromRGB(20,20,20)
Main.Visible = false
Main.Parent = ScreenGui

Instance.new("UICorner", Main).CornerRadius = UDim.new(0.03,0)
Instance.new("UIStroke", Main).Thickness = 1.5

--// HEADER
local Header = Instance.new("Frame")
Header.Size = UDim2.fromScale(1, 0.12)
Header.BackgroundColor3 = Color3.fromRGB(28,28,28)
Header.Parent = Main
Instance.new("UICorner", Header).CornerRadius = UDim.new(0.03,0)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.fromScale(1,1)
Title.Text = "My Hub"
Title.TextScaled = true
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.new(1,1,1)
Title.Parent = Header

--// CONTENT
local Content = Instance.new("Frame")
Content.Position = UDim2.fromScale(0,0.12)
Content.Size = UDim2.fromScale(1,0.88)
Content.BackgroundTransparency = 1
Content.Parent = Main

--// TOGGLE OPEN/CLOSE
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
		if dragging and (input.UserInputType == Enum.UserInputType.Touch 
		or input.UserInputType == Enum.UserInputType.MouseMovement) then
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
