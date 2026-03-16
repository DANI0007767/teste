--// CARREGADOR HABILIT WARS - SISTEMA GIT
--// Autor: Sistema de Carregamento
--// Repositório: https://github.com/DANI0007767/teste.git

--// TABELA GLOBAL PRIMEIRO (SEGURANÇA)
_G.HabilitWars = {
	-- Estado inicial
	SYSTEM_ENABLED = false,
	ABILITY_DISPLAY = false,
	ESP_PLAYERS = false,
	AUTO_DETECT = true,
	
	-- Configurações
	TARGET_PART = "Head",
	DISPLAY_DISTANCE = 200,
	UPDATE_INTERVAL = 0.5,
	REFRESH_RATE = 3
}

--// SERVICES
local HttpService = game:GetService("HttpService")

--// 2. CARREGAR MÓDULOS USANDO HttpService (FUNCIONA EM EXECUTORES)
print("🔗 Carregando módulos do repositório Git...")

-- Carregar lógica principal
local logic_code = HttpService:GetAsync("https://raw.githubusercontent.com/DANI0007767/teste/main/logicaHabilit.lua")
task.wait(0.5) -- Intervalo para executores lentos

-- Carregar GUI (se existir)
local gui_code = HttpService:GetAsync("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua")
task.wait(0.5) -- Intervalo para executores lentos

-- Carregar sistema de login (se existir)
local login_code = HttpService:GetAsync("https://raw.githubusercontent.com/DANI0007767/teste/main/LoginComOGit.lua")
task.wait(0.5) -- Intervalo para executores lentos

--// 3. EXECUTAR MÓDULOS CARREGADOS
local Logic = assert(loadstring(logic_code), "Erro ao carregar lógica")()
local GUI = gui_code and assert(loadstring(gui_code), "Erro ao carregar GUI")() or {}
local Login = login_code and assert(loadstring(login_code), "Erro ao carregar Login")() or {}

--// 4. CONECTAR SISTEMAS
-- Sincronizar estado global
_G.HabilitWars.Logic = Logic
_G.HabilitWars.GUI = GUI
_G.HabilitWars.Login = Login

--// 5. INICIAR SISTEMA AUTOMATICAMENTE
_G.HabilitWars.SYSTEM_ENABLED = true

-- Função para recarregar sistema do Git
function _G.HabilitWars.reloadFromGit()
	print("🔄 Recarregando sistema do repositório Git...")
	
	-- Parar sistema atual
	_G.HabilitWars.SYSTEM_ENABLED = false
	task.wait(1)
	
	-- Recarregar módulos
	local new_logic = HttpService:GetAsync("https://raw.githubusercontent.com/DANI0007767/teste/main/logicaHabilit.lua")
	local new_gui = HttpService:GetAsync("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua")
	local new_login = HttpService:GetAsync("https://raw.githubusercontent.com/DANI0007767/teste/main/LoginComOGit.lua")
	
	-- Executar novos módulos
	_G.HabilitWars.Logic = assert(loadstring(new_logic), "Erro ao recarregar lógica")()
	_G.HabilitWars.GUI = new_gui and assert(loadstring(new_gui), "Erro ao recarregar GUI")() or {}
	_G.HabilitWars.Login = new_login and assert(loadstring(new_login), "Erro ao recarregar Login")() or {}
	
	-- Reativar sistema
	_G.HabilitWars.SYSTEM_ENABLED = true
	print("✅ Sistema recarregado com sucesso!")
end

--// 6. COMANDOS RÁPIDOS
-- Comando para recarregar: _G.HabilitWars.reloadFromGit()

--// 7. INICIALIZAÇÃO FINAL
print("🎮 Habilit Wars carregado com sucesso!")
print("📋 Lógica: Carregada")
print("🖥️ GUI: Carregada") 
print("🔐 Login: Carregado")
print("🔗 Estado: Conectado ao repositório Git")
print("✅ Sistema pronto para uso!")
print("💡 Use _G.HabilitWars.reloadFromGit() para recarregar")

-- Auto-update check (opcional)
task.spawn(function()
	while true do
		task.wait(_G.HabilitWars.REFRESH_RATE * 60) -- Verificar a cada X minutos
		if _G.HabilitWars.SYSTEM_ENABLED then
			print("🔄 Verificando atualizações no repositório...")
			-- Aqui pode adicionar lógica para verificar se há atualizações
		end
	end
end)
