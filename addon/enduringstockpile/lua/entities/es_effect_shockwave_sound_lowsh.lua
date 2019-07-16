AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

if (SERVER) then
	util.AddNetworkString( "hb_net_sound_lowsh" )
end

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

net.Receive( "hb_net_sound_lowsh", function( len, pl )
	--print("Test, if you see this it SHOULD BE WORKING - Cat")
	local sound = net.ReadString()
	LocalPlayer():EmitSound(sound, 100, 100, 1)
	
end );

function ENT:Initialize()
     if (SERVER) then
		 self.FILTER                           = {}
         self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
	     self:SetSolid( SOLID_NONE )
	     self:SetMoveType( MOVETYPE_NONE )
	     self:SetUseType( ONOFF_USE ) 
		 self.Bursts = 0
		 self.CURRENTRANGE = 0
		 self.HBOWNER = self:GetVar("HBOWNER")
		 self.SOUND = self:GetVar("SOUND")
		 

     end
end

function ENT:Think()		
     if (SERVER) then
     if !self:IsValid() then return end
	 local pos = self:GetPos()
	 self.CURRENTRANGE = self.CURRENTRANGE+(self.SHOCKWAVE_INCREMENT*10)
	 if(GetConVar("hb_realistic_sound"):GetInt() >= 1) then
		 for k, v in pairs(ents.FindInSphere(pos,self.CURRENTRANGE)) do
			 if v:IsPlayer() then
				 if !(table.HasValue(self.FILTER,v)) then
					net.Start("hb_net_sound_lowsh")
						net.WriteString(self.SOUND)
					net.Send(v)
					v:SetNWString("sound", self.SOUND)
					if self:GetVar("Shocktime") == nil then
						self.shocktime = 1
					else
						self.shocktime = self:GetVar("Shocktime")
					end
					if GetConVar("hb_sound_shake"):GetInt()== 1 then
						util.ScreenShake( v:GetPos(), 5555, 555, self.shocktime, 500 )
					end
					table.insert(self.FILTER, v)
					
				 end
			 end
		 end
	 else
		if self:GetVar("Shocktime") == nil then
			self.shocktime = 1
		else
			self.shocktime = self:GetVar("Shocktime")
		end
	 	local ent = ents.Create("hb_shockwave_sound_instant")
		ent:SetPos( pos ) 
		ent:Spawn()
		ent:Activate()
		ent:SetPhysicsAttacker(ply)
		ent:SetVar("HBOWNER", self.HBOWNER)
		ent:SetVar("MAX_RANGE",50000)
		ent:SetVar("DELAY",0.01)
		ent:SetVar("Shocktime",self.shocktime)
		ent:SetVar("SOUND", self:GetVar("SOUND"))
		self:Remove()
	 end
	 self.Bursts = self.Bursts + 1
	 if (self.CURRENTRANGE >= self.MAX_RANGE) then
	     self:Remove()
	 end
	 self:NextThink(CurTime() + (self.DELAY*10))
	 return true
	 end
end
function ENT:OnRemove()
	if SERVER then
		if self.FILTER==nil then return end
		for k, v in pairs(self.FILTER) do
			if !v:IsValid() then return end
			v:SetNWBool("waiting", true)
		end
	end
end
function ENT:Draw()
     return false
end