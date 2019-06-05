AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )


ENT.Spawnable                         =  true         
ENT.AdminSpawnable                    =  true 
ENT.PrintName                        =  "Wire Geiger Counter"
ENT.Author                           =  "snowfrog"
ENT.Contact                          =  ""
ENT.Category                         =  "EnduringStockpile"
ENT.Model                            =  "models/props_lab/powerbox02d.mdl"                
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
    self.ClickSound = 0
    self.Outputs  = Wire_CreateOutputs(self, { "RadsPerMin" }) --, "MiliRadsPerMin", "RadsPerHour" })
	self.Inputs   = Wire_CreateInputs(self, { "Sound" })
    Wire_TriggerOutput(self, "RadsPerMin", 0)
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
	 if (iname == "Sound") then
         if (value >= 1) then
		     self.ClickSound = 1
		 else
		    self.ClickSound = 0
		 end
	 end	 
end 

function ENT:Think(ply) 
    self.spawned = true
    if (SERVER) then
        if !self:IsValid() then return end
        local milirads = math.Round(self.RadCount*1000)
        Wire_TriggerOutput(self, "RadsPerMin", self.RadCount)
        --Wire_TriggerOutput(self, "MiliRadsPerMin", milirads)
         
        if (self.ClickSound == 1) then
	        if (self.RadCount) >= 1000 then
		        self:EmitSound("geiger/rad_extreme.wav", 100, 100)
	        elseif (self.RadCount) >= 400 then
		        self:EmitSound("geiger/rad_veryhigh.wav", 100, 100)
	        elseif (self.RadCount) >= 200 then
		        self:EmitSound("geiger/rad_high.wav", 100, 100)
	        elseif (self.RadCount) >= 100 then
		        self:EmitSound("geiger/rad_med.wav", 100, 100)
	        elseif (self.RadCount) > 0 then
		        self:EmitSound("geiger/rad_low.wav", 100, 100)
	        end
	    end
        self.RadCount = 0
        self:NextThink(CurTime() + 1)
        return true
    end
end
