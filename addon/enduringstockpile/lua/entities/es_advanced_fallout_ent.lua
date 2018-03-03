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
            GeigerSound = 1,
            GeigerRads = 0,
            GeigerRPS = 0,
            -- put any more options here if you wanna keep track of other values
        }
    end
end


-- just some helper functions
local function addRads(ply,r)
    makePlyTable(ply)
    local raddose = r*60
    if ply.IsPlayer() then
        if !ply.hazsuited or (ply.hazsuited and raddose>1000) then
            if ply.hazsuited then
                ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + ((raddose-1000)/60)/2
                ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + ((raddose-1000)/60)/2
            else
                ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + r
                ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + r
            end
        end
    else
        ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + r
        ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + r
    end
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
    ply.EnduringStockpile.GeigerRads = 0
    ply.EnduringStockpile.GeigerRPS = 0
end
local function getRads(ply)
    makePlyTable(ply)
    local rps = ply.EnduringStockpile.RadsPerSecond
    ply.EnduringStockpile.RadsPerSecond = 0
    return ply.EnduringStockpile.Rads, rps
end
local function addGeigerRads(ply,r)
    makePlyTable(ply)
    ply.EnduringStockpile.GeigerRPS = ply.EnduringStockpile.GeigerRPS + r
end
local function getGeigerRads(ply)
    makePlyTable(ply)
    local rps = ply.EnduringStockpile.GeigerRPS
    ply.EnduringStockpile.GeigerRPS = 0
    return rps
end


-- hooks
hook.Add("PlayerDeath","enduringstockpile_rads_death", clearRads)

hook.Add( "PlayerSay", "CheckDosimeter", function( ply, text, team )
	-- Make the chat message entirely lowercase
	if ( string.lower( text ) == "/dosimeter" ) then
		ply:PrintMessage( HUD_PRINTTALK, "Your dosimeter reads "..math.Round(ply.EnduringStockpile.Rads).." rads")
	end
end )

hook.Add( "PlayerSay", "GeigerMute", function( ply, text, team )
	-- Make the chat message entirely lowercase
	if ( string.lower( text ) == "/geigersound" ) then
        if ply.EnduringStockpile.GeigerSound == 1 then
            ply:PrintMessage( HUD_PRINTTALK, "Geiger counter muted")
            ply.EnduringStockpile.GeigerSound = 0
        else
            ply:PrintMessage( HUD_PRINTTALK, "Geiger counter unmuted")
            ply.EnduringStockpile.GeigerSound = 1
        end
	end
end )


-- timer
timer.Create( "radiation_damage_think", 1, 0, function() -- 1 second timer, infinite repetitions
    for _, ply in pairs( player.GetAll() ) do
        if ply.EnduringStockpile then
        
            local rads, recentrads = getRads(ply)
            if rads > 0 then
                PrintMessage( HUD_PRINTCONSOLE, "Dosimeter "..math.Round(rads) )
                local raddamage = rads/3 * 0.01
                
                local dmg = DamageInfo()
                dmg:SetDamage(math.random((raddamage/2),(raddamage*2)))
                dmg:SetDamageType(DMG_DIRECT)
                dmg:SetAttacker(ply)
                ply:TakeDamageInfo(dmg)
                if rads > 1000 then
                    local ctd = math.Round((rads/20000)*100)
                    local draw = math.random(0,100)
                    if draw <= ctd then
                        ply:Kill()
                    end
                end
                --
            end
            
            local geigerrps = getGeigerRads(ply)
            if geigerrps > 0 then
                ply:PrintMessage( HUD_PRINTCENTER , "Geiger Counter: "..math.Round(geigerrps/4).." rads/hr")
                if ply.EnduringStockpile.GeigerSound == 1 then
                    if (geigerrps/4) >= 1000 then
                        ply:EmitSound("geiger/rad_extreme.wav", 100, 100)
                    elseif (geigerrps/4) >= 400 then
                        ply:EmitSound("geiger/rad_veryhigh.wav", 100, 100)
                    elseif (geigerrps/4) >= 200 then
                        ply:EmitSound("geiger/rad_high.wav", 100, 100)
                    elseif (geigerrps/4) >= 100 then
                        ply:EmitSound("geiger/rad_med.wav", 100, 100)
                    elseif (geigerrps/4) > 0 then
                        ply:EmitSound("geiger/rad_low.wav", 100, 100)
                    end
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
                local raddamage = rads/3 * 0.01
                local dmg = DamageInfo()
                dmg:SetDamage(math.random((raddamage/2),(raddamage*2)))
                dmg:SetDamageType(DMG_RADIATION)
                dmg:SetAttacker(v)
                v:TakeDamageInfo(dmg)
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


-- entity
function ENT:Think()
    
    if (SERVER) then
        if !self:IsValid() then return end
        local pos = self:GetPos()
        
        if falloutlen == nil then
            CreateConVar("es_falloutlength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        end
        
        local falloutlen = GetConVar("es_falloutlength"):GetInt()
        
        for _, v in pairs( ents.FindByModel("models/props_lab/powerbox02d.mdl")) do
            if v.GeigerCounter == 1 then
                -- tracer to find if entity is in the open
                local tracedata    = {}
                tracedata.start    = v:GetPos() + Vector(0,0,80)
                tracedata.endpos   = tracedata.start - Vector(0, 0, -4000)
                tracedata.filter   = self.Entity
                local trace = util.TraceLine(tracedata)
                if !trace.HitWorld then -- not shielded
                    local dist = (self:GetPos() - v:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    if self.Bursts<9 then
                        time_modifier = self.Bursts / 9
                    else
                        time_modifier = math.pow(((200*falloutlen)-(self.Bursts-9)) / (200*falloutlen), 6)
                    end
                    local raddose = math.Round((5000*dist_modifier*time_modifier))
                    v.RadCount = v.RadCount + raddose
                end
            end
        end
        
        for _, ply in pairs( player.GetAll() ) do
            local dist = (self:GetPos() - ply:GetPos()):Length()
            if dist<self.RadRadius and ply:IsPlayer() and ply:Alive() then
                -- tracer to find if entity is in the open
                local tracedata    = {}
                tracedata.start    = ply:GetPos() + Vector(0,0,80)
                tracedata.endpos   = tracedata.start - Vector(0, 0, -4000)
                tracedata.filter   = self.Entity
                local trace = util.TraceLine(tracedata)
                if !trace.HitWorld then -- not shielded
                    local dist = (self:GetPos() - ply:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    if self.Bursts<9 then
                        time_modifier = self.Bursts / 9
                    else
                        time_modifier = math.pow(((200*falloutlen)-(self.Bursts-9)) / (200*falloutlen), 6)
                    end
                    local raddose = math.Round((5000*dist_modifier*time_modifier))
                    local exposure = raddose/60
                    --PrintMessage( HUD_PRINTCONSOLE, "RD "..raddose )
                    addGeigerRads(ply,raddose)
                    addRads(ply,exposure)
                end
            end
        end
        
        for _, v in pairs( ents.FindByClass("npc_*") ) do
            local dist = (self:GetPos() - v:GetPos()):Length()
            if dist<self.RadRadius and v:IsNPC() and v:Health()>0 then
                -- tracer to find if entity is in the open
                local tracedata    = {}
                tracedata.start    = v:GetPos() + Vector(0,0,80)
                tracedata.endpos   = tracedata.start - Vector(0, 0, -4000)
                tracedata.filter   = self.Entity
                local trace = util.TraceLine(tracedata)
                if !trace.HitWorld then -- not shielded
                    local dist = (self:GetPos() - v:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    if self.Bursts<9 then
                        time_modifier = self.Bursts / 9
                    else
                        time_modifier = math.pow(((200*falloutlen)-(self.Bursts-9)) / (200*falloutlen), 6)
                    end
                    local raddose = math.Round((5000*dist_modifier*time_modifier))
                    local exposure = raddose/60
                    addRads(v,exposure)
                end
            end
        end
        
        self.Bursts = self.Bursts + 0.25
        if (self.Bursts >= (120*falloutlen)) then
            self:Remove()
        end
        self:NextThink(CurTime() + 0.25)
        return true
    end
end

function ENT:Draw()
    return true
end