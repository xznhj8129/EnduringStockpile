AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.PrintName = "Iodine pills"
ENT.Author = "snowfrog"
ENT.Spawnable = true
ENT.AdminSpawnable = true 
ENT.Information	 = "25% protection from radiation for 2 minutes, take one." 
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
 
function ENT:Use(activator,caller)
	if (activator.EnduringStockpile.radx) then
		return
	end
	
	activator.EnduringStockpile.radx = true
	activator.EnduringStockpile.radxtime = 120
	
    self.Entity:Remove()
end

