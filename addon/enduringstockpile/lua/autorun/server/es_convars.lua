AddCSLuaFile()

if GetConVar("es_falloutlength") == nil then
	CreateConVar("es_falloutlength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
if GetConVar("es_debug") == nil then
	CreateConVar("es_debug", "0", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
