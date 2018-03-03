AddCSLuaFile()

DEFINE_BASECLASS( "hb_base_dumb" )


ENT.Spawnable                         =  true         
ENT.AdminSpawnable                    =  true 

ENT.PrintName                        =  "Wire Geiger Counter"
ENT.Author                           =  "snowfrog"
ENT.Contact                          =  ""
ENT.Category                         =  "EnduringStockpile"

ENT.Model                            =  "models/props_lab/powerbox02d.mdl"           

ENT.TraceLength                      =  0         
ENT.Mass                             =  30
ENT.Shocktime                        =  1
ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

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
    self.GeigerCounter = 1
    self.RadCount = 0
    self.RadsPerHour = 0
    self.Outputs  = Wire_CreateOutputs(self, { "RadsPerHour" })
    Wire_TriggerOutput(self, "RadsPerHour", self.RadsPerHour)
 end
end

function ENT:Explode()
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:PhysicsCollide( data, physobj )
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

function ENT:Think(ply) 
    self.spawned = true
    if (SERVER) then
        if !self:IsValid() then return end
        self.RadsPerHour = self.RadCount/4
        Wire_TriggerOutput(self, "RadsPerHour", self.RadsPerHour)
        self.RadCount = 0
        self:NextThink(CurTime() + 1)
        return true
    end
end
