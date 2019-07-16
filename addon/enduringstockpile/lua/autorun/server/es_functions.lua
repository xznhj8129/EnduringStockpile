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


function InverseSquareLaw( d )
    local distance = d / 52.521
    local is = 1 / math.pow(distance, 2)
    return is
end

function NuclearHalfLife( quantity , t, hln)
    local remaining = quantity * math.pow(0.5, t / hln) 
    return remaining
end

-- this function determines the shielding present between radiation and player
function TracePathShielding(startent,endent) 
    local startpos = startent:LocalToWorld(startent:OBBCenter())
    local entpos = endent:LocalToWorld(endent:OBBCenter())
    local dist = startpos:Distance(entpos)
    local sourceinwater = startent:WaterLevel() >= 1
    local destinwater = endent:WaterLevel() >= 1
    
    local tracedata    = {}
    tracedata.start    = startpos
    tracedata.endpos   = entpos
    tracedata.filter   = startent.Entity
    tracedata.mask     = MASK_SOLID
    local trace = util.TraceLine(tracedata)
    local hitent = (trace.Entity == endent)
    local halving_thicknesses = 0

    if !hitent then
        if trace.Entity:IsVehicle() and endent:IsPlayer() and endent:InVehicle() and endent:GetVehicle() == trace.Entity then
            local airthickness = trace.HitPos:Distance(startpos)
            local air_shielding = (airthickness * 1.905) / 9000
            halving_thicknesses = air_shielding + 1.25
        else
        
            local tr2    = {}
            tr2.start    = entpos
            
            if endent:IsPlayer() and endent:InVehicle() then
                local playerinvehicle = true
                tr2.filter   = endent:GetVehicle()
            else
                local playerinvehicle = false
                tr2.filter   = endent
            end
            
            tr2.endpos   = trace.HitPos
            tr2.mask     = MASK_SOLID
            local trace2 = util.TraceLine(tr2)

            local thickness = trace.HitPos:Distance(trace2.HitPos)
            
            local airthickness = trace.HitPos:Distance(startpos) + trace2.HitPos:Distance(entpos)
            local air_shielding = (airthickness * 1.905) / 9000
            
            local shielding_value = 7
            if trace.HitNonWorld or trace2.HitNonWorld then
                shielding_value = 3
            end
            
            halving_thicknesses = air_shielding + ((thickness * 1.905) / shielding_value)
            
            if playerinvehicle then
                halving_thicknesses = halving_thicknesses + 1.25
            end
            
        end
        
        if sourceinwater then
            water_shielding = (startpos:Distance(trace.HitPos) * 1.905) / 18
            halving_thicknesses = halving_thicknesses + water_shielding
        end
        
    else 
        if sourceinwater and !destinwater then
            local tr2    = {}
            tr2.start    = entpos
            tr2.endpos   = startpos
            tr2.filter   = endent
            tr2.mask     = CONTENTS_WATER
            local trace2 = util.TraceLine(tr2)
            local water_shielding = (startpos:Distance(trace2.HitPos) * 1.905) / 18
            local air_shielding = (entpos:Distance(trace2.HitPos) * 1.905) / 9000
            halving_thicknesses = water_shielding + air_shielding
            
        elseif sourceinwater and destinwater then
            halving_thicknesses = (startpos:Distance(entpos) * 1.905) / 18
            
        elseif !sourceinwater and destinwater then
            local tr2    = {}
            tr2.start    = startpos
            tr2.endpos   = entpos
            tr2.filter   = startent
            tr2.mask     = CONTENTS_WATER
            local trace2 = util.TraceLine(tr2)
            local water_shielding = (entpos:Distance(trace2.HitPos) * 1.905) / 18
            local air_shielding = (startpos:Distance(trace2.HitPos) * 1.905) / 9000
            halving_thicknesses = water_shielding + air_shielding
            
        else
            halving_thicknesses = (entpos:Distance(startpos) * 1.905) / 9000
        end
    end
    return halving_thicknesses
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
    if trace.Entity != endent then
        return false
    else 
        return true
    end
end

-- find if LOS is blocked between entities
function TraceLineOfSight(startent,endent) 
    local startpos = startent:LocalToWorld(startent:OBBCenter())
    local entpos = endent:LocalToWorld(endent:OBBCenter())
    local dist = math.Round(startpos:Distance(entpos))
    
    local tracedata    = {}
    tracedata.start    = startpos
    tracedata.endpos   = entpos
    tracedata.filter   = startent.Entity
    tracedata.mask     = MASK_SHOT

    local trace = util.TraceLine(tracedata)
    if trace.Entity != endent then
        return false
    else 
        return true
    end
end

-- direct radiation emitter
function RadiationSource(source, radpower)
    local pos = source:LocalToWorld(source:OBBCenter())
    local maxloop = GetConVar("es_max_shieldingtrace"):GetInt()
    local maxrange = GetConVar("es_max_radrange"):GetInt()
    local emp_whitelist = {"gmod_wire_pod",
        "gmod_wire_expression2",
        "gmod_wire_gate",
        "gmod_wire_value",
        "gmod_wire_button",
        "gmod_wire_dynamic_button",
        "gmod_wire_input",
        "gmod_button",
        "gmod_hoverball"}
    
    if GetConVar("es_electronics_rad_damage"):GetInt()==1 then
        for k, v in pairs(ents.FindInSphere(pos,20000)) do
            if(table.HasValue(emp_whitelist,v:GetClass())) then
                local dist = (source:GetPos() - v:GetPos()):Length()
                local shielding = TracePathShielding(source,v) 
                if shielding !=0 then
                    power = radpower/math.pow(2,shielding)
                else
                    power = radpower
                end
                local raddose = power * InverseSquareLaw(dist)
                local exposure = raddose / 60
                AddRadElectronics(v, exposure)
            end
        end
    end
    
    local loopcount = 0
    for _, ent in pairs( ents.FindByModel("models/props_lab/powerbox02d.mdl")) do
        if loopcount > maxloop then
            break
        end
        local dist = (source:GetPos() - ent:GetPos()):Length()
        if ent.GeigerCounter == 1 and dist<maxrange then
            
            local shielding = TracePathShielding(source,ent) 
            if shielding !=0 then
                power = radpower/math.pow(2,shielding)
            else
                power = radpower
            end
            local raddose = power * InverseSquareLaw(dist)
            ent.RadCount = ent.RadCount + raddose
        end
        loopcount = loopcount + 1
    end
 
    local loopcount = 0
    for _, ply in pairs( player.GetAll() ) do
        if loopcount > maxloop then
            break
        end
        local dist = (source:GetPos() - ply:GetPos()):Length()
        
        if ply:IsPlayer() and ply:Alive() and dist<maxrange then
            local shielding = TracePathShielding(source,ply) 
            if shielding !=0 then
                power = radpower/math.pow(2,shielding)
            else
                power = radpower
            end
            local raddose = power * InverseSquareLaw(dist)
            local exposure = raddose/60
            addGeigerRads(ply,raddose)
            addRads(ply,exposure)
        end
        loopcount = loopcount + 1
    end

    local loopcount = 0
    for _, ent in pairs( ents.FindByClass("npc_*") ) do
        if loopcount > maxloop then
            break
        end
        
        local dist = (source:GetPos() - ent:GetPos()):Length()
        
        if ent:IsNPC() and ent:Health()>0 and dist<maxrange then
            local shielding = TracePathShielding(source,ent) 
            if shielding !=0 then
                power = radpower/math.pow(2,shielding)
            else
                power = radpower
            end
            local raddose = power * InverseSquareLaw(dist)
            local exposure = raddose/60
            addRads(ent,exposure)
        end
        loopcount = loopcount + 1
    end
end

-- explosion height type determination
function NuclearBurstType(ent)
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
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "DET: Hit World")
            end
        elseif trace.Hit then
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "DET: Hit non-world")
            end 
        end
        
        if trace.HitWorld then
            BurstType = 0
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "DET: Surface burst")
            end
        else 
            BurstType = 1   
            if GetConVar("es_debug"):GetInt()==1 then
                PrintMessage( HUD_PRINTCONSOLE, "DET: Airburst")
            end
        end
        local hitdist = pos:Distance(trace.HitPos)
        
        if GetConVar("es_debug"):GetInt()==1 then
            PrintMessage( HUD_PRINTCONSOLE, "DET Tracedist: "..hitdist)
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
            lead_suit = false,
            originalmodel = ply:GetModel()
        }
    end
end


-- add radiation to chips
function AddRadElectronics(ent, raddose)
    if not ent.EnduringStockpile then
        ent.EnduringStockpile = {
            TotalDose = 0,
            Rads = 0
        }
    end
    ent.EnduringStockpile.Rads = ent.EnduringStockpile.Rads + raddose
    local rpm = raddose * 60
    if ent.EnduringStockpile.Rads > 10000 or rpm > 25000 then
        RadiationFryChip(ent)
    end
end

-- radiation damage to chips
function RadiationFryChip(v)
    v:Ignite(2)
    v:SetColor(Color(65,65,65,255))
    local sound = string.Explode(" ",table.Random(emp_soundlist))[1]
    v:EmitSound(sound)
    timer.Simple(math.random(2,3)+math.random(), function()
        if !v:IsValid() then return end
        v:Remove()
    end)
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
		    ply:PrintMessage( HUD_PRINTTALK, "Your dosimeter reads "..math.Round(ply.EnduringStockpile.Rads).." rads accumulated dose, "..math.Round(ply.EnduringStockpile.TotalDose).." rads total absorbed dose")
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
