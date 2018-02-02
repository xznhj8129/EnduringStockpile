AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Thermal radiation"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""

ENT.VaporizeRadius                   =  0 -- 5th degree burn range (100 cal/cm^2), player/npc is just gone
ENT.CremateRadius                    =  0 -- 4th degree burn range (35 cal/cm2), player becomes skeleton
ENT.IgniteRadius                     =  0 -- 3rd degree burn range (8 cal/cm^2), player becomes crispy, things ignite
ENT.Burn2Radius                      =  0 -- 2nd degree burn range (5 cal/cm^2), player becomes burn victim
ENT.Burn1Radius                      =  0 -- 1st degree burn range (3 cal/cm^2), player catches fire for 1sec

          
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
    
    for k, v in pairs(ents.FindInSphere(pos,self.Burn1Radius)) do
        local entdist = pos:Distance(v:GetPos())
        if (v:IsValid() and !v:IsPlayer()) and !v:IsNPC() then
            if v:IsValid() and v:GetPhysicsObject():IsValid() and entdist < self.IgniteRadius then
                if entdist <= self.CremateRadius then
                    v:Ignite(10,0)
                    v:SetMaterial("models/props_debris/plasterwall009d")
                else
                    v:Ignite(5,0)
                end
            end
        end
        if (v:IsValid() or v:IsPlayer()) then
            if (v:IsPlayer() or v:IsNPC()) then
            
                if entdist < self.VaporizeRadius then
                    ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0)
                    if v:IsPlayer() then
                        --v:SetMaterial("models/props_debris/plasterwall009d")
                        v:SetModel("models/player/skeleton.mdl")
                        v:Kill()
                    else
                        v:TakeDamage(1000000,self)
                        v:Remove()
                    end
                    
                elseif entdist < self.CremateRadius and v:IsLineOfSightClear(self) then
                    ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0)
                    v:SetModel("models/player/skeleton.mdl")
                    --v:SetMaterial("models/props_debris/plasterwall009d")
                    if v:IsPlayer() then
                        v:Kill()
                    else
                        v:TakeDamage(1000,self)
                    end
                    v:Ignite(10,0)
                    
                elseif entdist < self.IgniteRadius and v:IsLineOfSightClear(self) then
                    ParticleEffectAttach("nuke_player_vaporize_fatman",PATTACH_POINT_FOLLOW,ent,0)
                    v:SetModel("models/player/Charple01.mdl")
                    if v:IsPlayer() then
                        v:Kill()
                    else
                        v:TakeDamage(1000,self)
                    end
                    v:Ignite(10,0)
                    
                elseif entdist < self.Burn2Radius and v:IsLineOfSightClear(self) then
                    v:SetModel("models/player/corpse1.mdl")
                    v:TakeDamage(50,self)
                    v:Ignite(4,0)
                    
                elseif entdist < self.Burn1Radius and v:IsLineOfSightClear(self) then
                    v:TakeDamage(10,self)
                    v:Ignite(1,0)

                end
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