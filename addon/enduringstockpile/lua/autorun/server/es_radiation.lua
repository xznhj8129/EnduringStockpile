AddCSLuaFile()

-- just some helper functions

function addRads(ply,r)
    makePlyTable(ply)
    local raddose = r*60
    if ply.IsPlayer() then
        if ply.hazsuited then
            ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + (r/5)
            ply.EnduringStockpile.TotalDose = ply.EnduringStockpile.TotalDose + (r/5)
            ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + (r/5)
        else
            ply.EnduringStockpile.Rads = ply.EnduringStockpile.Rads + r
            ply.EnduringStockpile.TotalDose = ply.EnduringStockpile.TotalDose + r
            ply.EnduringStockpile.RadsPerSecond = ply.EnduringStockpile.RadsPerSecond + r
        end
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
            -- put any more options here if you wanna keep track of other values
        }
    end
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

function clearRads(ply)
    makePlyTable(ply)
    ply.EnduringStockpile.TotalDose = 0
    ply.EnduringStockpile.Rads = 0
    ply.EnduringStockpile.RadsPerSecond = 0
    ply.EnduringStockpile.GeigerRads = 0
    ply.EnduringStockpile.GeigerRPS = 0
end


-- hooks
hook.Add("PlayerDeath","enduringstockpile_rads_death", clearRads)

hook.Add( "PlayerSay", "CheckDosimeter", function( ply, text, team )
	-- Make the chat message entirely lowercase
	if ( string.lower( text ) == "/dosimeter" ) then
		ply:PrintMessage( HUD_PRINTTALK, "Your dosimeter reads "..math.Round(ply.EnduringStockpile.Rads).." rads, "..math.Round(ply.EnduringStockpile.TotalDose).." total")
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

-- main timer
timer.Create( "radiation_damage_think", 1, 0, function() -- 1 second timer, infinite repetitions
    for _, ply in pairs( player.GetAll() ) do
        if ply.EnduringStockpile then
			if !ply:HasGodMode() then
			
			    local totaldose = ply.EnduringStockpile.TotalDose
			    if totaldose > 1000 then
			        local maxh = 100-(math.pow((totaldose-1000)/100,1.25))
			        ply:SetMaxHealth(maxh)
			    end
			
				local rads, recentrads = getRads(ply)
				if rads > 0 then
					--PrintMessage( HUD_PRINTCONSOLE, "Dosimeter "..math.Round(rads).." Total "..math.Round(totaldose) )
					local raddamage = rads * 0.001
					
					if raddamage < 1 then
                        local ctd = math.Round(raddamage*100)
                        local draw = math.random(0,100)
                        if draw <= ctd then
							ply:SetHealth(ply:Health() - 1) -- this way damage is silent
						end
					else
					    ply:SetHealth(ply:Health() - raddamage) -- this way damage is silent
					end
					
					if ply:Health() <= 0 then
					    ply:Kill()
					end
					
					if rads > 2000 then
						local ctd = math.Round((rads/100000)*1000)
						local draw = math.random(0,1000)
						if draw <= ctd then
							ply:Kill()
						end
					end
				end
				
				local geigerrps = getGeigerRads(ply)
				if geigerrps > 0 then
					ply:PrintMessage( HUD_PRINTCENTER , "Geiger Counter: "..math.Round(geigerrps).." rads/min")
					if ply.EnduringStockpile.GeigerSound == 1 then
						if (geigerrps) >= 1000 then
							ply:EmitSound("geiger/rad_extreme.wav", 100, 100)
						elseif (geigerrps) >= 400 then
							ply:EmitSound("geiger/rad_veryhigh.wav", 100, 100)
						elseif (geigerrps) >= 200 then
							ply:EmitSound("geiger/rad_high.wav", 100, 100)
						elseif (geigerrps) >= 100 then
							ply:EmitSound("geiger/rad_med.wav", 100, 100)
						elseif (geigerrps) > 0 then
							ply:EmitSound("geiger/rad_low.wav", 100, 100)
						end
					end
				end
				if geigerrps < rads then    
    				removeRads(ply, math.random(1,10))
    			end
			end
            
        else
            makePlyTable(ply)
        end
    end
    
    for _, v in pairs( ents.FindByClass("npc_*") ) do
        if v.EnduringStockpile then
            local rads, recentrads = getRads(v)
            
            if rads > 0 then
                local raddamage = rads * 0.001
				local randomdamage = math.random((raddamage/2),raddamage)
				
				local dmg = DamageInfo()
				dmg:SetDamage(randomdamage)
                dmg:SetDamageType(DMG_RADIATION)
                dmg:SetAttacker(v)
                v:TakeDamageInfo(dmg)
                if rads > 2000 then
                    local ctd = math.Round((rads/100000)*1000)
                    local draw = math.random(0,1000)
                    if draw < ctd then
                        v:TakeDamage(1000000, v, v )
                    end
                end
            end
            removeRads(v, math.random(1,10))
            
        else
            makePlyTable(v)
        end
    end
end)
