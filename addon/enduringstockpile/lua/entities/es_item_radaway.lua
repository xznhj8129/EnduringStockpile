AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.PrintName = "Rad-Away"
ENT.Author = "snowfrog"
ENT.Spawnable = true
ENT.AdminSpawnable = true 
ENT.Information	 = "Accelerates removal of radionucleides from the body for 60 seconds, causes 25 damage, take one." 
ENT.Category = "EnduringStockpile"
ENT.Model = "models/props_lab/jar01b.mdl"
ENT.Mass = 5

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

 
function ENT:Use(activator,caller)
	
	activator.EnduringStockpile.radaway = true
	activator.EnduringStockpile.radawaytime = 60
	
	activator:SetHealth(activator:Health() - 25)
	if activator:Health() <= 0 then
	    activator:Kill()
	end
	
    self.Entity:Remove()
end

