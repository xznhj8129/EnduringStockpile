AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Nuclear Reactor Core"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"

ENT.Model                            =  "models/props_wasteland/laundry_washer001a.mdl"                     
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"

ENT.Mass                             =  2000
ENT.RadPower                         =  25000

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.


function ENT:Initialize()
    if (SERVER) then
        self:LoadModel()
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetUseType( ONOFF_USE ) -- doesen't fucking work
        local phys = self:GetPhysicsObject()
        local skincount = self:SkinCount()
        if (phys:IsValid()) then
            phys:SetMass(self.Mass)
            phys:SetBuoyancyRatio(0)
            phys:Wake()
        end
        if (skincount > 0) then
            self:SetSkin(math.random(0,skincount))
        end
        self.Exploded = false
        if !(WireAddon == nil) then 
            self.Inputs   = Wire_CreateInputs(self, { "Power", "Explode" }) 
            self.Outputs  = Wire_CreateOutputs(self, { "RadPower" })
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
 

function ENT:TriggerInput(iname, value)
     if (!self:IsValid()) then return end
	 if (iname == "Power") then
        self.RadPower = ((value/100)*975000) + 25000
        Wire_TriggerOutput(self, "RadPower", self.RadPower)
	 end	 
end 


function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end
        
        RadiationSource(self, self.RadPower)
        
        self:NextThink(CurTime() + 0.25)
        return true
    end
end
