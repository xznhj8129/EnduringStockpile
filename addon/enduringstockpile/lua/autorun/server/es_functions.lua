AddCSLuaFile()


function addRads(ply,r)
    makePlyTable(ply)
    local raddose = r
    if ply.IsPlayer() then
    
        if ply.hazsuited then
            raddose = raddose * 0.25
        end
        
        if ply.EnduringStockpile.radx then
            raddose = raddose * 0.75
        end
        
        ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + raddose
        ply.EnduringStockpile.TotalDose = ply.EnduringStockpile.TotalDose + raddose
        ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + raddose
    else
        
        ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + raddose
        ply.EnduringStockpile.TotalDose = ply.EnduringStockpile.TotalDose + raddose
        ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + raddose
        
    end
end

function addGeigerRads(ply,r)
    makePlyTable(ply)
    ply.EnduringStockpile.GeigerRPS = ply.EnduringStockpile.GeigerRPS + r
end

function getRads(ply)
    makePlyTable(ply)
    local rps = ply.EnduringStockpile.RadsPerSecond
    ply.EnduringStockpile.RadsPerSecond = 0
    return ply.EnduringStockpile.Rads, rps
end

function getGeigerRads(ply)
    makePlyTable(ply)
    local rps = ply.EnduringStockpile.GeigerRPS
    ply.EnduringStockpile.GeigerRPS = 0
    return rps
end

function removeRads(ply,r)
    makePlyTable(ply)
    local rads = ply.EnduringStockpile.Rads
    
    if rads > 0 then
        ply.EnduringStockpile.Rads = rads - r
    end
    
    if rads < 0 or r>rads then
        ply.EnduringStockpile.Rads = 0
    end
end


function inversesquare( d )
    local distance = d / 52.521
    local is = 1 / math.pow(distance, 2)
    return is
end

function halflife( quantity , t, hln)
    local remaining = quantity * math.pow(0.5, t / hln) 
    return remaining
end

-- this function determines the shielding present between radiation and player
function TracePathShielding(source, ent)
    local sourcepos = source:LocalToWorld(source:OBBCenter())
    local entpos = ent:LocalToWorld(ent:OBBCenter())
    
    local tracedata    = {}
    tracedata.start    = sourcepos
    tracedata.endpos   = tracedata.start - Vector(0, 0, 0)
    tracedata.filter   = ent.Entity
    tracedata.mask     = MASK_NPCWORLDSTATIC

    local trace = util.TraceLine(tracedata)
    ent.TraceHitPos = trace.HitPos

    if trace.HitWorld then
    end
end
 
-- find if LOS is blocked by world between entities
function TraceLineOfSightWorld(startent,endent) 
    local startpos = startent:LocalToWorld(startent:OBBCenter())
    local entpos = endent:LocalToWorld(endent:OBBCenter())
    local dist = math.Round(startpos:Distance(entpos))
    
    local tracedata    = {}
    tracedata.start    = startpos
    tracedata.endpos   = entpos
    tracedata.filter   = startent.Entity
    tracedata.mask     = MASK_NPCWORLDSTATIC

    local trace = util.TraceLine(tracedata)
    local TraceHitPos = trace.HitPos
    local hitdist = math.Round(entpos:Distance(TraceHitPos))
    
    --PrintMessage( HUD_PRINTCONSOLE, "TRACE "..hitdist)
    if trace.HitWorld then
        --PrintMessage( HUD_PRINTCONSOLE, "TRACE HIT WORLD")
    end
     
    if hitdist>0 and trace.HitWorld then
        return false
    else 
        return true
    end
    
end

-- direct radiation emitter
function RadiationSource(source, radradius, radpower)
    for _, ent in pairs( ents.FindByModel("models/props_lab/powerbox02d.mdl")) do
    
        if ent.GeigerCounter == 1 then
            local dist = (source:GetPos() - ent:GetPos()):Length()
            
            if dist < radradius and TraceLineOfSightWorld(source,ent) then
                local raddose = radpower * inversesquare(dist)
                ent.RadCount = ent.RadCount + raddose
            end
        end
    end

    for _, ply in pairs( player.GetAll() ) do
        local dist = (source:GetPos() - ply:GetPos()):Length()
        
        if dist < radradius and ply:IsPlayer() and ply:Alive() and ply:IsLineOfSightClear(source) then
            local raddose = radpower * inversesquare(dist)
            local exposure = raddose/60
            addGeigerRads(ply,raddose)
            addRads(ply,exposure)
        end
    end

    for _, ent in pairs( ents.FindByClass("npc_*") ) do
        local dist = (source:GetPos() - ent:GetPos()):Length()
        
        if dist < radradius and ent:IsNPC() and ent:Health()>0 and ent:IsLineOfSightClear(source) then
            local raddose = radpower * inversesquare(dist)
            local exposure = raddose/60
            addRads(ent,exposure)
        end
    end
end

-- explosion height type determination
function bursttype(ent)
    local pos = ent:LocalToWorld(ent:OBBCenter())
    local BurstType = 0
    local HitPos = Vector(0,0,0)
    
    if(ent:WaterLevel() >= 1) then  -- explosion height type determination
        local trdata   = {}
        local trlength = Vector(0,0,9000)

        trdata.start   = pos
        trdata.endpos  = pos + trlength
        trdata.filter  = ent
        local tr = util.TraceLine(trdata) 

        local trdat2   = {}
        trdat2.start   = tr.HitPos
        trdat2.endpos  = pos - trlength
        trdat2.filter  = ent.Entity
        trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
        
        local tr2 = util.TraceLine(trdat2)
        HitPos = tr2.HitPos
        
        if tr2.Hit then
            BurstType = 2
            ent.TraceHitPos = tr2.HitPos
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Underwater burst")
            end
        else
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Water Surface burst")
            end
        end
    else
        local tracedata    = {}
        tracedata.start    = pos
        tracedata.endpos   = tracedata.start - Vector(0, 0, ent.FireballSize)
        tracedata.filter   = ent.Entity
        tracedata.mask     = MASK_NPCWORLDSTATIC
        
        local trace = util.TraceLine(tracedata)
        HitPos = trace.HitPos
        
        if trace.HitWorld then
            BurstType = 0
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Surface burst")
            end
        else 
            BurstType = 1   
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Airburst")
            end
        end
        local hitdist = pos:Distance(trace.HitPos)
        if GetConVar("es_debug"):GetInt()==1 then
            PrintMessage( HUD_PRINTCONSOLE, "Tracedist: "..hitdist)
            PrintMessage( HUD_PRINTCONSOLE, tostring(HitPos))
        end
    end
    if HitPos == nil then
        HitPos = pos
    end
    return BurstType, HitPos
end


-- this function initializes the table on each player
function makePlyTable(ply)
    if not ply.EnduringStockpile then
        ply.EnduringStockpile = {
            TotalDose = 0,
            Rads = 0,
            RadsPerSecond = 0,
            GeigerSound = 1,
            GeigerRads = 0,
            GeigerRPS = 0,
            radx = false,
            radxtime = 0,
            radaway = false,
            radawaytime = 0,
            dosimeter = false,
            nbc_suit = false,
            lead_suit = false
        }
    end
end


function clearPlyTable(ply)
    makePlyTable(ply)
    ply.EnduringStockpile.TotalDose = 0
    ply.EnduringStockpile.Rads = 0
    ply.EnduringStockpile.RadsPerSecond = 0
    ply.EnduringStockpile.GeigerRads = 0
    ply.EnduringStockpile.GeigerRPS = 0
    ply.EnduringStockpile.radx = false
    ply.EnduringStockpile.dosimeter = false
    ply.EnduringStockpile.radxtime = 0
    ply.EnduringStockpile.radaway = false
    ply.EnduringStockpile.radawaytime = 0
    ply.EnduringStockpile.nbc_suit = false
    ply.EnduringStockpile.lead_suit = false
    ply.EnduringStockpile.originalmodel = ply:GetModel()
end


-- hooks
hook.Add("PlayerDeath","enduringstockpile_rads_death", clearPlyTable)

hook.Add( "PlayerSay", "CheckDosimeter", function( ply, text, team )
	if ( string.lower( text ) == "/dosimeter" ) then
	    if ply.EnduringStockpile.dosimeter then
		    ply:PrintMessage( HUD_PRINTTALK, "Your dosimeter reads "..math.Round(ply.EnduringStockpile.Rads).." rads, "..math.Round(ply.EnduringStockpile.TotalDose).." total")
		else
		    ply:PrintMessage( HUD_PRINTTALK, "You have no personal dosimeter")
		end
    end
end )

hook.Add( "PlayerSay", "GeigerMute", function( ply, text, team )
	-- Make the chat message entirely lowercase
	if string.lower(text) == "/geigersound" then
        if ply.EnduringStockpile.GeigerSound == 1 then
            ply:PrintMessage( HUD_PRINTTALK, "Geiger counter muted")
            ply.EnduringStockpile.GeigerSound = 0
        else
            ply:PrintMessage( HUD_PRINTTALK, "Geiger counter unmuted")
            ply.EnduringStockpile.GeigerSound = 1
        end
	end
end )
