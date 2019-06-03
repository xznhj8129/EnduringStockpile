AddCSLuaFile()


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
        trdat2.filter  = ent
        trdat2.mask    = MASK_WATER + CONTENTS_TRANSLUCENT
        
        local tr2 = util.TraceLine(trdat2)
        
        if tr2.Hit then
            ent.BurstType = 2
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
        ent.TraceHitPos = trace.HitPos
        
        if trace.HitWorld then
            ent.BurstType = 0
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Surface burst")
            end
        else 
            ent.BurstType = 1   
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "Airburst")
            end
        end
        local hitdist = pos:Distance(trace.HitPos)
        if GetConVar("es_debug"):GetInt()==1 then
            PrintMessage( HUD_PRINTCONSOLE, "Tracedist: "..hitdist)
        end
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

function inversesquare( d )
    local distance = d / 52.521
    local is = 1 / math.pow(distance, 2)
    return is
end

function halflife( quantity , t, hln)
    local remaining = quantity * math.pow(0.5, t / hln) 
    return remaining
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
