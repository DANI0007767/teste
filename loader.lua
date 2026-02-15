--// 1. CRIAR A TABELA GLOBAL PRIMEIRO (SEGURANÇA)
_G.AimbotHub = {
	-- Estado inicial
	AIMBOT_ENABLED = false,
	AIM_FORCE = 16,
	FOV_ENABLED = false,
	SilentRadius = 200,
	TEAM_CHECK = false, -- false mira em todos, true ignora seu time
	ESP_ENABLED = false, -- NOVA VARIÁVEL: ESP toggle
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

-- Mobile-proof: garantir que o botão ≡ sempre funcione
GUI.ToggleBtn.Visible = true
GUI.ToggleBtn.Active = true
GUI.ToggleBtn.Selectable = true
GUI.ToggleBtn.ZIndex = 1000

--// 3. CONECTAR E MOSTRAR
-- Sincronizar estado com a GUI
_G.AimbotHub.GUI = GUI
_G.AimbotHub.Logic = Logic

-- Atualizar textos iniciais com base na tabela global
GUI.ValueInput.Text = tostring(_G.AimbotHub.AIM_FORCE)
GUI.FovValueLabel.Text = tostring(_G.AimbotHub.SilentRadius)
GUI.TeamsToggle.Text = _G.AimbotHub.TEAM_CHECK and "Team Check: ON" or "Team Check: OFF"
GUI.TeamsToggle.BackgroundColor3 = _G.AimbotHub.TEAM_CHECK and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)
GUI.EspToggle.Text = _G.AimbotHub.ESP_ENABLED and "ESP: ON" or "ESP: OFF"
GUI.EspToggle.BackgroundColor3 = _G.AimbotHub.ESP_ENABLED and Color3.fromRGB(40,120,40) or Color3.fromRGB(120,40,40)

--// 4. EVENTOS DA GUI

-- Toggle do Aimbot (removido evento duplicado do ToggleBtn)
GUI.Switch.Activated:Connect(function()
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

-- Validação do input do TextBox
GUI.ValueInput.FocusLost:Connect(function()
	local value = tonumber(GUI.ValueInput.Text)

	if not value then
		-- valor inválido, restaura
		GUI.ValueInput.Text = tostring(_G.AimbotHub.AIM_FORCE)
		return
	end

	value = math.clamp(math.floor(value), 1, 100)

	_G.AimbotHub.AIM_FORCE = value
	AimForce = value -- Sincroniza variável local
	GUI.ValueInput.Text = tostring(value)
end)

-- Prevenir texto muito longo (UX)
GUI.ValueInput:GetPropertyChangedSignal("Text"):Connect(function()
	if #GUI.ValueInput.Text > 3 then
		GUI.ValueInput.Text = string.sub(GUI.ValueInput.Text, 1, 3)
	end
end)

GUI.MinusBtn.Activated:Connect(function()
	AimForce = math.clamp(AimForce - 1, 1, 100)
	_G.AimbotHub.AIM_FORCE = AimForce
	GUI.ValueInput.Text = tostring(AimForce)
end)

GUI.PlusBtn.Activated:Connect(function()
	AimForce = math.clamp(AimForce + 1, 1, 100)
	_G.AimbotHub.AIM_FORCE = AimForce
	GUI.ValueInput.Text = tostring(AimForce)
end)

-- Controle de FOV Circle
local SilentRadius = _G.AimbotHub.SilentRadius

GUI.FovToggleBtn.Activated:Connect(function()
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

GUI.FovMinusBtn.Activated:Connect(function()
	SilentRadius = math.clamp(SilentRadius - 10, 50, 600)
	_G.AimbotHub.SilentRadius = SilentRadius
	GUI.SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
	if _G.AimbotHub.FOV_ENABLED then
		_G.AimbotHub.FOV = SilentRadius
	end
	GUI.FovValueLabel.Text = tostring(SilentRadius)
end)

GUI.FovPlusBtn.Activated:Connect(function()
	SilentRadius = math.clamp(SilentRadius + 10, 50, 600)
	_G.AimbotHub.SilentRadius = SilentRadius
	GUI.SilentCircle.Size = UDim2.fromOffset(SilentRadius, SilentRadius)
	if _G.AimbotHub.FOV_ENABLED then
		_G.AimbotHub.FOV = SilentRadius
	end
	GUI.FovValueLabel.Text = tostring(SilentRadius)
end)

-- Toggle de Team Check (Simplificado)
GUI.TeamsToggle.Activated:Connect(function()
	_G.AimbotHub.TEAM_CHECK = not _G.AimbotHub.TEAM_CHECK
	
	if _G.AimbotHub.TEAM_CHECK then
		GUI.TeamsToggle.Text = "Team Check: ON"
		GUI.TeamsToggle.BackgroundColor3 = Color3.fromRGB(40,120,40) -- Verde
	else
		GUI.TeamsToggle.Text = "Team Check: OFF"
		GUI.TeamsToggle.BackgroundColor3 = Color3.fromRGB(120,40,40) -- Vermelho
	end
end)

-- Toggle de ESP
GUI.EspToggle.Activated:Connect(function()
	_G.AimbotHub.ESP_ENABLED = not _G.AimbotHub.ESP_ENABLED
	
	if _G.AimbotHub.ESP_ENABLED then
		GUI.EspToggle.Text = "ESP: ON"
		GUI.EspToggle.BackgroundColor3 = Color3.fromRGB(40,120,40) -- Verde
		Logic.startEspLoop()
	else
		GUI.EspToggle.Text = "ESP: OFF"
		GUI.EspToggle.BackgroundColor3 = Color3.fromRGB(120,40,40) -- Vermelho
		Logic.stopEspLoop()
	end
end)

-- Ativar drag
GUI.enableDrag(GUI.Main)
GUI.enableDrag(GUI.ToggleBtn)

-- Configurações finais da GUI
GUI.ScreenGui.DisplayOrder = 999

-- Controle explícito do ToggleBtn (mobile-proof)
local guiOpen = true

GUI.ToggleBtn.Activated:Connect(function()
	guiOpen = not guiOpen
	
	GUI.Main.Visible = guiOpen
	
	-- segurança mobile + Header control
	GUI.Main.Active = guiOpen
	GUI.Main.Selectable = guiOpen
	
	-- Controlar Header para drag funcionar
	if guiOpen then
		GUI.Main.ZIndex = 2
		-- Header será controlado pelo próprio GUI
	else
		GUI.Main.ZIndex = 1
		-- Header será desativado pelo próprio GUI
	end
end)

--// 5. INICIAR SISTEMA
print("🎯 Aimbot Hub carregado com sucesso!")
print("📋 GUI: Carregada e visível")
print("🧠 Lógica: Carregada")
print("🔗 Estado: Conectado")
print("✅ Sistema pronto para uso!")

-- Não precisa de loop, eventos cuidam de tudo
