AddCSLuaFile()
local PANEL = {}
local function convclr( color ) return color.r, color.g, color.b, color.a; end

function PANEL:DoESRads(Rads,xperx)
	--print("hey fucktard")
	local dcol
	local w=ScrW()
	local h=ScrH()
	local yel=255
	if xperx=="RADS / MIN" then --fancy color change, ooOOoO
		yel=10/(math.Clamp(Rads,0,100))*255
		dcol=Color(255,yel,0,255)
	else 
		dcol=Color(0,255,0,255)
	end
	if yel<=70 then
		draw.SimpleText("CAUTION","HudSelectionText",w*0.028,h*0.805,Color(255,0,0,255),0,0) --if there was a font that had a skull and crossbones, i absolutely would have used it here
	end
	draw.RoundedBox(6,w*0.018,h*0.800,180,75,Color(0,0,0,200))
	draw.SimpleText(Rads,"HudNumbers",w*0.028,h*0.814,dcol,0,0)
	draw.SimpleText(xperx,"HudSelectionText",w*0.028,h*0.845,dcol,0,0)
end

function PANEL:DoESDosi(Total,Acc,ply)
	local w=ScrW()
	local h=ScrH()
	draw.RoundedBox(6,w*0.13,h*0.800,200,75,Color(0,0,0,200))
	draw.SimpleText(tostring(math.Round(Acc)).." / "..tostring(math.Round(Total)),"HudNumbers",w*0.133,h*0.814,Color(0,255,0,255),0,0)
	draw.SimpleText("DOSE - CURRENT / TOTAL","HudSelectionText",w*0.133,h*0.845,Color(0,255,0,255),0,0)

end

hook.Add( "HUDPaint", "HUDPaint_EsRadCounter", function()
	for _, ply in pairs( player.GetAll() ) do
		if ply:GetNetworkedInt("EnduringStockPileDoHud") then
            local TRad=ply:GetNetworkedInt("EnduringStockPileGeigerHud")
			TRad = TRad + (math.random(10,20)/10000000)
			local milirads = math.Round(TRad*1000,2)
			local microrads = math.Round(TRad*1000000,2)
			if milirads < 1 and microrads > 2 then
				PANEL:DoESRads(microrads,"MICRORADS / MIN")
			elseif TRad < 1 and milirads > 0 then
				PANEL:DoESRads(milirads,"MILIRADS / MIN")
			elseif TRad >= 1 then
                PANEL:DoESRads(math.Round(TRad,2),"RADS / MIN")
            else
				PANEL:DoESRads(1.5,"MICRORADS / MIN")
			end
			PANEL:DoESDosi(ply:GetNetworkedInt("EnduringStockPileDosimeter"),ply:GetNetworkedInt("EnduringStockPileDosimeterAcc"),ply)
		end
	end
end)
