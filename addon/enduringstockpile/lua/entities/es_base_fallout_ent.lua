AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Fallout"        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      
          
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.HBOWNER = self:GetVar("HBOWNER")
		 self.RadRadius = self:GetVar("Rad_Radius")
		 if self.RadRadius==nil then
			self.RadRadius=500
		 end
     end
end

function ENT:Think() -- why doesnt it work with NPC's?
	
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()
	for k, v in pairs(ents.FindInSphere(pos,self.RadRadius)) do
		if (v:IsPlayer() or v:IsNPC()) then
            -- tracer to find if entity is in the open
            local tracedata    = {}
            tracedata.start    = v:GetPos() + Vector(0,0,100)
            tracedata.endpos   = tracedata.start - Vector(0, 0, -2000)
            tracedata.filter   = self.Entity
            local trace = util.TraceLine(tracedata)
            self.TraceHitPos = trace.HitPos
            if !trace.HitWorld then -- not shielded
                --PrintMessage( HUD_PRINTCONSOLE, "Entity "..v:EntIndex().." not shielded" )
                local dist = (self:GetPos() - v:GetPos()):Length()
                local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                local time_modifier = math.pow((200-self.Bursts) / 200, 4)
                local damage = math.Clamp(15 * dist_modifier * time_modifier, 0.1, 15)
                
                if v.hazsuited==false then
                    local dmg = DamageInfo()
                    dmg:SetDamage(damage)
                    dmg:SetDamageType(DMG_RADIATION)
                    if self.HBOWNER==nil or !self.HBOWNER:IsValid() then
                        self.HBOWNER=table.Random(player.GetAll())
                    end
                    dmg:SetAttacker(self.HBOWNER)
                    --PrintMessage( HUD_PRINTCONSOLE, "T: "..self.Bursts.." Dist: "..dist.." Damage: "..damage.." DM: "..dist_modifier.." TM: "..time_modifier )
                    if !v:IsNPC() then
                        if damage >= 10 then
                            v:EmitSound("geiger/rad_extreme.wav", 100, 100)
                        elseif damage >= 7 then
                            v:EmitSound("geiger/rad_high.wav", 100, 100)
                        elseif damage >= 2 then
                            v:EmitSound("geiger/rad_med.wav", 100, 100)
                        elseif damage > 0 then
                            v:EmitSound("geiger/rad_low.wav", 100, 100)
                        end
                    end
                    v:TakeDamageInfo(dmg)
                end
                PrintMessage( HUD_PRINTCENTER , "Geiger Counter: "..math.Round(5000*dist_modifier*time_modifier).." rads/hr")
            --else
                --PrintMessage( HUD_PRINTCONSOLE, "Entity "..v:EntIndex().." is shielded" )
            end
		end
	end
	self.Bursts = self.Bursts + 1
	if (self.Bursts >= 120) then
		self:Remove()
	end
    self:NextThink(CurTime() + 1)
	return true
	end
end

function ENT:Draw()
     return true
end