AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Radioactive debris"
ENT.Information	                     =  "Definitely not graphite, comrade."
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"
ENT.Model                            =  ""

ENT.Mass                             =  100
ENT.RadPower                         =  1000
ENT.HalfLife                         =  3600
ENT.Time                             =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     local modellist = {"models/props_debris/concrete_spawnchunk001c.mdl",
                        "models/props_debris/concrete_spawnchunk001d.mdl",
                        "models/props_debris/concrete_spawnchunk001e.mdl",
                        "models/props_debris/concrete_spawnchunk001f.mdl",
                        "models/props_debris/concrete_spawnchunk001g.mdl",
                        "models/props_debris/concrete_spawnchunk001h.mdl",
                        "models/props_debris/concrete_spawnchunk001i.mdl",
                        "models/props_debris/concrete_spawnchunk001j.mdl",
                        "models/props_debris/concrete_spawnchunk001k.mdl"}
    self:SetModel( modellist[math.random(9)] )
    self:LoadModel()
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetUseType( ONOFF_USE ) -- doesen't fucking work
    self.EntList={}
    self.EntCount = 0
    self.HalfLife = GetConVar("es_isotopes_halflife"):GetInt()
    if self.HalfLife == nil then
        CreateConVar("es_isotopes_halflife", "3600", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        self.HalfLife = 3600
    end
    local phys = self:GetPhysicsObject()
    local skincount = self:SkinCount()
    if (phys:IsValid()) then
     phys:SetMass(self.Mass)
     phys:Wake()
    end
 end
end

function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
     self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
     ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end
 
function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end
        
        local radpower_left = NuclearHalfLife(self.RadPower, self.Time, self.HalfLife)
        RadiationSource(self, radpower_left)
        
        self:NextThink(CurTime() + 0.25)
        self.Time = self.Time+0.25
        return true
    end
end


