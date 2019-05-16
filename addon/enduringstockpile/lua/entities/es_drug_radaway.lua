AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Rad-Away"
ENT.Author = "snowfrog"
ENT.Spawnable = true
ENT.AdminSpawnable = true 
ENT.Information	 = "Accelerates removal of radionucleides from the body for 60 seconds, causes 25 damage, take one." 
ENT.Category = "EnduringStockpile"
ENT.Model = "models/props_lab/jar01b.mdl"
ENT.MASS = 5

function ENT:SpawnFunction( ply, tr, Classname)

    if ( !tr.Hit ) then return end

    local SpawnPos = tr.HitPos + tr.HitNormal * 16

    local ent = ents.Create(Classname)
    ent:SetPos( SpawnPos )
    ent:Spawn()
    ent:Activate()

    return ent

end

function ENT:Initialize()	
	self:SetModel( self.Model )
	self:PhysicsInit( SOLID_VPHYSICS )

	local phys = self:GetPhysicsObject()  	
	if phys:IsValid() then  		
		phys:Wake()  	
	end
	
	if( self.MASS )then
		self.Entity:GetPhysicsObject():SetMass( self.MASS );
	end
	
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

