AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  "Prompt Radiation"        
ENT.Author			                 =  "snowfrog"      
ENT.Contact			                 =  ""     
ENT.RadPower                         =  0 
ENT.Rad5000rem                       =  0
ENT.Rad1000rem                       =  0
ENT.Rad500rem                        =  0
          
function ENT:Initialize()
     if (SERVER) then
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.HBOWNER = self:GetVar("HBOWNER")
		 self.RadRadius = self:GetVar("Rad_Radius")
		 if self.RadRadius==nil then
			self.RadRadius=500
		 end
		 if self.Burst==nil then
			self.Burst=10
		 end
     end
end

function ENT:Think()
	
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()

    for _, v in pairs( ents.FindByModel("models/props_lab/powerbox02d.mdl") ) do
            -- tracer to find if vity is in the open
        if v.GeigerCounter == 1 then
            local tracedata    = {}
            tracedata.start    = v:GetPos() + Vector(0,0,100)
            tracedata.endpos   = tracedata.start - Vector(0, 0, -2000)
            tracedata.filter   = self.Entity
            local trace = util.TraceLine(tracedata)
            local dist = (self:GetPos() - v:GetPos()):Length()
            local promptdose = self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 3.8)
            local effectivedose = promptdose
            
            if TraceLineOfSight(self,v)  then --not shielded, line of sight
                effectivedose = promptdose
                --PrintMessage( HUD_PRINTCONSOLE, "NOTSH, LOS")
                
            elseif !TraceLineOfSight(self,v) and !trace.HitWorld then --not shielded, no los
                local shielding = TracePathShielding(self,v)
                local shielding_val = 1
                if shielding !=0 then
                    shielding_val = math.pow(2,shielding)
                end
                effectivedose = promptdose / shielding_val
                --PrintMessage( HUD_PRINTCONSOLE, "NOTSH, NOLOS")
                
            elseif !TraceLineOfSight(self,v) and trace.HitWorld then --shielded, no los
                local shielding = TracePathShielding(self,v)
                local shielding_val = 1
                if shielding !=0 then
                    shielding_val = math.pow(2,shielding)
                end
                effectivedose = (self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 4.2)) / shielding_val
                --PrintMessage( HUD_PRINTCONSOLE, "SH, NOLOS")
            end
            
            if effectivedose>0 then
                v.RadCount = v.RadCount + effectivedose*4*60
            end
        end
    end
    
    for _, ply in pairs( player.GetAll() ) do
            -- tracer to find if entity is in the open
        if ply:Alive() and !ply:HasGodMode() then
            local tracedata    = {}
            tracedata.start    = ply:GetPos() + Vector(0,0,100)
            tracedata.endpos   = tracedata.start - Vector(0, 0, -2000)
            tracedata.filter   = self.Entity
            local trace = util.TraceLine(tracedata)
            local dist = (self:GetPos() - ply:GetPos()):Length()
            local promptdose = self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 3.8)
            local effectivedose = promptdose
            
            if TraceLineOfSight(self,ply)  then --not shielded, line of sight
                effectivedose = promptdose
                --PrintMessage( HUD_PRINTCONSOLE, "NOTSH, LOS")
                
            elseif !TraceLineOfSight(self,ply) and !trace.HitWorld then --not shielded, no los
                local shielding = TracePathShielding(self,ply)
                local shielding_val = 1
                if shielding !=0 then
                    shielding_val = math.pow(2,shielding) 
                end
                effectivedose = promptdose / shielding_val
                --PrintMessage( HUD_PRINTCONSOLE, "NOTSH, NOLOS")
                
            elseif !TraceLineOfSight(self,ply) and trace.HitWorld then --shielded, no los
                local shielding = TracePathShielding(self,ply)
                local shielding_val = 1
                if shielding !=0 then
                    shielding_val = math.pow(2,shielding)
                end
                effectivedose = (self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 4.2)) / shielding_val
                --PrintMessage( HUD_PRINTCONSOLE, "SH, NOLOS")
            end
            
            if effectivedose>0 then
                addRads(ply,effectivedose)
                addGeigerRads(ply,effectivedose*4*60)
            end
            
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Player "..ply:Name().." exposed to "..effectivedose.." rads from prompt radiation")
            end
            
        end
    end
    
    for _, v in pairs( ents.FindByClass("npc_*") ) do
        -- tracer to find if entity is in the open
        if v:Health()>0 then
            local tracedata    = {}
            tracedata.start    = v:GetPos() + Vector(0,0,100)
            tracedata.endpos   = tracedata.start - Vector(0, 0, -2000)
            tracedata.filter   = self.Entity
            local trace = util.TraceLine(tracedata)
            local dist = (self:GetPos() - v:GetPos()):Length()
            local promptdose = self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 3.8)
            local effectivedose = promptdose
            
            if TraceLineOfSight(self,v)  then --not shielded, line of sight
                effectivedose = promptdose
                --PrintMessage( HUD_PRINTCONSOLE, "NOTSH, LOS")
                
            elseif !TraceLineOfSight(self,v) and !trace.HitWorld then --not shielded, no los
                local shielding = TracePathShielding(self,v)
                local shielding_val = 1
                if shielding !=0 then
                    shielding_val = math.pow(2,shielding)
                end
                effectivedose = promptdose / shielding_val
                --PrintMessage( HUD_PRINTCONSOLE, "NOTSH, NOLOS")
                
            elseif !TraceLineOfSight(self,v) and trace.HitWorld then --shielded, no los
                local shielding = TracePathShielding(self,v)
                local shielding_val = 1
                if shielding !=0 then
                    shielding_val = math.pow(2,shielding)
                end
                effectivedose = (self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 4.2)) / shielding_val
                --PrintMessage( HUD_PRINTCONSOLE, "SH, NOLOS")
            end
            
            if effectivedose>0 then
                addRads(v,effectivedose)
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
