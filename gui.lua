
--// SERVICES
local Players = game:GetService("Players")
local _UserInputService = game:GetService("UserInputService")

--// STATE (recebido da cola)
local _State = {}

--// GUI ROOT
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MobileAimbotHub"
ScreenGui.ResetOnSpawn = false
ScreenGui.IgnoreGuiInset = true -- Evita GUI ser empurrada pelo notch
ScreenGui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")

--// FLOATING TOGGLE BUTTON
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.fromOffset(60, 60) -- Mínimo 60x60 para mobile
ToggleBtn.Position = UDim2.fromScale(0.05, 0.45)
ToggleBtn.Text = "≡"
ToggleBtn.TextScaled = true
ToggleBtn.BackgroundColor3 = Color3.fromRGB(30,30,30)
ToggleBtn.TextColor3 = Color3.new(1,1,1)
ToggleBtn.Parent = ScreenGui
ToggleBtn.Active = true
ToggleBtn.AutoButtonColor = true -- Melhor para mobile
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

MinBtn.Activated:Connect(function()
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
local ForceFrame = Instance.new("Frame")
ForceFrame.Size = UDim2.fromScale(0.9, 0.15)
ForceFrame.Position = UDim2.fromScale(0.05, 0.25)
ForceFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
ForceFrame.Parent = Content
ForceFrame.ZIndex = 4

Instance.new("UICorner", ForceFrame).CornerRadius = UDim.new(0.2,0)

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

local ValueLabel = Instance.new("TextLabel")
ValueLabel.Size = UDim2.fromScale(0.12,0.6)
ValueLabel.Position = UDim2.fromScale(0.69,0.2)
ValueLabel.Text = "16"
ValueLabel.TextScaled = true
ValueLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
ValueLabel.TextColor3 = Color3.new(1,1,1)
ValueLabel.Font = Enum.Font.GothamBold
ValueLabel.Parent = ForceFrame
ValueLabel.ZIndex = 5

Instance.new("UICorner", ValueLabel).CornerRadius = UDim.new(1,0)

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

--// FOV CIRCLE CONTROL
local FovFrame = Instance.new("Frame")
FovFrame.Size = UDim2.fromScale(0.9, 0.15)
FovFrame.Position = UDim2.fromScale(0.05, 0.45)
FovFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
FovFrame.Parent = Content
FovFrame.ZIndex = 4

Instance.new("UICorner", FovFrame).CornerRadius = UDim.new(0.2,0)

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

local FovValueLabel = Instance.new("TextLabel")
FovValueLabel.Size = UDim2.fromScale(0.12,0.6)
FovValueLabel.Position = UDim2.fromScale(0.62,0.2)
FovValueLabel.Text = "200"
FovValueLabel.TextScaled = true
FovValueLabel.BackgroundColor3 = Color3.fromRGB(40,40,40)
FovValueLabel.TextColor3 = Color3.new(1,1,1)
FovValueLabel.Font = Enum.Font.GothamBold
FovValueLabel.Parent = FovFrame
FovValueLabel.ZIndex = 5

Instance.new("UICorner", FovValueLabel).CornerRadius = UDim.new(1,0)

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

--// TEAMS TAB FRAME
local TeamsFrame = Instance.new("Frame")
TeamsFrame.Size = UDim2.fromScale(0.9, 0.15)
TeamsFrame.Position = UDim2.fromScale(0.05, 0.65)
TeamsFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
TeamsFrame.Parent = Content
TeamsFrame.ZIndex = 4

Instance.new("UICorner", TeamsFrame).CornerRadius = UDim.new(0.2,0)

local TeamsToggle = Instance.new("TextButton")
TeamsToggle.Size = UDim2.fromScale(1,1)
TeamsToggle.Text = "Team Check: OFF"
TeamsToggle.TextScaled = true
TeamsToggle.BackgroundTransparency = 1
TeamsToggle.TextColor3 = Color3.new(1,1,1)
TeamsToggle.Font = Enum.Font.GothamBold
TeamsToggle.Parent = TeamsFrame
TeamsToggle.ZIndex = 5

--// ESP FRAME
local EspFrame = Instance.new("Frame")
EspFrame.Size = UDim2.fromScale(0.9, 0.15)
EspFrame.Position = UDim2.fromScale(0.05, 0.82)
EspFrame.BackgroundColor3 = Color3.fromRGB(30,30,30)
EspFrame.Parent = Content
EspFrame.ZIndex = 4

Instance.new("UICorner", EspFrame).CornerRadius = UDim.new(0.2,0)

local EspToggle = Instance.new("TextButton")
EspToggle.Size = UDim2.fromScale(1,1)
EspToggle.Text = "ESP: OFF"
EspToggle.TextScaled = true
EspToggle.BackgroundTransparency = 1
EspToggle.TextColor3 = Color3.new(1,1,1)
EspToggle.Font = Enum.Font.GothamBold
EspToggle.Parent = EspFrame
EspToggle.ZIndex = 5

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

local circleCorner = Instance.new("UICorner")
circleCorner.CornerRadius = UDim.new(1, 0)
circleCorner.Parent = SilentCircle

local circleStroke = Instance.new("UIStroke")
circleStroke.Thickness = 2
circleStroke.Color = Color3.fromRGB(0, 170, 255)
circleStroke.Transparency = 0.2
circleStroke.Parent = SilentCircle

-- Atualiza SilentCircle para acompanhar a tela (mobile-safe)
game:GetService("RunService").RenderStepped:Connect(function()
	SilentCircle.Position = UDim2.fromScale(0.5, 0.5)
end)

--// DRAG SYSTEM (Mobile-Safe)
local function enableDrag(frame)
	local dragging = false
	local dragStart, startPos
	local dragInput
	local UIS = game:GetService("UserInputService")

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch
		or input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			dragInput = input -- Guarda qual input iniciou o drag
		end
	end)

	frame.InputEnded:Connect(function(input)
		if input == dragInput then -- Só para se for o mesmo input
			dragging = false
		end
	end)

	UIS.InputChanged:Connect(function(input)
		if dragging and input == dragInput then -- Só move se for o mesmo input
			local delta = input.Position - dragStart
			local deSilentCircle = SilentCircle
			frame.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)
end

--// EXPORTAR FUNÇÕES PARA A COLA
Main.Visible = false
Main.Parent = ScreenGui
Main.Active = true

ToggleBtn.Activated:Connect(function()
	Main.Visible = not Main.Visible
end)

ScreenGui.DisplayOrder = 999

enableDrag(ToggleBtn)
enableDrag(Header)

return {
	ScreenGui = ScreenGui,
	Main = Main,
	ToggleBtn = ToggleBtn,
	Switch = Switch,
	MinusBtn = MinusBtn,
	PlusBtn = PlusBtn,
	ValueLabel = ValueLabel,
	FovToggleBtn = FovToggleBtn,
	FovMinusBtn = FovMinusBtn,
	FovPlusBtn = FovPlusBtn,
	FovValueLabel = FovValueLabel,
	TeamsToggle = TeamsToggle,
	EspToggle = EspToggle,
	SilentCircle = SilentCircle,
	enableDrag = enableDrag
}
