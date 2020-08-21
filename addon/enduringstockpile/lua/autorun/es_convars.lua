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

if GetConVar("es_isotopes_halflife") == nil then
	CreateConVar("es_isotopes_halflife", "3600", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("es_reactor_debris") == nil then
	CreateConVar("es_reactor_debris", "20", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("es_reactor_explode") == nil then
	CreateConVar("es_reactor_explode", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end

if GetConVar("es_reactor_falloutlen") == nil then
	CreateConVar("es_reactor_falloutlen", "3", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
end
