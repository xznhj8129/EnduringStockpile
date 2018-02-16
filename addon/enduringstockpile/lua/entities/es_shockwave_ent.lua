AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable                        =  false
ENT.AdminSpawnable                   =  false     

ENT.PrintName                        =  "Blast Shockwave"        
ENT.Author                           =  "snowfrog"      
ENT.Contact                          =  ""      

ENT.HBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.MAX_BREAK                        = 0
ENT.MAX_DESTROY                      = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""

if SERVER then
    function ENT:Initialize()  
        self.FILTER = {}
        self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
        self:SetSolid( SOLID_NONE )
        self:SetMoveType( MOVETYPE_NONE )
        self:SetUseType( ONOFF_USE ) 
        self.Bursts = 0
        self.CURRENTRANGE = 0
        self.HBOWNER = self:GetVar("HBOWNER")
        self.SOUND = self:GetVar("SOUND")
        self.DEFAULT_PHYSFORCE  = self:GetVar("DEFAULT_PHYSFORCE")
        self.DEFAULT_PHYSFORCE_PLYAIR  = self:GetVar("DEFAULT_PHYSFORCE_PLYAIR")
        self.DEFAULT_PHYSFORCE_PLYGROUND = self:GetVar("DEFAULT_PHYSFORCE_PLYGROUND")
        self.SHOCKWAVEDAMAGE = self:GetVar("SHOCKWAVE_DAMAGE")
        self.allowtrace=true
    end
end
function ENT:Trace()
    if SERVER then
        if !self:IsValid() then return end
        if(GetConVar("hb_decals"):GetInt() >= 1) then
            local pos = self:GetPos()
            local tracedata    = {}
            tracedata.start    = pos
            tracedata.endpos   = tracedata.start - Vector(0, 0, self.trace)
            tracedata.filter   = self.Entity
            local trace = util.TraceLine(tracedata)
            if self.decal==nil then 
                self.decal="scorch_medium"
            end

            util.Decal( self.decal, tracedata.start, tracedata.endpos )
        end
    end
end
function ENT:Think()        
    if (SERVER) then
    if !self:IsValid() then return end
    local pos = self:GetPos()
    self.CURRENTRANGE = self.CURRENTRANGE+(self.SHOCKWAVE_INCREMENT*10)
    if self.allowtrace then
        self:Trace()
        self.allowtrace=false
    end
    for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
        if (v:IsValid() or v:IsPlayer()) then
            local i = 0
            while i < v:GetPhysicsObjectCount() do
                local dmg = DamageInfo()
                dmg:SetDamageType(DMG_BLAST)
                if self.HBOWNER == nil or !self.HBOWNER:IsValid() then
                    self.HBOWNER = self
                end
                dmg:SetAttacker(self.HBOWNER)
                phys = v:GetPhysicsObjectNum(i)
                
                if phys:IsValid() and !v:IsPlayer() and !v:IsNPC() then
                    if (self.CURRENTRANGE <= self.MAX_DESTROY) then
                        v:Remove()
                    else
                        local mass = phys:GetMass()
                        local F_ang = self.DEFAULT_PHYSFORCE
                        local dist = (pos - v:GetPos()):Length()
                        local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
                        local F_dir = (v:GetPos() - pos):GetNormal() * (self.DEFAULT_PHYSFORCE or 690)
                        phys:Wake()
                        phys:EnableMotion(true)
                        phys:AddAngleVelocity(Vector(F_ang, F_ang, F_ang) * relation)
                        phys:AddVelocity(F_dir) 
                        if (self.CURRENTRANGE <= self.MAX_BREAK) and (GetConVar("hb_shockwave_unfreeze"):GetInt() >= 1) then
                            if !v.isWacAircraft then
                               constraint.RemoveAll(v)
                            end
                        end
                        
                        if (v:GetClass()=="func_breakable" or class=="func_breakable_surf" or class=="func_physbox") then
                           v:Fire("Break", 0)
                        end
                    end
                end
                
                if v:IsLineOfSightClear(self) or self.CURRENTRANGE <= self.MAX_BREAK then
                    local dist = (pos - v:GetPos()):Length()
                    local blastdmg = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1) * 50
                    dmg:SetDamage(blastdmg)
                    if (v:IsPlayer()) then
                        
                        v:TakeDamageInfo(dmg)
                        local mass = phys:GetMass()
                        local F_ang = self.DEFAULT_PHYSFORCE_PLYAIR
                        local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
                        local F_dir = (v:GetPos() - pos):GetNormal() * (self.DEFAULT_PHYSFORCE_PLYAIR or 690)
                        v:SetVelocity( F_dir )        
                    end

                    if (v:IsPlayer()) and v:IsOnGround() then
                        v:TakeDamageInfo(dmg)
                        local mass = phys:GetMass()
                        local F_ang = self.DEFAULT_PHYSFORCE_PLYGROUND
                        local relation = math.Clamp((self.CURRENTRANGE - dist) / self.CURRENTRANGE, 0, 1)
                        local F_dir = (v:GetPos() - pos):GetNormal() * (self.DEFAULT_PHYSFORCE_PLYGROUND or 690)    
                        v:SetVelocity( F_dir )        
                    end

                    if (v:IsNPC()) then --and (v:IsLineOfSightClear(self) or (self.CURRENTRANGE <= self.MAX_BREAK)) then
                        v:TakeDamageInfo(dmg)
                    end
                end
                
            i = i + 1
            end
        end
    end
    self.Bursts = self.Bursts + 1
    if (self.CURRENTRANGE >= self.MAX_RANGE) then
        self:Remove()
    end
    self:NextThink(CurTime() + (self.DELAY*10))
    return true
    end
end

function ENT:Draw()
     return false
end