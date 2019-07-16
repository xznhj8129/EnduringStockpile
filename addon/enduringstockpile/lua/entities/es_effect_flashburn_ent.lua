AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable                        =  false
ENT.AdminSpawnable                   =  false     

ENT.PrintName                        =  "Thermal radiation"
ENT.Author                           =  ""
ENT.Contact                          =  ""

ENT.VaporizeRadius                   =  0 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
ENT.CremateRadius                    =  0 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
ENT.IgniteRadius                     =  0 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
ENT.Burn2Radius                      =  0 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
ENT.Burn1Radius                      =  0 -- 1st degree burn range (3 cal/cm^2), player catches fire

          
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
         self:SetSolid( SOLID_NONE )
         self:SetMoveType( MOVETYPE_NONE )
         self:SetUseType( ONOFF_USE ) 
         self.HBOWNER = self:GetVar("HBOWNER")
     end
end

function ENT:Think()
    
    if (SERVER) then
    if !self:IsValid() then return end
    local pos = self:GetPos()
    local npc_whitelist = {"npc_citizen",
        "npc_monk",
        "npc_zombie",
        "npc_combine_s",
        "npc_metropolice",
        "npc_alyx",
        "npc_barney",
        "npc_breen",
        "npc_eli",
        "npc_kleiner",
        "npc_mossman",
        "npc_gman"
        }
    
    for k, v in pairs(ents.FindInSphere(pos,self.Burn1Radius)) do
        local entdist = pos:Distance(v:GetPos())
        if (v:IsValid() and !v:IsPlayer()) and !v:IsNPC() then
            if v:IsValid() and v:GetPhysicsObject():IsValid() and entdist < self.IgniteRadius and TraceLineOfSight(self,v) then
                if entdist <= self.CremateRadius then
                    v:Ignite(10,0)
                    v:SetMaterial("models/props_debris/plasterwall009d")
                    v:SetColor( Color( 100, 100, 100, 255 ) )
                else
                    v:Ignite(5,0)
                end
            end
        end
        if v:IsValid() and  ((v:IsPlayer() and !v:HasGodMode()) or v:IsNPC()) and v:Health()>0 then
            if entdist < self.VaporizeRadius and (TraceLineOfSight(self,v) or entdist < self.VaporizeRadius/2)then
                ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,v,0)
                if table.HasValue(npc_whitelist,v:GetClass()) or v:IsPlayer() then
                    v:SetModel("models/player/skeleton.mdl")
                    if table.HasValue(npc_whitelist,v:GetClass()) then
                        v:SetMaterial("models/props_c17/metalladder001")
                        v:SetColor( Color( 77, 77, 77, 255 ) )
                    end
                end
                local dmg = DamageInfo()
                dmg:SetDamage(1000000)
                dmg:SetDamageType(DMG_DISSOLVE)
                dmg:SetAttacker(self)
                v:TakeDamageInfo(dmg)
                v:Remove()
                
            elseif entdist < self.CremateRadius and TraceLineOfSight(self,v) then
                ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,v,0)
                if table.HasValue(npc_whitelist,v:GetClass()) or v:IsPlayer() then
                    v:SetModel("models/player/skeleton.mdl")
                    if table.HasValue(npc_whitelist,v:GetClass()) then
                        v:SetMaterial("models/props_c17/metalladder001")
                        v:SetColor( Color( 77, 77, 77, 255 ) )
                    end
                end
                local dmg = DamageInfo()
                dmg:SetDamage(1000000)
                dmg:SetDamageType(DMG_BURN)
                dmg:SetAttacker(self)
                v:TakeDamageInfo(dmg)
                v:Ignite(10,0)
                
            elseif entdist < self.IgniteRadius and TraceLineOfSight(self,v) then
                ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,v,0)
                local modellist = {"models/humans/charple01.mdl",
                    "models/humans/charple02.mdl",
                    "models/humans/charple03.mdl",
                    "models/humans/charple04.mdl",}

                if table.HasValue(npc_whitelist,v:GetClass()) or v:IsPlayer() then
                    v:SetModel( modellist[math.random(4)] )
                end
                local dmg = DamageInfo()
                dmg:SetDamage(1000000)
                dmg:SetDamageType(DMG_BURN)
                dmg:SetAttacker(self)
                v:TakeDamageInfo(dmg)
                v:Ignite(10,0)
                
            elseif entdist < self.Burn2Radius and TraceLineOfSight(self,v) then
                ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,v,0)
                if v:IsPlayer() then
                    v:SetModel("models/player/corpse1.mdl")
                elseif table.HasValue(npc_whitelist,v:GetClass()) then
                    v:SetModel("models/humans/corpse1.mdl")
                end
                local dmg = DamageInfo()
                dmg:SetDamage(40)
                dmg:SetDamageType(DMG_BURN)
                dmg:SetAttacker(self)
                v:TakeDamageInfo(dmg)
                v:Ignite(4,0)
                
            elseif entdist < self.Burn1Radius and TraceLineOfSight(self,v) then
                local dmg = DamageInfo()
                dmg:SetDamage(10)
                dmg:SetDamageType(DMG_BURN)
                dmg:SetAttacker(self)
                v:TakeDamageInfo(dmg)
                v:Ignite(1,0)

            end
        end
    end
    
    self:Remove()
    return true
    end
end

function ENT:Draw()
     return true
end
