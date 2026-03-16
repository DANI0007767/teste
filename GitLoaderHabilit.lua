--// CARREGADOR HABILIT WARS - SISTEMA GIT
--// Loader otimizado para executores

_G.HabilitWars = {
	SYSTEM_ENABLED = false,
	ABILITY_DISPLAY = true,
	ESP_PLAYERS = false,
	AUTO_DETECT = true,

	TARGET_PART = "Head",
	DISPLAY_DISTANCE = 200,
	UPDATE_INTERVAL = 0.5,
	REFRESH_RATE = 3
}

print("🔗 Conectando ao GitHub...")

-- função segura para carregar scripts
local function loadGitScript(url)
	local success, result = pcall(function()
		return game:HttpGet(url)
	end)

	if success and result then
		local func = loadstring(result)
		if func then
			print("✅ Script carregado:", url)
			return func()
		else
			warn("❌ Erro no loadstring:", url)
		end
	else
		warn("❌ Falha ao baixar:", url)
	end

	return {}
end

-- carregar módulos
local Logic = loadGitScript("https://raw.githubusercontent.com/DANI0007767/teste/main/logicaHabilit.lua")
local GUI = loadGitScript("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua")
local Login = loadGitScript("https://raw.githubusercontent.com/DANI0007767/teste/main/LoginComOGit.lua")

-- conectar sistemas
_G.HabilitWars.Logic = Logic
_G.HabilitWars.GUI = GUI
_G.HabilitWars.Login = Login

_G.HabilitWars.SYSTEM_ENABLED = true

print("🎮 Habilit Wars carregado!")
print("📡 Sistema conectado ao GitHub")

-- reload
function _G.HabilitWars.reloadFromGit()

	print("🔄 Recarregando sistema...")

	_G.HabilitWars.SYSTEM_ENABLED = false
	task.wait(1)

	_G.HabilitWars.Logic = loadGitScript("https://raw.githubusercontent.com/DANI0007767/teste/main/logicaHabilit.lua")
	_G.HabilitWars.GUI = loadGitScript("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua")
	_G.HabilitWars.Login = loadGitScript("https://raw.githubusercontent.com/DANI0007767/teste/main/LoginComOGit.lua")

	_G.HabilitWars.SYSTEM_ENABLED = true

	print("✅ Sistema atualizado!")
end
