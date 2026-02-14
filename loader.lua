--// 1. CRIAR A TABELA GLOBAL PRIMEIRO (SEGURANÇA)
_G.AimbotHub = {
	-- Estado inicial
	AIMBOT_ENABLED = false,
	AIM_FORCE = 16,
	FOV_ENABLED = false,
	SilentRadius = 200,
	AllowedTeams = {},
	TeamsOpen = false,
	
	-- Configurações
	TARGET_PART = "Head",
	WALL_CHECK = true,
	FOV = 250
}

--// SERVICES
local Players = game:GetService("Players")

--// 2. CARREGAR MÓDULUS USANDO game:HttpGet (FUNCIONA EM EXECUTORES)
local gui_code = game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/refs/heads/main/gui.lua")
task.wait(0.5) -- Intervalo para executores lentos
local logic_code = game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/refs/heads/main/logica.lua")
task.wait(0.5) -- Intervalo para executores lentos

local GUI = loadstring(gui_code)()
local Logic = loadstring(logic_code)()

--// 3. CONECTAR E MOSTRAR (FORÇAR APARIÇÃO PARA TESTE)
GUI.Main.Visible = true -- Janela visível imediatamente

-- Sincronizar estado com a GUI
_G.AimbotHub.GUI = GUI
_G.AimbotHub.Logic = Logic

--// 4. EVENTOS DA GUI

-- Toggle principal da janela
GUI.ToggleBtn.MouseButton1Click:Connect(function()
	GUI.Main.Visible = not GUI.Main.Visible
end)

-- Toggle do Aimbot
GUI.Switch.MouseButton1Click:Connect(function()
	_G.AimbotHub.AIMBOT_ENABLED = not _G.AimbotHub.AIMBOT_ENABLED
	
	if _G.AimbotHub.AIMBOT_ENABLED then
		GUI.Switch.Text = "ON"
		GUI.Switch.BackgroundColor3 = Color3.fromRGB(40,120,40)
		Logic.startAimbot()
	else
		GUI.Switch.Text = "OFF"
		GUI.Switch.BackgroundColor3 = Color3.fromRGB(120,40,40)
		Logic.stopAimbot()
	end
end)

-- Controle de Aim Force
local AimForce = _G.AimbotHub.AIM_FORCE

GUI.MinusBtn.MouseButton1Click:Connect(function()
	AimForce = math.clamp(AimForce - 1, 1, 100)
	_G.AimbotHub.AIM_FORCE = AimForce
	GUI.ValueLabel.Text = tostring(AimForce)
end)

GUI.PlusBtn.MouseButton1Click:Connect(function()
	AimForce = math.clamp(AimForce + 1, 1, 100)
	_G.AimbotHub.AIM_FORCE = AimForce
	GUI.ValueLabel.Text = tostring(AimForce)
end)

-- Controle de FOV Circle
local SilentRadius = _G.AimbotHub.SilentRadius

GUI.FovToggleBtn.MouseButton1Click:Connect(function()
	_G.AimbotHub.FOV_ENABLED = not _G.AimbotHub.FOV_ENABLED
	
	if _G.AimbotHub.FOV_ENABLED then
		GUI.FovToggleBtn.Text = "ON"
		GUI.FovToggleBtn.BackgroundColor3 = Color3.fromRGB(40,120,40)
		GUI.SilentCircle.Visible = true
		_G.AimbotHub.FOV = SilentRadius
	else
		GUI.FovToggleBtn.Text = "OFF"
		GUI.FovToggleBtn.BackgroundColor3 = Color3.fromRGB(120,40,40)
		GUI.SilentCircle.Visible = false
		_G.AimbotHub.FOV = 0
	end
end)

GUI.FovMinusBtn.MouseButton1Click:Connect(function()
	SilentRadius = math.clamp(SilentRadius - 10, 50, 600)
	_G.AimbotHub.SilentRadius = SilentRadius
	GUI.SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
	if _G.AimbotHub.FOV_ENABLED then
		_G.AimbotHub.FOV = SilentRadius
	end
	GUI.FovValueLabel.Text = tostring(SilentRadius)
end)

GUI.FovPlusBtn.MouseButton1Click:Connect(function()
	SilentRadius = math.clamp(SilentRadius + 10, 50, 600)
	_G.AimbotHub.SilentRadius = SilentRadius
	GUI.SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
	if _G.AimbotHub.FOV_ENABLED then
		_G.AimbotHub.FOV = SilentRadius
	end
	GUI.FovValueLabel.Text = tostring(SilentRadius)
end)

-- Sistema de Teams
local function loadTeams()
	-- Limpar times existentes
	for _, child in pairs(GUI.TeamsList:GetChildren()) do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end
	
	-- Coletar times únicos
	local foundTeams = {}
	for _, player in pairs(Players:GetPlayers()) do
		if player.Team then
			local teamName = player.Team.Name
			if not _G.AimbotHub.AllowedTeams[teamName] then
				_G.AimbotHub.AllowedTeams[teamName] = false
			end
			foundTeams[teamName] = true
		end
	end
	
	-- Criar opções de times
	local teamButtons = {}
	for teamName, _ in pairs(foundTeams) do
		local Option = Instance.new("Frame")
		Option.Size = UDim2.fromScale(1, 0.25)
		Option.BackgroundColor3 = Color3.fromRGB(35,35,35)
		Option.Parent = GUI.TeamsList

		Instance.new("UICorner", Option).CornerRadius = UDim.new(0.3,0)

		local Label = Instance.new("TextLabel")
		Label.Size = UDim2.fromScale(0.7,1)
		Label.Text = teamName
		Label.TextScaled = true
		Label.BackgroundTransparency = 1
		Label.TextColor3 = Color3.new(1,1,1)
		Label.Font = Enum.Font.Gotham
		Label.Parent = Option

		local Check = Instance.new("TextButton")
		Check.Size = UDim2.fromScale(0.2,0.6)
		Check.Position = UDim2.fromScale(0.75,0.2)
		Check.Text = "OFF"
		Check.TextScaled = true
		Check.BackgroundColor3 = Color3.fromRGB(120,40,40)
		Check.TextColor3 = Color3.new(1,1,1)
		Check.Font = Enum.Font.GothamBold
		Check.Parent = Option

		Instance.new("UICorner", Check).CornerRadius = UDim.new(1,0)
		
		teamButtons[teamName] = Check
		
		Check.MouseButton1Click:Connect(function()
			_G.AimbotHub.AllowedTeams[teamName] = not _G.AimbotHub.AllowedTeams[teamName]
			
			if _G.AimbotHub.AllowedTeams[teamName] then
				Check.Text = "ON"
				Check.BackgroundColor3 = Color3.fromRGB(40,120,40)
			else
				Check.Text = "OFF"
				Check.BackgroundColor3 = Color3.fromRGB(120,40,40)
			end
		end)
		
		if _G.AimbotHub.AllowedTeams[teamName] then
			Check.Text = "ON"
			Check.BackgroundColor3 = Color3.fromRGB(40,120,40)
		end
	end
	
	-- Botões Select/Clear All
	GUI.SelectAllBtn.MouseButton1Click:Connect(function()
		for teamName, _ in pairs(_G.AimbotHub.AllowedTeams) do
			_G.AimbotHub.AllowedTeams[teamName] = true
		end
		loadTeams()
	end)
	
	GUI.ClearAllBtn.MouseButton1Click:Connect(function()
		for teamName, _ in pairs(_G.AimbotHub.AllowedTeams) do
			_G.AimbotHub.AllowedTeams[teamName] = false
		end
		loadTeams()
	end)
end

-- Animação da aba Teams
GUI.TeamsToggle.MouseButton1Click:Connect(function()
	_G.AimbotHub.TeamsOpen = not _G.AimbotHub.TeamsOpen
	GUI.TeamsToggle.Text = _G.AimbotHub.TeamsOpen and "Teams ▲" or "Teams ▼"
	
	local teamCount = 0
	for _ in pairs(_G.AimbotHub.AllowedTeams) do
		teamCount = teamCount + 1
	end
	
	local maxHeight = math.min(teamCount * 0.3, 2.0)
	
	GUI.TeamsList:TweenSize(
		_G.AimbotHub.TeamsOpen and UDim2.fromScale(1, maxHeight) or UDim2.fromScale(1, 0),
		Enum.EasingDirection.Out,
		Enum.EasingStyle.Quad,
		0.25,
		true
	)
end)

-- Carregar times iniciais
Players.PlayerAdded:Connect(loadTeams)
Players.PlayerRemoving:Connect(loadTeams)
loadTeams()

-- Ativar drag
GUI.enableDrag(GUI.Main)
GUI.enableDrag(GUI.ToggleBtn)

--// 5. INICIAR SISTEMA
print("🎯 Aimbot Hub carregado com sucesso!")
print("📋 GUI: Carregada e visível")
print("🧠 Lógica: Carregada")
print("🔗 Estado: Conectado")
print("✅ Sistema pronto para uso!")

-- Não precisa de loop, eventos cuidam de tudo
