-- LOADER PRINCIPAL HABILIT WARS
-- Sistema de carregamento modular

-- Criar tabela global (seguro para múltiplas execuções)
_G.HabilitWars = _G.HabilitWars or {}

print("🔗 Carregando módulos do Habilit Wars...")

-- Carregar lógica primeiro
print("📦 Carregando lógica...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/main/logicaHabilit.lua"))()

-- Carregar GUI depois
print("🎮 Carregando interface...")
loadstring(game:HttpGet("https://raw.githubusercontent.com/DANI0007767/teste/main/GuiHabilit.lua"))()

print("✅ Habilit Wars carregado com sucesso!")
print("🎯 Sistema pronto para uso!")
