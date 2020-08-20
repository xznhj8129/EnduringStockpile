AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Nuclear Waste Barrel"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"

ENT.Model                            =  "models/thedoctor/radbarrel.mdl"                     
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"

ENT.Bursts                           =  1
ENT.Mass                             =  200
ENT.RadPower                         =  2000
ENT.HalfLife                         =  3600
ENT.Time                             =  0

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


function ENT:SpawnFunction( ply, tr )
    if ( not tr.Hit ) then return end
    self.GBOWNER = ply
    local ent = ents.Create( self.ClassName )
    self.HalfLife = GetConVar("es_isotopes_halflife"):GetInt()
    if self.HalfLife == nil then
        CreateConVar("es_isotopes_halflife", "3600", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        self.HalfLife = 3600
    end
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
