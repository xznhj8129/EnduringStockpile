AddCSLuaFile()

if GetConVar("es_falloutlength") == nil then
	CreateConVar("es_falloutlength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("es_debug") == nil then
	CreateConVar("es_debug", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("es_max_shieldingtrace") == nil then
	CreateConVar("es_max_shieldingtrace", "50", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("es_max_radrange") == nil then
	CreateConVar("es_max_radrange", "1000000", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("es_electronics_rad_damage") == nil then
	CreateConVar("es_electronics_rad_damage", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
