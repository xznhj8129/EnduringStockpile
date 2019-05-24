AddCSLuaFile()

DEFINE_BASECLASS( "es_base_nuclearweapon" )

ENT.Spawnable                        =  true
ENT.AdminSpawnable                   =  true
ENT.AdminOnly                        =  false

ENT.PrintName                        =  "B61 Mod 12 bomb (tactical, dial-a-yield)"
ENT.Author                           =  "snowfrog"
ENT.Contact                          =  ""
ENT.Category                         =  "EnduringStockpile"

ENT.Model                            =  "models/bombs/gbu/gbu10.mdl"
ENT.Material                         =  "phoenix_storms/fender_chrome"
ENT.ArmSound                         =  "npc/roller/mine/rmine_blip3.wav"
ENT.ActivationSound                  =  "buttons/button14.wav"

ENT.DialAYield                       =  true -- 1, 5, 10, 20, 50 kilotons
ENT.EnhancedRadiation                =  false -- is the bomb an Enhanced Radiation weapon aka "neutron bomb"
ENT.Yield                            =  50   -- yield in kilotons

ENT.ShouldUnweld                     =  true
ENT.ShouldExplodeOnImpact            =  true
ENT.Flamable                         =  false
ENT.UseRandomSounds                  =  false
ENT.Timed                            =  false

ENT.TraceHitPos                      =  Vector(0,0,0)
ENT.BurstType                        =  0  -- 0: ground, 1: air, 2: underwater
ENT.ExplosionDamage                  =  500
ENT.PhysForce                        =  2500
ENT.MaxIgnitionTime                  =  4
ENT.Life                             =  25                                  
ENT.MaxDelay                         =  2
ENT.ImpactSpeed                      =  700
ENT.Mass                             =  400
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
            self.Yield = 5
            
        elseif rounded == 3 then
            self.Yield = 10
            
        elseif rounded == 4 then
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
    
    if self.Yield == 5 then
        self.FireballSize = 600
        self.Decal = "nuke_small"
        
    elseif self.Yield == 10 then
        self.FireballSize = 700
        self.Decal = "nuke_medium"
        
    elseif self.Yield == 20 then
        self.FireballSize = 900
        self.Decal = "nuke_medium"
        
    elseif self.Yield == 50 then
        self.FireballSize = 1300
        self.Decal = "nuke_medium"
        
    else
        self.FireballSize = 400
        self.Decal = "nuke_small"
    end
    
    if(self:WaterLevel() >= 1) then  -- explosion height type determination
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
            self.BurstType = 2
            self.TraceHitPos = tr2.HitPos
        
        end
    else
        local tracedata    = {}
        tracedata.start    = pos
        tracedata.endpos   = tracedata.start - Vector(0, 0, self.FireballSize)
        tracedata.filter   = self.Entity
        
        local trace = util.TraceLine(tracedata)
        self.TraceHitPos = trace.HitPos
        
        if trace.HitWorld then
            self.BurstType = 0
            --PrintMessage( HUD_PRINTCONSOLE, "Surface burst")
        else 
            self.BurstType = 1   
            --PrintMessage( HUD_PRINTCONSOLE, "Airburst")
        end
        local hitdist = pos:Distance(trace.HitPos)
        --PrintMessage( HUD_PRINTCONSOLE, "Tracedist: "..hitdist)
    end
     
    if self.Yield == 10 then                                   
        self.Effect                           =  "h_nuke"                  
        self.EffectAir                        =  "h_nuke_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/nukeaudio1.mp3"
        self.Rad5000rem                       =  3700 -- 5000rem initial radiation range
        self.Rad1000rem                       =  4900 -- 1000rem initial radiation range
        self.Rad500rem                        =  5500 -- 500rem range
        self.RadPower                         =  3.11710999999e+25 -- flux of prompt radiation pulse
        if self.BurstType == 1 then -- airburst
            self.TotalRadius                      =  800 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  6600 -- 5psi range, all constraints break
            self.BlastRadius                      =  15300 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  2200 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  3700 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  7400 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  9700 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  13400 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        else -- ground/water burst
            self.TotalRadius                      =  800 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  4400 -- 5psi range, all constraints break
            self.BlastRadius                      =  9300 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  1900 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  3200 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  6200 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  8100 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  11300 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        end
        self.FalloutRadius                        =  self.IgniteRadius -- fallout range, no wind, use Ignite radius
        self.ExplosionRadius                      =  self.BlastRadius + (self.BlastRadius*0.2)
        
    elseif self.Yield == 20 then
        self.Effect                           =  "hbomb"                  
        self.EffectAir                        =  "hbomb_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/nukeaudio2.mp3"
        self.Rad5000rem                       =  4300 -- 5000rem initial radiation range
        self.Rad1000rem                       =  5600 -- 1000rem initial radiation range
        self.Rad500rem                        =  6200 -- 500rem range
        self.RadPower                         =  6.41111111111e+25 -- flux of prompt radiation pulse
        if self.BurstType == 1 then -- airburst
            self.TotalRadius                      =  1200 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  8300 -- 5psi range, all constraints break
            self.BlastRadius                      =  19300 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  3200 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  5200 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  10000 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  13100 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  18200 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        else -- ground/water burst
            self.TotalRadius                      =  1400 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  5500 -- 5psi range, all constraints break
            self.BlastRadius                      =  11600 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  2600 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  4400 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  8400 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  11100 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  15400 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        end
        self.FalloutRadius                        =  self.IgniteRadius -- fallout range, no wind, use Ignite radius
        self.ExplosionRadius                      =  self.BlastRadius + (self.BlastRadius*0.2)
        
    elseif self.Yield == 50 then
        self.Effect                           =  "h_nuke5"                  
        self.EffectAir                        =  "h_nuke5_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/nukeaudio2.mp3"
        self.Rad5000rem                       =  5100 -- 5000rem initial radiation range
        self.Rad1000rem                       =  6600 -- 1000rem initial radiation range
        self.Rad500rem                        =  7200 -- 500rem range
        self.RadPower                         =  1.50111111111e+26 -- flux of prompt radiation pulse
        if self.BurstType == 1 then -- airburst
            self.TotalRadius                      =  1300 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  11200 -- 5psi range, all constraints break
            self.BlastRadius                      =  26100 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  4900 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  8100 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  14900 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  19600 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  27200 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        else -- ground/water burst
            self.TotalRadius                      =  1700 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  7400 -- 5psi range, all constraints break
            self.BlastRadius                      =  15800 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  4100 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  6800 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  12600 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  16600 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  23100 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        end
        self.FalloutRadius                        =  self.IgniteRadius -- fallout range, no wind, use Ignite radius
        self.ExplosionRadius                      =  self.BlastRadius + (self.BlastRadius*0.2)
        
    elseif self.Yield == 5 then
        self.Effect                           =  "hbomb_small"                  
        self.EffectAir                        =  "hbomb_small_airburst"                   
        self.EffectWater                      =  "hbomb_underwater"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/NukeAudioBass.mp3"
        self.Rad5000rem                       =  3200 -- 5000rem initial radiation range
        self.Rad1000rem                       =  4300 -- 1000rem initial radiation range
        self.Rad500rem                        =  4900 -- 500rem range
        self.RadPower                         =  1.60111111111e+25 -- flux of prompt radiation pulse
        if self.BurstType == 1 then -- airburst
            self.TotalRadius                      =  600 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  5300 -- 5psi range, all constraints break
            self.BlastRadius                      =  12200 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  1600 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  2700 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  5400 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  7100 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  9900 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        else -- ground/water burst
            self.TotalRadius                      =  700 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  3500 -- 5psi range, all constraints break
            self.BlastRadius                      =  7400 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  1400 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  2200 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  4600 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  6000 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  8300 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        end
        self.FalloutRadius                        =  self.IgniteRadius -- fallout range, no wind, use Ignite radius
        self.ExplosionRadius                      =  self.BlastRadius + (self.BlastRadius*0.2)
        
    else
        self.Yield = 1
        self.Effect                           =  "hbomb_small_a"                  
        self.EffectAir                        =  "hbomb_small_airburst_a"                   
        self.EffectWater                      =  "h_water_huge"
        self.ExplosionSound                   =  "gbombs_5/explosions/nuclear/NukeAudioBass.mp3"
        self.Rad5000rem                       =  2300 -- 5000rem initial radiation range
        self.Rad1000rem                       =  3200 -- 1000rem initial radiation range
        self.Rad500rem                        =  3700 -- 500rem range
        self.RadPower                         =  3.31111111111e+24 -- flux of prompt radiation pulse
        if self.BurstType == 1 then -- airburst
            self.TotalRadius                      =  400 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  3100 -- 5psi range, all constraints break
            self.BlastRadius                      =  7100 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  700 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  1200 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  2700 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  3500 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  4900 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        else -- ground/water burst
            self.TotalRadius                      =  400 -- delete (fireball or 200psi, whichever bigger) range, everything vaporized (1400 minimum for the removal to work)
            self.DestroyRadius                    =  2100 -- 5psi range, all constraints break
            self.BlastRadius                      =  4300 -- 1.5psi range, unfreeze props
            self.VaporizeRadius                   =  400 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
            self.CremateRadius                    =  1100 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
            self.IgniteRadius                     =  2200 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
            self.Burn2Radius                      =  2900 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
            self.Burn1Radius                      =  4200 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec
        end
        self.FalloutRadius                        =  self.IgniteRadius -- fallout range, no wind, use Ignite radius
        self.ExplosionRadius                      =  self.BlastRadius + (self.BlastRadius*0.2)
        
    end
    
    local ent = ents.Create("es_effect_flashburn_ent")
    ent:SetPos( pos ) 
    ent:Spawn()
    ent:Activate()
    ent:SetVar("HBOWNER", self.HBOWNER)
    ent:SetVar("VaporizeRadius",self.VaporizeRadius)
    ent:SetVar("CremateRadius",self.CremateRadius)
    ent:SetVar("IgniteRadius",self.IgniteRadius)
    ent:SetVar("Burn2Radius",self.Burn2Radius)
    ent:SetVar("Burn1Radius",self.Burn1Radius)
    
    local ent = ents.Create("es_rad_prompt_radiation_ent")
    ent:SetPos( pos ) 
    ent:Spawn()
    ent:Activate()
    ent:SetVar("RadPower",self.RadPower)
    ent:SetVar("Rad5000rem",self.Rad5000rem)
    ent:SetVar("Rad1000rem",self.Rad1000rem)
    ent:SetVar("Rad500rem",self.Rad500rem)
    
    timer.Simple(0.1, function()
        if !self:IsValid() then return end 
        
        local ent = ents.Create("es_effect_shockwave_ent")
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
        ent:SetVar("SOUND", self.ExplosionSound)
        ent.trace=self.TraceLength
        ent.decal=self.Decal
        
        local ent = ents.Create("es_effect_shockwave_ent_nounfreeze")
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
        
        if GetConVar("hb_nuclear_fallout"):GetInt()== 1 and self.BurstType!=1 then
            local ent = ents.Create("es_rad_fallout_ent")
            ent:SetPos( pos ) 
            ent:Spawn()
            ent:Activate()
            ent.RadRadius = self.FalloutRadius
            
            local ent = ents.Create("es_rad_crater_ent")
            ent:SetPos( pos ) 
            ent:Spawn()
            ent:Activate()
            ent.RadRadius = self.FireballSize
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
    
    if self.BurstType == 0 then -- ground burst
        ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)    
        timer.Simple(2, function()
            if !self:IsValid() then return end 
            ParticleEffect("",self.TraceHitPos,Angle(0,0,0),nil)    
            self:Remove()
        end)
    elseif self.BurstType == 1 then -- air burst
            ParticleEffect(self.EffectAir,pos,Angle(0,0,0),nil) 
            timer.Simple(2, function()
                if !self:IsValid() then return end 
                ParticleEffect("",self.TraceHitPos,Angle(0,0,0),nil)    
                self:Remove()
            end)    
            --Here we do an emp check
            if(GetConVar("hb_nuclear_emp"):GetInt() >= 1) then
                local ent = ents.Create("hb_emp_entity")
                ent:SetPos( self:GetPos() ) 
                ent:Spawn()
                ent:Activate()
            end
    elseif self.BurstType == 2 then -- underwater burst
        ParticleEffect(self.EffectWater, self.TraceHitPos, Angle(0,0,0), nil)
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
