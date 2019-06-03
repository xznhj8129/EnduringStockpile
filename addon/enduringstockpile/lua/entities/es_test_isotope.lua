AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Test isotope"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"
ENT.Model                            =  "models/props_lab/jar01b.mdl"                     

ENT.RadRadius                        =  25000
ENT.Mass                             =  20
ENT.RadPower                         =  500
ENT.HalfLife                         =  30
ENT.Time                             =  0


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

function ENT:OnTakeDamage( dmginfo ) 
    self.Entity:TakePhysicsDamage( dmginfo ) 
end 


function ENT:Think()
    
    if (SERVER) then
        if !self:IsValid() then return end
        local pos = self:GetPos()
        
        local radpower_left = halflife(self.RadPower, self.Time, self.HalfLife)
        --PrintMessage( HUD_PRINTCONSOLE, "RADPOWER "..radpower_left)
        
        for _, v in pairs( ents.FindByModel("models/props_lab/powerbox02d.mdl")) do
            if v.GeigerCounter == 1 then
                local dist = (self:GetPos() - v:GetPos()):Length()
                if dist<self.RadRadius then
                    local raddose = radpower_left * inversesquare(dist)
                    v.RadCount = v.RadCount + raddose
                end
            end
        end
        
        for _, ply in pairs( player.GetAll() ) do
            local dist = (self:GetPos() - ply:GetPos()):Length()
            if dist<self.RadRadius and ply:IsPlayer() and ply:Alive() and ply:IsLineOfSightClear(self) then
                local raddose = radpower_left * inversesquare(dist)
                local exposure = raddose/60
                addGeigerRads(ply,raddose)
                addRads(ply,exposure)
            end
        end
        
        for _, v in pairs( ents.FindByClass("npc_*") ) do
            local dist = (self:GetPos() - v:GetPos()):Length()
            if dist<self.RadRadius and v:IsNPC() and v:Health()>0 and v:IsLineOfSightClear(self) then
                local raddose = radpower_left * inversesquare(dist)
                local exposure = raddose/60
                addRads(v,exposure)
            end
        end
        
        self:NextThink(CurTime() + 0.25)
        self.Time = self.Time+0.25
        return true
    end
end
