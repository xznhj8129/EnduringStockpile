AddCSLuaFile()

DEFINE_BASECLASS( "es_base_nuclearweapon" )

ENT.Spawnable                        =  true
ENT.AdminSpawnable                   =  true
ENT.AdminOnly                        =  false

-- 1, 10, 20, 50 kilotons
ENT.PrintName                        =  "B61 Mod 12 bomb (tactical, dial-a-yield)"
ENT.Author                           =  "snowfrog"
ENT.Contact                          =  ""
ENT.Category                         =  "Enduring Stockpile"

ENT.Model                            =  "models/bombs/gbu/gbu10.mdl"
ENT.Material                         =  "phoenix_storms/fender_chrome"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound                  =  "buttons/button14.wav"

ENT.DialAYield                       =  true
ENT.Yield                            =  50   -- yield in kilotons
ENT.Effect                           =  "hbomb_small"                  
ENT.EffectAir                        =  "hbomb_small_airburst"                   
ENT.EffectWater                      =  "h_water_huge"
ENT.ExplosionSound                   =  "gbombs_5/explosions/nuclear/NukeAudioBass.mp3"

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
ENT.TotalRadius                      =  400 -- 200psi range or fireball size (whichever bigger), everything vaporized (1400 minimum for the removal to work)
ENT.DestroyRadius                    =  2100 -- 5psi range, all constraints break
ENT.BlastRadius                      =  4300 -- 1.5psi range, unfreeze props
ENT.ExplosionRadius                  =  5000 -- Max range at which things move
ENT.FalloutRadius                    =  3700 -- 500rem range, fallout range
ENT.VaporizeRadius                   =  400 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
ENT.CremateRadius                    =  1400 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
ENT.IgniteRadius                     =  2200 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
ENT.Burn2Radius                      =  2900 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
ENT.Burn1Radius                      =  4200 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec

ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.FalloutBurst                     =  25
ENT.MaxIgnitionTime                  =  4
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2                                 
ENT.TraceLength                      =  500
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  350
ENT.ArmDelay                         =  1   
ENT.Timer                            =  0

ENT.DEFAULT_PHYSFORCE                = 255
ENT.DEFAULT_PHYSFORCE_PLYAIR         = 25
ENT.DEFAULT_PHYSFORCE_PLYGROUND      = 2555
ENT.HBOWNER                          =  nil     
ENT.Decal                            = "nuke_small"

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
	 self.Inputs   = Wire_CreateInputs(self, { "Arm", "Detonate", "YieldMode" })
	 self.Outputs  = Wire_CreateOutputs(self, { "Yield" })
     Wire_TriggerOutput(self, "Yield", self.Yield)
     
	end
end


function ENT:TriggerInput(iname, value)
    if (!self:IsValid()) then return end
    if (iname == "Detonate") then
        if (value >= 1) then
            if (!self.Exploded and self.Armed) then
                if !self:IsValid() then return end
                self.Exploded = true
                self:Explode()
            end
        end
    end
    if (iname == "Arm") then
        if (value >= 1) then
            if (!self.Exploded and !self.Armed and !self.Arming) then
                self:EmitSound(self.ActivationSound)
                self:Arm()
            end 
        end
    end		 
    if iname == "YieldMode" then -- dial-a-yield selection function
        local rounded = math.floor(value)
        
        if rounded == 1 then
            self.Yield = 1
            
        elseif rounded == 2 then
            self.Yield = 10
            
        elseif rounded == 3 then
            self.Yield = 20
            
        else
            self.Yield = 50
            
        end
        
        Wire_TriggerOutput(self, "Yield", self.Yield)
    end
end

function ENT:Explode()
     if !self.Exploded then return end
	 if self.Exploding then return end
     local pos = self:LocalToWorld(self:OBBCenter())
     
     if self.Yield == 10 then                                   
        self.Effect                           =  "h_nuke"                  
        self.EffectAir                        =  "h_nuke_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/nukeaudio1.mp3"
        self.TotalRadius                      =  1400 
        self.DestroyRadius                    =  4400 
        self.BlastRadius                      =  9300 
        self.ExplosionRadius                  =  12000 
        self.FalloutRadius                    =  5500
        self.VaporizeRadius                   =  1900
        self.CremateRadius                    =  3200 
        self.IgniteRadius                     =  6200
        self.Burn2Radius                      =  8100
        self.Burn1Radius                      =  11300
        
     elseif self.Yield == 20 then
        self.Effect                           =  "hbomb"                  
        self.EffectAir                        =  "hbomb_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/nukeaudio2.mp3"
        self.TotalRadius                      =  1400
        self.DestroyRadius                    =  5500
        self.BlastRadius                      =  11600
        self.ExplosionRadius                  =  20000
        self.FalloutRadius                    =  6200 
        self.VaporizeRadius                   =  2600 
        self.CremateRadius                    =  4400 
        self.IgniteRadius                     =  8400 
        self.Burn2Radius                      =  11100 
        self.Burn1Radius                      =  15400 
        
     elseif self.Yield == 50 then
        self.Effect                           =  "h_nuke5"                  
        self.EffectAir                        =  "h_nuke5_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/nukeaudio2.mp3"
        self.TotalRadius                      =  1700
        self.DestroyRadius                    =  7400
        self.BlastRadius                      =  15800
        self.ExplosionRadius                  =  22500
        self.FalloutRadius                    =  7200
        self.VaporizeRadius                   =  4100
        self.CremateRadius                    =  6800
        self.IgniteRadius                     =  12600
        self.Burn2Radius                      =  16600
        self.Burn1Radius                      =  23100
        
     else
        self.Yield = 1
        self.Effect                           =  "hbomb_small"                  
        self.EffectAir                        =  "hbomb_small_airburst"                   
        self.EffectWater                      =  "h_water_huge"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/NukeAudioBass.mp3"
        self.Yield                            =  1 
        self.TotalRadius                      =  400 
        self.DestroyRadius                    =  2100 
        self.BlastRadius                      =  4300 
        self.ExplosionRadius                  =  5000 
        self.FalloutRadius                    =  3700 
        self.VaporizeRadius                   =  400 
        self.CremateRadius                    =  1400 
        self.IgniteRadius                     =  2200 
        self.Burn2Radius                      =  2900 
        self.Burn1Radius                      =  4200 
        
     end
	 
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
         if self.Yield == 1 then
            ent:SetVar("SOUND", "gbombs_5/explosions/nuclear/nukeaudiobassspeed2.mp3")
         end
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
		 ent:SetVar("MAX_RANGE",50000)
		 ent:SetVar("SHOCKWAVE_INCREMENT",140)
		 ent:SetVar("DELAY",0.01)
		 ent:SetVar("SOUND", self.ExplosionSound)
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