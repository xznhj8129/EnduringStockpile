AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  false
ENT.AdminSpawnable		             =  false
ENT.AdminOnly                        =  true

ENT.PrintName		                 =  "Test isotope"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"
ENT.Model                            =  "models/props_lab/jar01b.mdl"                     

ENT.Mass                             =  20
ENT.RadPower                         =  500
ENT.HalfLife                         =  1800
ENT.Time                             =  0


function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
     self:PhysicsInit( SOLID_VPHYSICS )
     self:SetSolid( SOLID_VPHYSICS )
     self:SetMoveType( MOVETYPE_VPHYSICS )
     self:SetUseType( ONOFF_USE ) -- doesen't fucking work
     self.EntList={}
     self.EntCount = 0
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

function ENT:OnTakeDamage( dmginfo ) 
    self.Entity:TakePhysicsDamage( dmginfo ) 
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
