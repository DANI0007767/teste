--// 1. CRIAR A TABELA GLOBAL PRIMEIRO (SEGURANÇA)
_G.AimbotHub = {
	-- Estado inicial
	AIMBOT_ENABLED = false,
	AIM_FORCE = 16,
	FOV_ENABLED = false,
	SilentRadius = 200,
	TEAM_CHECK = false,
	ESP_ENABLED = false,
	GLOBAL_AIM = false,
	TeamsOpen = false,
	
	-- Configurações
	TARGET_PART = "Head",
	WALL_CHECK = true,
	FOV = 250
}

--// SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

--// 2. CARREGAR MÓDULUS USANDO game:HttpGet (FUNCIONA EM EXECUTORES)
local gui_code = game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/refs/heads/main/gui_new.lua")
task.wait(0.5)
local logic_code = game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/refs/heads/main/logica.lua")
task.wait(0.5)

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
GUI.AimForceInput.Text = tostring(_G.AimbotHub.AIM_FORCE)
GUI.SilentCircle.Visible = _G.AimbotHub.FOV_ENABLED and not _G.AimbotHub.GLOBAL_AIM

--// 4. EVENTOS DA GUI

-- Toggle principal da janela
local guiOpen = true
GUI.ToggleBtn.Activated:Connect(function()
	guiOpen = not guiOpen
	
	GUI.Main.Visible = guiOpen
	
	-- segurança mobile + Header control
	GUI.Main.Active = guiOpen
	GUI.Main.Selectable = guiOpen
end)

-- Toggle do Aimbot
GUI.AimbotButton.Activated:Connect(function()
	_G.AimbotHub.AIMBOT_ENABLED = not _G.AimbotHub.AIMBOT_ENABLED
	
	if _G.AimbotHub.AIMBOT_ENABLED then
		GUI.AimbotButton.Text = "AIMBOT : ON"
		GUI.AimbotButton.BackgroundColor3 = Color3.fromRGB(40,120,40)
		Logic.startAimbot()
	else
		GUI.AimbotButton.Text = "AIMBOT : OFF"
		GUI.AimbotButton.BackgroundColor3 = Color3.fromRGB(120,40,40)
		Logic.stopAimbot()
	end
end)

-- Toggle de Global Aim
GUI.AimGlobalButton.Activated:Connect(function()
	_G.AimbotHub.GLOBAL_AIM = not _G.AimbotHub.GLOBAL_AIM
	
	if _G.AimbotHub.GLOBAL_AIM then
		GUI.AimGlobalButton.Text = "AIM GLOBAL : ON"
		GUI.AimGlobalButton.BackgroundColor3 = Color3.fromRGB(60,120,255)
		-- UX: desativar FOV visual no Global Aim
		GUI.SilentCircle.Visible = false
	else
		GUI.AimGlobalButton.Text = "AIM GLOBAL : OFF"
		GUI.AimGlobalButton.BackgroundColor3 = Color3.fromRGB(120,40,40)
		-- UX: reativar FOV visual se FOV_ENABLED estiver ativo
		GUI.SilentCircle.Visible = _G.AimbotHub.FOV_ENABLED
	end
end)

-- Toggle de ESP
GUI.EspButton.Activated:Connect(function()
	_G.AimbotHub.ESP_ENABLED = not _G.AimbotHub.ESP_ENABLED
	
	if _G.AimbotHub.ESP_ENABLED then
		GUI.EspButton.Text = "ESP : ON"
		GUI.EspButton.BackgroundColor3 = Color3.fromRGB(40,120,40)
		Logic.startEspLoop()
	else
		GUI.EspButton.Text = "ESP : OFF"
		GUI.EspButton.BackgroundColor3 = Color3.fromRGB(120,40,40)
		Logic.stopEspLoop()
	end
end)

-- Validação do input do TextBox
local AimForce = _G.AimbotHub.AIM_FORCE

GUI.AimForceInput.FocusLost:Connect(function()
	local value = tonumber(GUI.AimForceInput.Text)

	if not value then
		-- valor inválido, restaura
		GUI.AimForceInput.Text = tostring(_G.AimbotHub.AIM_FORCE)
		return
	end

	value = math.clamp(math.floor(value), 1, 100)

	_G.AimbotHub.AIM_FORCE = value
	AimForce = value -- Sincroniza variável local
	GUI.AimForceInput.Text = tostring(value)
end)

-- Prevenir texto muito longo (UX)
GUI.AimForceInput:GetPropertyChangedSignal("Text"):Connect(function()
	if #GUI.AimForceInput.Text > 3 then
		GUI.AimForceInput.Text = string.sub(GUI.AimForceInput.Text, 1, 3)
	end
end)

-- Ativar drag
GUI.enableDrag(GUI.Main)

-- Configurações finais da GUI
GUI.ScreenGui.DisplayOrder = 999

--// 5. INICIAR SISTEMA
print("🎯 Aimbot Hub carregado com sucesso!")
print("📋 GUI: Carregada e visível")
print("🧠 Lógica: Carregada")
print("🔗 Estado: Conectado")
print("✅ Sistema pronto para uso!")

-- Não precisa de loop, eventos cuidam de tudo
