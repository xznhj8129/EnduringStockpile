AddCSLuaFile()
local PANEL = {}
local function convclr( color ) return color.r, color.g, color.b, color.a; end

function PANEL:DoESRads(Rads,xperx)
	--print("hey fucktard")
	local dcol
	local yel=255
	if xperx=="RADS/MIN" then --fancy color change, ooOOoO
		yel=100/(math.Clamp(Rads,0,500))*255
		dcol=Color(255,yel,0,255)
	else 
		dcol=Color(0,255,0,255)
	end
	if yel<=70 then
		draw.SimpleText("CAUTION","HudSelectionText",185,870,dcol,0,0) --if there was a font that had a skull and crossbones, i absolutely would have used it here
	end
	draw.RoundedBox(6,35,865,230,75,Color(0,0,0,70))
	draw.SimpleText(Rads,"HudNumbers",55,880,dcol,0,0)
	draw.SimpleText(xperx,"HudSelectionText",55,910,dcol,0,0)
end

function PANEL:DoESDosi(Total,Acc,ply)
	draw.RoundedBox(6,315,865,240,75,Color(0,0,0,70))
	draw.SimpleText(tostring(math.Round(Acc,2)).." / "..tostring(math.Round(Total,2)),"HudNumbers",330,880,Color(0,255,0,255),0,0)
	draw.SimpleText("DOSE - CURRENT / TOTAL","HudSelectionText",330,910,Color(0,255,0,255),0,0)

end

hook.Add( "HUDPaint", "HUDPaint_EsRadCounter", function()
	for _, ply in pairs( player.GetAll() ) do
		if ply:GetNetworkedInt("EnduringStockPileDoHud") then
            local TRad=ply:GetNetworkedInt("EnduringStockPileGeigerHud")
			TRad = TRad + (math.random(10,20)/10000000)
			local milirads = math.Round(TRad*1000,2)
			local microrads = math.Round(TRad*1000000,2)
			if milirads < 1 and microrads > 2 then
				PANEL:DoESRads(microrads,"MICRORADS/MIN")
			elseif TRad < 1 and milirads > 0 then
				PANEL:DoESRads(milirads,"MILIRADS/MIN")
			elseif TRad >= 1 then
                PANEL:DoESRads(math.Round(TRad,2),"RADS/MIN")
            else
				PANEL:DoESRads(1.5,"MICRORADS/MIN")
			end
			PANEL:DoESDosi(ply:GetNetworkedInt("EnduringStockPileDosimeter"),ply:GetNetworkedInt("EnduringStockPileDosimeterAcc"),ply)
		end
	end
end)
