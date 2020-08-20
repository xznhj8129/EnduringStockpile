AddCSLuaFile()

DEFINE_BASECLASS( "es_base_nuclearweapon" )

ENT.Spawnable                   =  true
ENT.AdminSpawnable              =  true
ENT.AdminOnly                   =  true

ENT.PrintName	                =  "Nuclear Reactor Core"
ENT.Author		                =  "snowfrog"
ENT.Category                    =  "EnduringStockpile"

ENT.Model                       =  "models/props_wasteland/laundry_washer001a.mdl"
ENT.Effect                      =  "jdam_explosion_ground"               
ENT.EffectAir                   =  "jdam_explosion_air"                
ENT.EffectWater                 =  "water_medium"
ENT.ExplosionSound              =  "gbombs_5/explosions/heavy_bomb/ex2.mp3"

ENT.Mass                        = 25000
ENT.RadPower                    = 25000
ENT.SetPower                    = 0
ENT.Explodes                    = 0
ENT.FalloutLen                  = 2
ENT.FalloutEnergy               = 500
ENT.FalloutRadius               = 40000
ENT.CraterRadius                = 1000
ENT.Wrecked                     = false
ENT.HalfLife                    = 1800
ENT.Time                        = 0

ENT.ShouldUnweld                 =  true
ENT.ShouldIgnite                 =  false
ENT.ShouldExplodeOnImpact          =  true
ENT.Flamable                    =  false
ENT.Timed                       =  false
ENT.ExplosionDamage               =  99
ENT.PhysForce                    =  5000
ENT.ExplosionRadius               =  1000
ENT.SpecialRadius                =  575
ENT.MaxIgnitionTime               =  10
ENT.Life                        =  20                            
ENT.MaxDelay                    =  2                           
ENT.TraceLength                  =  100
ENT.ImpactSpeed                  =  350
ENT.ArmDelay                    =  2   
ENT.Timer                       =  0
ENT.Decal                       = "scorch_big"
ENT.GBOWNER                     =  nil           -- don't you fucking touch this.

function ENT:Initialize()
    if (SERVER) then
        self.DebrisN = GetConVar("es_reactor_debris"):GetInt()
        if self.DebrisN == nil then
            CreateConVar("es_reactor_debris", "20", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
            self.DebrisN = 20
        end
        self.Explodes = GetConVar("es_reactor_explode"):GetInt()
        if self.Explodes == nil then
            CreateConVar("es_reactor_explode", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
            self.Explodes = 1
        end
        self.FalloutLen = GetConVar("es_reactor_falloutlen"):GetInt()
        if self.FalloutLen == nil then
            CreateConVar("es_reactor_falloutlen", "3", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
            self.FalloutLen = 3
        end
        self.HalfLife = GetConVar("es_isotopes_halflife"):GetInt()
        if self.HalfLife == nil then
            CreateConVar("es_isotopes_halflife", "3600", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
            self.HalfLife = 3600
        end
        
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
        self.Used    = false
        self.Arming = false
        self.Exploding = false
        if !(WireAddon == nil) then 
            self.Inputs   = Wire_CreateInputs(self, { "Power" }) 
            self.Outputs  = Wire_CreateOutputs(self, { "RadPower" })
        end
    end
end

function ENT:ExploSound(pos)
    if not self.Exploded then return end
    sound.Play(self.ExplosionSound, pos, 160, 100,1)
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
    if self.Wrecked then return end
    if (iname == "Power") then
        self.SetPower = value
        self.RadPower = ((value/100)*975000) + 25000
        Wire_TriggerOutput(self, "RadPower", self.RadPower)
    end    
end 

function ENT:Explode()
    if !self.Exploded then return end
    if self.Exploding then return end
    
    if(GetConVar("hb_decals"):GetInt() >= 1) then
        local pos = self:GetPos()
        local tracedata    = {}
        tracedata.start    = pos
        tracedata.endpos   = tracedata.start - Vector(0, 0, self.trace)
        tracedata.filter   = self.Entity
        local trace = util.TraceLine(tracedata)
        if self.Decal==nil then 
            self.Decal="scorch_medium"
        end

        util.Decal( self.Decal, tracedata.start, tracedata.endpos )
    end
    
    local pos = self:LocalToWorld(self:OBBCenter())

    constraint.RemoveAll(self)
    local physo = self:GetPhysicsObject()
    physo:Wake()	
    self.Exploding = true
    if !self:IsValid() then return end 
    self:StopParticles()
    local pos = self:LocalToWorld(self:OBBCenter())

    local ent = ents.Create("hb_shockwave_ent")
    ent:SetPos( pos ) 
    ent:Spawn()
    ent:Activate()
    ent:SetVar("DEFAULT_PHYSFORCE", self.DEFAULT_PHYSFORCE)
    ent:SetVar("DEFAULT_PHYSFORCE_PLYAIR", self.DEFAULT_PHYSFORCE_PLYAIR)
    ent:SetVar("DEFAULT_PHYSFORCE_PLYGROUND", self.DEFAULT_PHYSFORCE_PLYGROUND)
    ent:SetVar("HBOWNER", self.HBOWNER)
    ent:SetVar("MAX_RANGE",self.ExplosionRadius)
    ent:SetVar("SHOCKWAVE_INCREMENT",100)
    ent:SetVar("DELAY",0.01)

    local ent = ents.Create("hb_shockwave_sound_lowsh")
    ent:SetPos( pos ) 
    ent:Spawn()
    ent:Activate()
    ent:SetVar("HBOWNER", self.HBOWNER)
    ent:SetVar("MAX_RANGE",50000)
    ent:SetVar("SHOCKWAVE_INCREMENT",100)
    ent:SetVar("DELAY",0.01)
    ent:SetVar("SOUND", self.ExplosionSound)
    ent:SetVar("Shocktime", self.Shocktime)
    
    if GetConVar("hb_nuclear_fallout"):GetInt()== 1 then
        local ent = ents.Create("es_effect_fallout_ent")
        ent:SetPos( pos ) 
        ent:Spawn()
        ent:Activate()
        ent.RadRadius = self.FalloutRadius
        ent.RadiationEnergy = self.FalloutEnergy
        ent.FalloutLen = self.FalloutLen
        
        local ent = ents.Create("es_effect_crater_ent")
        ent:SetPos( pos ) 
        ent:Spawn()
        ent:Activate()
        ent.RadRadius = self.CraterRadius
    end

    for i=0, (self.DebrisN) do
       local ent1 = ents.Create("es_rad_debris") 
       local phys = ent1:GetPhysicsObject()
       ent1:SetPos( self:GetPos() + VectorRand(-50,50) ) 
       ent1:Spawn()
       ent1:Activate()
       ent1:SetVar("GBOWNER", self.GBOWNER)
       local bphys = ent1:GetPhysicsObject()
       local phys = self:GetPhysicsObject()
       if bphys:IsValid() and phys:IsValid() then
            bphys:ApplyForceCenter(Vector(0,0,100000))
            bphys:ApplyForceCenter(VectorRand(-25000,25000))
       end
       ent1:Ignite(30,0)
    end

    for k, v in pairs(ents.FindInSphere(pos,500)) do
        if v:IsValid() && (v != self) then
            local phys = v:GetPhysicsObject()
            if (phys:IsValid()) then
                v:Ignite(5,0)
            end
        end
    end 

	local pos = self:GetPos()
    ParticleEffect(self.Effect,pos,Angle(0,0,0),nil)	
    self.Wrecked = true
    self:SetMaterial("models/props_wasteland/rockcliff04a")
    self:SetColor( Color( 70, 70, 70, 255 ) )
    self.RadPower = 1000000
    --timer.Simple(0.1, function()
    --    if !self:IsValid() then return end 
    --    self:Remove()
    --end)
end

function ENT:Think()
    if (SERVER) then
        if !self:IsValid() then return end
        
        if self.Wrecked then
            local radpower_left = NuclearHalfLife(self.RadPower, self.Time, self.HalfLife)
            RadiationSource(self, radpower_left)
            self.Time = self.Time + 0.25
        else
            RadiationSource(self, self.RadPower)
        end

        if self.Explodes == 1 and !self.Wrecked then
            if self.SetPower > 1000 then
                if !self:IsValid() then return end 
                self.Exploded = true
                self:Explode()
            end
            if self.SetPower > 110 then
                local boomchance = (self.SetPower-110)/4
                if math.random(0,100) <= math.Round(boomchance) then
                    self:Ignite(30)
                    timer.Simple(5,function()
                        if !self:IsValid() then return end 
                        self.Exploded = true
                        self:Explode()
                    end)
                end
            end
        end
        
        
        self:NextThink(CurTime() + 0.25)
        
        return true
    end
end


function ENT:PhysicsCollide( data, physobj )
end

function ENT:OnTakeDamage(dmginfo)
end

function ENT:Use( activator, caller )
end

function ENT:Arm()
end
