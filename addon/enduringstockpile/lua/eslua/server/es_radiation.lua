AddCSLuaFile()

-- main timer
timer.Create( "radiation_damage_think", 1, 0, function() -- 1 second timer, infinite repetitions
    if GetConVar("es_falloutlength") == nil then
        CreateConVar("es_falloutlength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
    end
    if GetConVar("es_falloutlength"):GetInt() < 1 then
        RunConsoleCommand("es_falloutlength", "1")
    end
    for _, ply in pairs( player.GetAll() ) do
        if ply.EnduringStockpile then
			if !ply:HasGodMode() then
			    
			    if ply.EnduringStockpile.radx then
			        ply.EnduringStockpile.radxtime = ply.EnduringStockpile.radxtime - 1
			        if ply.EnduringStockpile.radxtime <= 0 then
			            ply.EnduringStockpile.radx = false
			            ply.EnduringStockpile.radxtime = 0
			         end
			    end
			    
			    local totaldose = ply.EnduringStockpile.TotalDose
                --PrintMessage( HUD_PRINTCONSOLE, "TD     "..totaldose)
			    if totaldose > 1000 then
			        local maxh = 100-(math.pow((totaldose-1000)/100,1.25))
			        ply:SetMaxHealth(maxh)
			    end
			
				local rads, recentrads = getRads(ply)
				if rads > 1 then
		
                    if math.random(0,100) <= math.Round((rads/1000)*20) then
                        ply:SetHealth(ply:Health() - math.random(1,10))
                    end
					
					if ply:Health() <= 0 then
					    ply:Kill()
					end
                    
                    if rads > 5000 then
						local ctd = math.Round((rads/500000)*1000)
						local draw = math.random(0,1000)
						if draw <= ctd then
							ply:Kill()
						end
					end
                    
				end
				
				local geigerrps = getGeigerRads(ply)
				--print(geigerrps)
				ply:SetNetworkedInt("EnduringStockPileGeigerHud",geigerrps)
				ply:SetNetworkedBool("EnduringStockPileDoHud",ply.EnduringStockpile.dosimeter)
				ply:SetNetworkedInt("EnduringStockPileDosimeter",math.Round(ply.EnduringStockpile.TotalDose,2))
				ply:SetNetworkedInt("EnduringStockPileDosimeterAcc",math.Round(ply.EnduringStockpile.Rads,2))
                
				if geigerrps > 0 then
				    if ply.EnduringStockpile.dosimeter then
                        geigerrps = geigerrps + (math.random(10,20)/10000000)
						ply:SetNetworkedInt("EnduringStockPileGeigerHud",geigerrps)
					    if ply.EnduringStockpile.GeigerSound == 1 then
						    if (geigerrps) >= 1000 then
							    ply:EmitSound("geiger/rad_extreme.wav", 100, 100)
						    elseif (geigerrps) >= 400 then
							    ply:EmitSound("geiger/rad_veryhigh.wav", 100, 100)
						    elseif (geigerrps) >= 200 then
							    ply:EmitSound("geiger/rad_high.wav", 100, 100)
						    elseif (geigerrps) >= 100 then
							    ply:EmitSound("geiger/rad_med.wav", 100, 100)
						    elseif microrads > 2 then
							    ply:EmitSound("geiger/rad_low.wav", 100, 100)
						    end
					    end
					end
				end

		        if geigerrps <= rads then
			        if ply.EnduringStockpile.radaway then
			            
		                removeRads(ply, math.random(5,20))
		                ply.EnduringStockpile.radawaytime = ply.EnduringStockpile.radawaytime - 1
		                if ply.EnduringStockpile.radawaytime <= 0 then
		                    ply.EnduringStockpile.radaway = false
		                    ply.EnduringStockpile.radawaytime = 0
		                 end
		            else
				        removeRads(ply, math.random(0,11))
				    end
			    end
			end
            
        else
            makePlyTable(ply)
        end
    end
    
    for _, v in pairs( ents.FindByClass("npc_*") ) do
        if v.EnduringStockpile then
            local rads, recentrads = getRads(v)
            if rads > 1 then
                local raddamage = rads * 0.001
                
                if math.random(0,100) <= math.Round((rads/1000)*20) then
                    local dmg = DamageInfo()
                    dmg:SetDamage(math.random(1,10))
                    dmg:SetDamageType(DMG_RADIATION)
                    dmg:SetAttacker(v)
                    v:TakeDamageInfo(dmg)
                end
                
                if rads > 2000 then
                    local ctd = math.Round((rads/500000)*1000)
                    local draw = math.random(0,1000)
                    if draw < ctd then
                        v:TakeDamage(1000000, v, v )
                    end
                end
            else
                removeRads(v, math.random(1,11))
            end
            
        else
            makePlyTable(v)
        end
    end
end)
