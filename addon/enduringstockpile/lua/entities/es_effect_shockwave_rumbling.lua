AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable		            	 =  false
ENT.AdminSpawnable		             =  false     

ENT.PrintName		                 =  ""        
ENT.Author			                 =  ""      
ENT.Contact			                 =  ""      

ENT.HBOWNER                          =  nil            
ENT.MAX_RANGE                        = 0
ENT.SHOCKWAVE_INCREMENT              = 0
ENT.DELAY                            = 0
ENT.SOUND                            = ""
function ENT:Initialize()
     if (SERVER) then
		 self.FILTER                           = {}
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 5000
		 self.HBOWNER = self:GetVar("HBOWNER")
     end
end

function ENT:Think(ply)

			
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+self.SHOCKWAVE_INCREMENT
	 for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
		 if v:IsValid() or v:IsPlayer() then
			 local i = 0
			 while i < v:GetPhysicsObjectCount() do
				 if (v:IsPlayer()) then
					 if !(table.HasValue(self.FILTER,v:SteamID())) then
						net.Start("hb_net_sound_lowsh")
							net.WriteString("gbombs_5/explosions/nuclear/nuke_rumbling.mp3")
						net.Send(v)
						table.insert(self.FILTER, v:SteamID() )
					 end
				 end

			 i = i + 1
			 end
		 end
 	 end
	 self.Bursts = self.Bursts + 1
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + self.DELAY)
	 return true
	 end
end

function ENT:Draw()
     return false
end