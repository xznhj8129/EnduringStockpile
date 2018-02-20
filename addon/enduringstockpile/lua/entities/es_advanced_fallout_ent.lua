AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable                         =  false
ENT.AdminSpawnable                    =  false

ENT.PrintName                         =  "Radioactive Fallout"
ENT.Author                            =  "snowfrog"
ENT.Contact                           =  ""

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

-- this function initializes the table on each player
local function makePlyTable(ply)
    if not ply.EnduringStockpile then
        ply.EnduringStockpile = {
            Rads = 0,
            RadsPerSecond = 0,
            -- put any more options here if you wanna keep track of other values
        }
    end
end

-- just some helper functions
local function addRads(ply,r)
    makePlyTable(ply)
    ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + r
    ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + r
end
local function removeRads(ply,r)
    makePlyTable(ply)
    if ply.EnduringStockpile.Rads > 0 then
        ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads - r
    end
    if ply.EnduringStockpile.Rads < 0 then
        ply.EnduringStockpile.Rads = 0
    end
end
local function clearRads(ply)
    makePlyTable(ply)
    ply.EnduringStockpile.Rads = 0
    ply.EnduringStockpile.RadsPerSecond = 0
end
local function getRads(ply)
    makePlyTable(ply)
    local rps = ply.EnduringStockpile.RadsPerSecond
    ply.EnduringStockpile.RadsPerSecond = 0
    return ply.EnduringStockpile.Rads, rps
end

hook.Add("PlayerDeath","enduringstockpile_rads_death", clearRads)

hook.Add( "PlayerSay", "CheckDosimeter", function( ply, text, team )
	-- Make the chat message entirely lowercase
	if ( string.lower( text ) == "/dosimeter" ) then
		ply:PrintMessage( HUD_PRINTTALK, "Your dosimeter reads "..math.Round(ply.EnduringStockpile.Rads).." rads")
	end
end )

timer.Create( "radiation_damage_think", 1, 0, function() -- 1 second timer, infinite repetitions
    for _, ply in pairs( player.GetAll() ) do
        if ply.EnduringStockpile then
            local rads, recentrads = getRads(ply)
            
            if rads > 0 then
                PrintMessage( HUD_PRINTCONSOLE, "Dosimeter "..rads )
                ply:TakeDamage(math.random((raddamage/2),(raddamage*2)), ply, ply )
                if rads > 1000 then
                    local ctd = math.Round((rads/20000)*100)
                    local draw = math.random(0,100)
                    if draw <= ctd then
                        ply:Kill()
                    end
                end
                --
            end
            if recentrads > 0 then
                ply:PrintMessage( HUD_PRINTCENTER , "Geiger Counter: "..math.Round(recentrads*10).." rads/hr")
                if (recentrads*10) >= 1000 then
                    ply:EmitSound("geiger/rad_extreme.wav", 100, 100)
                elseif (recentrads*10) >= 400 then
                    ply:EmitSound("geiger/rad_veryhigh.wav", 100, 100)
                elseif (recentrads*10) >= 200 then
                    ply:EmitSound("geiger/rad_high.wav", 100, 100)
                elseif (recentrads*10) >= 100 then
                    ply:EmitSound("geiger/rad_med.wav", 100, 100)
                elseif (recentrads*10) > 0 then
                    ply:EmitSound("geiger/rad_low.wav", 100, 100)
                end
            end
            removeRads(ply, math.random(5,10))
            
        else
            makePlyTable(ply)
        end
    end
    
    for _, v in pairs( ents.FindByClass("npc_*") ) do
        if v.EnduringStockpile then
            local rads, recentrads = getRads(v)
            
            if rads > 0 then
                v:TakeDamage(math.random((raddamage/2),(raddamage*2)), v, v )
                if rads > 1000 then
                    local ctd = math.Round((rads/20000)*100)
                    local draw = math.random(0,100)
                    if draw <= ctd then
                        v:TakeDamage(1000000, v, v )
                    end
                end
            end
            removeRads(v, math.random(5,10))
            
        else
            makePlyTable(v)
        end
    end
end)

function ENT:Think()
    
    if (SERVER) then
        if !self:IsValid() then return end
        local pos = self:GetPos()
        
        for _, ply in pairs( player.GetAll() ) do
            local dist = (self:GetPos() - ply:GetPos()):Length()
            if dist<self.RadRadius and ply:IsPlayer() and ply:Alive() then
                -- tracer to find if entity is in the open
                local tracedata    = {}
                tracedata.start    = ply:GetPos() + Vector(0,0,100)
                tracedata.endpos   = tracedata.start - Vector(0, 0, -4000)
                tracedata.filter   = self.Entity
                local trace = util.TraceLine(tracedata)
                if !trace.HitWorld then -- not shielded
                    local dist = (self:GetPos() - ply:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    if self.Bursts<9 then
                        time_modifier = self.Bursts / 9
                    else
                        time_modifier = math.pow((200-(self.Bursts-9)) / 200, 6)
                    end
                    local raddose = math.Round((5000*dist_modifier*time_modifier))
                    
                    if !ply.hazsuited or (ply.hazsuited and raddose>1000) then
                        local exposure = raddose/60
                        if ply.hazsuited then
                            exposure = exposure/2
                        end
                        addRads(ply,exposure)
                        --PrintMessage( HUD_PRINTCONSOLE, "Rads/sec: "..math.Round(exposure))
                    end
                end
            end
        end
        
        for _, v in pairs( ents.FindByClass("npc_*") ) do
            local dist = (self:GetPos() - v:GetPos()):Length()
            if dist<self.RadRadius and v:IsNPC() and v:Health()>0 then
                -- tracer to find if entity is in the open
                local tracedata    = {}
                tracedata.start    = v:GetPos() + Vector(0,0,100)
                tracedata.endpos   = tracedata.start - Vector(0, 0, -4000)
                tracedata.filter   = self.Entity
                local trace = util.TraceLine(tracedata)
                if !trace.HitWorld then -- not shielded
                    local dist = (self:GetPos() - v:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    if self.Bursts<9 then
                        time_modifier = self.Bursts / 9
                    else
                        time_modifier = math.pow((200-(self.Bursts-9)) / 200, 6)
                    end
                    local raddose = math.Round((5000*dist_modifier*time_modifier))
                    local exposure = raddose/60
                    addRads(v,exposure)
                end
            end
        end
        
        self.Bursts = self.Bursts + 0.25
        if (self.Bursts >= 120) then
            self:Remove()
        end
        self:NextThink(CurTime() + 0.25)
        return true
    end
end

function ENT:Draw()
    return true
end