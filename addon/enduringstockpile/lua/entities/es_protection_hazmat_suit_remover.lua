AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.PrintName		= "Hazmat Suit Remover"
ENT.Author		    = ""
ENT.Information		= ""
ENT.Category		= "EnduringStockpile"

ENT.Editable		= false
ENT.Spawnable		= true
ENT.AdminOnly		= true
ENT.Contact			                 =  ""  

function ENT:SpawnFunction( ply, tr )
	if ( not tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	local ent = ents.Create( "hazmat_suit_remover" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

if SERVER then
	function ENT:Initialize()
		self.Entity:SetModel("models/Items/item_item_crate.mdl")
		self.Entity:PhysicsInit( SOLID_VPHYSICS )
		self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		local phys = self.Entity:GetPhysicsObject()
		if (phys:IsValid()) then	
			phys:Wake()
		end	
		
		local ent = ents.Create( "prop_physics" )
		local offset = self:GetPos() -7 * self:GetForward()
		ent:SetModel("models/thedoctor/signs/rad02.mdl")
		ent:SetPos( Vector(offset.x,offset.y,offset.z-35))
		ent:SetAngles(Angle(0,180,0))
		ent:Spawn()
		ent:Activate()
		ent:SetParent( self ) 
		
		local ent = ents.Create( "prop_physics" )
		ent:SetModel("models/Items/hevsuit.mdl")
		ent:SetPos( Vector(self:GetPos().x,self:GetPos().y,self:GetPos().z+24 ))
		ent:Spawn()
		ent:Activate()
		ent:SetParent( self ) 
		
	end
end

if SERVER then
	function ENT:Use( activator, caller )
		if activator.hazsuited==true then	
			activator:EmitSound("gbombs_5/protection_used.wav",50,190)
			activator.hazsuited=true
			activator:SetRunSpeed(500)
			activator:SetWalkSpeed(250)
			net.Start( "gbombs5_net" )        
				net.WriteBit( false )
				activator:StopSound("breathing")				
			net.Send(activator)
			activator.hazsuited=false
			
			self:Remove()
		end
	end
end

if CLIENT then
	function ENT:OnRemove()
		net.Receive( "gbombs5_net", function( len )
			local mask_on = net.ReadBit()
			if mask_on==1 then
				hook.Add( "RenderScreenspaceEffects", "GasMask", GasMask)
			else
				hook.Remove("RenderScreenspaceEffects", "GasMask", GasMask)
			end
		end)
    end
end



if CLIENT then
	function ENT:Draw()
		self.Entity:DrawModel()
		local squad = self:GetNetworkedString( 12 )
		if ( LocalPlayer():GetEyeTrace().Entity == self.Entity and EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), ( "Hazmat Suit Remover" ), 0.5, self.Entity:GetPos(), self.Entity  )
		end
	end
	language.Add( 'Hazmat Suit Remover', 'Hazmat Suit Remover' )
end


