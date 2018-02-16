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

-- this function initializes the table on each player
local function makePlyTable(ply)
    if not ply.EnduringStockpile then
        ply.EnduringStockpile = {
            Rads = 0,
            RadsPerSecond = 0,
        }
    end
end

local function addRads(ply,r)
    makePlyTable(ply)
    ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + r
    ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + r
end

function ENT:Think()
	
	if (SERVER) then
	if !self:IsValid() then return end
	local pos = self:GetPos()
    
    for _, ply in pairs( player.GetAll() ) do
            -- tracer to find if entity is in the open
        local tracedata    = {}
        tracedata.start    = ply:GetPos() + Vector(0,0,100)
        tracedata.endpos   = tracedata.start - Vector(0, 0, -2000)
        tracedata.filter   = self.Entity
        local trace = util.TraceLine(tracedata)
        local dist = (self:GetPos() - ply:GetPos()):Length()
        local promptdose = self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 3.8)
        local effectivedose = 0
        if ply:IsLineOfSightClear(self) then --not shielded, line of sight
            effectivedose = promptdose
            --PrintMessage( HUD_PRINTCONSOLE, "Not shielded, LOS")
        elseif !ply:IsLineOfSightClear(self) and !trace.HitWorld then --not shielded, no los
            effectivedose = promptdose*0.5
            --PrintMessage( HUD_PRINTCONSOLE, "Not shielded, no LOS")
        elseif (dist>self.Rad5000rem and dist<self.Rad500rem*2) and !ply:IsLineOfSightClear(self) and trace.HitWorld then --shielded, no los
            effectivedose = promptdose*0.2
            --PrintMessage( HUD_PRINTCONSOLE, "Shielded, no LOS")
        elseif dist<=self.Rad5000rem then
            effectivedose = promptdose
            --PrintMessage( HUD_PRINTCONSOLE, "In 5000rem range")
        end
        if ply.hazsuited then
            effectivedose = effectivedose*0.5
        end
        if effectivedose>0 then
            addRads(ply,effectivedose)
        end
        PrintMessage( HUD_PRINTCONSOLE, "Player "..ply:Name().." exposed to "..effectivedose.." rads from prompt radiation")
    end
    
    for _, v in pairs( ents.FindByClass("npc_*") ) do
            -- tracer to find if entity is in the open
        local tracedata    = {}
        tracedata.start    = v:GetPos() + Vector(0,0,100)
        tracedata.endpos   = tracedata.start - Vector(0, 0, -2000)
        tracedata.filter   = self.Entity
        local trace = util.TraceLine(tracedata)
        local dist = (self:GetPos() - v:GetPos()):Length()
        local promptdose = self.RadPower/(4*math.pi*math.pow(dist,2)) / math.pow(dist, 3.8)
        local effectivedose = 0
        if v:IsLineOfSightClear(self) then --not shielded, line of sight
            effectivedose = promptdose
        elseif !v:IsLineOfSightClear(self) and !trace.HitWorld then --not shielded, no los
            effectivedose = promptdose*0.5
        elseif (dist>self.Rad5000rem and dist<self.Rad500rem*2) and !v:IsLineOfSightClear(self) and trace.HitWorld then --shielded, no los
            effectivedose = promptdose*0.2
        elseif dist<=self.Rad5000rem then
            effectivedose = promptdose
        end
        if effectivedose>0 then
            addRads(v,effectivedose)
        end
    end
	self:Remove()
	return true
	end
end

function ENT:Draw()
     return true
end