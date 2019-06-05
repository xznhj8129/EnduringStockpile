AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Nuclear Waste Barrel"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"

ENT.Model                            =  "models/props/de_train/barrel.mdl"                     
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"

ENT.Bursts                           =  1
ENT.RadRadius                        =  1000
ENT.Mass                             =  200
ENT.RadPower                         =  2000

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.



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
        local pos = self:GetPos()
        
        RadiationSource(self, self.RadRadius, self.RadPower)
        
        self:NextThink(CurTime() + 0.25)
        return true
    end
end
