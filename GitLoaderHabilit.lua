_G.HabilitWars = _G.HabilitWars or {}

print("🔗 Carregando módulos...")

-- lógica primeiro
loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/main/logicaHabilit.lua"))()

-- depois GUI
loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua"))()

print("✅ Sistema carregado!")
print("🎯 Sistema pronto para uso!")
