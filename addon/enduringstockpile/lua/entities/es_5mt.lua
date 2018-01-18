AddCSLuaFile()

DEFINE_BASECLASS( "es_base_nuclearweapon" )

ENT.Spawnable                        =  true
ENT.AdminSpawnable                   =  true
ENT.AdminOnly                        =  true

ENT.PrintName                        =  "REN-5000 warhead (5 megatons)"
ENT.Author                           =  "snowfrog"
ENT.Contact                          =  ""
ENT.Category                         =  "Enduring Stockpile"

ENT.Model                            =  "models/props_c17/canister_propane01a.mdl"
ENT.Material                         =  "phoenix_storms/torpedo"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"            
ENT.ActivationSound                  =  "buttons/button14.wav"     

ENT.DialAYield                       =  false
ENT.Yield                            =  5000   -- yield in kilotons 
ENT.Effect                           =  "hnuke1"
ENT.EffectAir                        =  "hnuke1_airburst"
ENT.EffectWater                      =  "hbomb_underwater" 
ENT.ExplosionSound                   =  "gbombs_5/explosions/nuclear/tsar_detonate.mp3"

ENT.ShouldUnweld                     =  true
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

-- Nuclear effects variables
-- Calculated from NUKEMAP.ORG, converted to gmod units and scaled down
-- All effects calculated from ground bursts
-- Scale factor: 1:12
ENT.TotalRadius                      =  10500 -- 200psi range or fireball size (whichever bigger), everything vaporized (1400 minimum for the removal to work)
ENT.DestroyRadius                    =  34300 -- 5psi range, all constraints break
ENT.BlastRadius                      =  73100 -- 1.5psi range, unfreeze props
ENT.ExplosionRadius                  =  80000 -- Max range at which things move
ENT.FalloutRadius                    =  13400 -- 500rem range, fallout range
ENT.VaporizeRadius                   =  36100 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
ENT.CremateRadius                    =  58200 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
ENT.IgniteRadius                     =  93200 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
ENT.Burn2Radius                      =  122500 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
ENT.Burn1Radius                      =  164100 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.FalloutBurst                     =  50
ENT.MaxIgnitionTime                  =  5
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  1000
ENT.ImpactSpeed                      =  1300
ENT.Mass                             =  2500
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 25
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 2555
ENT.HBOWNER                          = nil             -- don't you fucking touch this.
ENT.Decal                            = "nuke_tsar"

function ENT:Initialize()
 if (SERVER) then
     self:SetModel(self.Model)
     self:SetMaterial(self.Material)
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
		 phys:Wake()
     end 
	 if(self.Dumb) then
	     self.Armed    = true
	 else
	     self.Armed    = false
	 end
	 self.Exploded = false
	 self.Used     = false
	 self.Arming = false
	 self.Exploding = false
	  if !(WireAddon == nil) then self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate" }) end
	end
end

function ENT:Explode()
     if !self.Exploded then return end
	 if self.Exploding then return end
     local pos = self:LocalToWorld(self:OBBCenter())
	 
	 for k, v in pairs(ents.FindInSphere(pos,self.Burn1Radius)) do
        local entdist = pos:Distance(v:GetPos())
        if (v:IsValid() and !v:IsPlayer()) and !v:IsNPC() then
            if v:IsValid() and v:GetPhysicsObject():IsValid() and entdist < self.IgniteRadius then
                v:Ignite(self.MaxIgnitionTime,0)
                if entdist <= self.CremateRadius then
                    v:SetMaterial("models/props_debris/plasterwall009d")
                end
            end
        end
        if (v:IsValid() or v:IsPlayer()) then
            if (v:IsPlayer() or v:IsNPC()) and v:IsLineOfSightClear(self) then
            
                if entdist < self.VaporizeRadius then
                    ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0)
                    if v:IsPlayer() then
                        v:SetModel("models/player/skeleton.mdl")
                        v:Kill()
                    else
                        v:Remove()
                    end
                    
                elseif entdist < self.CremateRadius then
                    ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0)
                    v:SetModel("models/player/skeleton.mdl")
                    if v:IsPlayer() then
                        v:Kill()
                    else
                        v:TakeDamage(1000,self)
                    end
                    v:Ignite(4,0)
                    
                elseif entdist < self.IgniteRadius then
                    ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0)
                    v:SetModel("models/Humans/Charple01.mdl")
                    if v:IsPlayer() then
                        v:Kill()
                    else
                        v:TakeDamage(1000,self)
                    end
                    v:Ignite(4,0)
                    
                elseif entdist < self.Burn2Radius then
                    v:SetModel("models/Humans/corpse1.mdl")
                    v:TakeDamage(50,self)
                    v:Ignite(4,0)
                    
                elseif entdist < self.Burn1Radius then
                    v:TakeDamage(10,self)
                    v:Ignite(1,0)

                end
            end
        end
	 end
	 
  	 timer.Simple(0.1, function()
	     if !self:IsValid() then return end 
		 local ent = ents.Create("es_shockwave_ent")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
		 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
		 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
		 ent:SetVar("HBOWNER", self.HBOWNER)
		 ent:SetVar("MAX_RANGE",self.BlastRadius)
         ent:SetVar("MAX_BREAK",self.DestroyRadius)
         ent:SetVar("MAX_DESTROY",self.TotalRadius)
		 ent:SetVar("SHOCKWAVE_INCREMENT",140)
		 ent:SetVar("DELAY",0.01)
		 ent.trace=self.TraceLength
		 ent.decal=self.Decal
		 
		 local ent = ents.Create("hb_shockwave_ent_nounfreeze")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("DEFAULT_PHYSFORCE",10)
		 ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR",1)
		 ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND",1)
		 ent:SetVar("HBOWNER", self.HBOWNER)
		 ent:SetVar("MAX_RANGE",self.ExplosionRadius)
		 ent:SetVar("SHOCKWAVE_INCREMENT",140)
		 ent:SetVar("DELAY",0.01)
		 ent.trace=self.TraceLength
		 ent.decal=self.Decal
		 
	 	if GetConVar("hb_nuclear_fallout"):GetInt()== 1 then
			local ent = ents.Create("hb_base_radiation_draw_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = self.FalloutBurst
			ent.RadRadius = self.FalloutRadius
			
			local ent = ents.Create("hb_base_radiation_ent")
			ent:SetPos( pos ) 
			ent:Spawn()
			ent:Activate()
			ent.Burst = self.FalloutBurst
			ent.RadRadius = self.FalloutRadius
			end
			
		 local ent = ents.Create("hb_shockwave_sound_lowsh")
		 ent:SetPos( pos ) 
		 ent:Spawn()
		 ent:Activate()
		 ent:SetVar("HBOWNER", self.HBOWNER)
		 ent:SetVar("MAX_RANGE",60000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",140)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)
		 self:SetModel("models/gibs/scanner_gib02.mdl")
	 
         local ent = ents.Create("hb_shockwave_sound_lowsh")
         ent:SetPos( pos ) 
         ent:Spawn()
         ent:Activate()
         ent:SetVar("HBOWNER", self.HBOWNER)
         ent:SetVar("MAX_RANGE",60000)
         ent:SetVar("SHOCKWAVE_INCREMENT",160)
         ent:SetVar("DELAY",0.01)
         ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/nukeaudio3.mp3")
         self:SetModel("models/gibs/scanner_gib02.mdl") 
		 
		 self.Exploding = true
		 self:StopParticles()
     end)
	 if(self:WaterLevel() >= 1) then
		 local trdata   = {}
		 local trlength = Vector(0,0,9000)

		 trdata.start   = pos
		 trdata.endpos  = trdata.start + trlength
		 trdata.filter  = self
		 local tr = util.TraceLine(trdata) 

		 local trdat2   = {}
		 trdat2.start   = tr.HitPos
		 trdat2.endpos  = trdata.start - trlength
		 trdat2.filter  = self
		 trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
		 
		 local tr2 = util.TraceLine(trdat2)
		 
		 if tr2.Hit then
			 ParticleEffect(self.EffectWater, tr2.HitPos, Angle(0,0,0), nil)
		
		 end
	 else
		 local tracedata    = {}
		 tracedata.start    = pos
		 tracedata.endpos   = tracedata.start - Vector(0, 0, self.TraceLength)
		 tracedata.filter   = self.Entity
			
		 local trace = util.TraceLine(tracedata)
	 
		 if trace.HitWorld then
			 ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
			 timer.Simple(2, function()
				 if !self:IsValid() then return end 
				 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				 self:Remove()
		 end)	
		 else 
			 ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
			 timer.Simple(2, function()
				 if !self:IsValid() then return end 
				 ParticleEffect("",trace.HitPos,Angle(0,0,0),nil)	
				 self:Remove()
			end)	
			 --Here we do an emp check
			if(GetConVar("hb_nuclear_emp"):GetInt() >= 1) then
				 local ent = ents.Create("hb_emp_entity")
				 ent:SetPos( self:GetPos() ) 
				 ent:Spawn()
				 ent:Activate()	
			 end
		 end
	 end
end

function ENT:SpawnFunction( ply, tr )
     if ( !tr.Hit ) then return end
	 self.HBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 24 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end