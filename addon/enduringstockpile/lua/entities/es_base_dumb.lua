AddCSLuaFile()
DEFINE_BASECLASS( "base_anim" )

util.PrecacheSound( "BaseExplosionEffect.Sound" ) 

--[[
This is a base for vegetable entities which are not affected by bullets and shit.
OMFG STOP READING THIS!
--]]

local ExploSnds = {}
ExploSnds[1]                         =  "BaseExplosionEffect.Sound"

local Models = {}
Models[1]                            =  "model"

local damagesound                    =  "weapons/rpg/shotdown.wav"

ENT.Spawnable		            	 =  false         
ENT.AdminSpawnable		             =  false         

ENT.PrintName		                 =  "Name"       
ENT.Author			                 =  "Avatar natsu"     
ENT.Contact			                 =  "GTFO" 
ENT.Category                         =  "GTFO!"           

ENT.Model                            =  ""            
ENT.Life                             =  20       
ENT.Mass                             =  0
ENT.HBOWNER                          =  nil             -- don't you fucking touch this.

ENT.DEFAULT_PHYSFORCE  = 0
ENT.DEFAULT_PHYSFORCE_PLYAIR  = 0
ENT.DEFAULT_PHYSFORCE_PLYGROUND = 0

function ENT:Initialize()
 if (SERVER) then
     self:LoadModel()
	 self:PhysicsInit( SOLID_VPHYSICS )
	 self:SetSolid( SOLID_VPHYSICS )
	 self:SetMoveType( MOVETYPE_VPHYSICS )
	 self:SetUseType( ONOFF_USE ) -- doesen't fucking work
	 local phys = self:GetPhysicsObject()
	 local skincount = self:SkinCount()
	 if (phys:IsValid()) then
		 phys:SetMass(self.Mass)
         phys:SetBuoyancyRatio(0)
		 phys:Wake()
         
     end
	 if (skincount > 0) then
	     self:SetSkin(math.random(0,skincount))
	 end
	 self.Exploded = false
	end
end

function ENT:LoadModel()
     if self.UseRandomModels then
	     self:SetModel(table.Random(Models))
	 else
	     self:SetModel(self.Model)
	 end
end

function ENT:Explode()
end

function ENT:OnTakeDamage(dmginfo)
     self:TakePhysicsDamage(dmginfo)
end

function ENT:PhysicsCollide( data, physobj )
end

function ENT:OnRemove()
	 self:StopParticles()
end

if ( CLIENT ) then
     function ENT:Draw()
         self:DrawModel()
     end
end
