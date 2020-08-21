if SERVER then
	--AddCSLuaFile("eslua/server/es_convars.lua")
	--AddCSLuaFile("eslua/server/es_functions.lua")
	AddCSLuaFile("eslua/server/es_radiation.lua")

	--include("eslua/server/es_convars.lua")
	--include("eslua/server/es_functions.lua")
	include("eslua/server/es_radiation.lua")
	include("eslua/client/es_hud.lua")
end
if CLIENT then
	AddCSLuaFile("eslua/client/es_hud.lua")
	include("eslua/client/es_hud.lua")
end