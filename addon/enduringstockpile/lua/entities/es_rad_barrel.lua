AddCSLuaFile()

DEFINE_BASECLASS( "es_base_nuclearweapon" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Nuclear Waste Barrel"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"

ENT.Model                            =  "models/props/de_train/barrel.mdl"                     
ENT.Effect                           =  ""
ENT.EffectAir                        =  ""      
ENT.EffectWater                      =  "water_small"

ENT.ShouldUnweld                     =  false
ENT.ShouldIgnite                     =  false
ENT.ShouldExplodeOnImpact            =  false
ENT.Flamable                         =  false    
ENT.UseRandomSounds                  =  false
ENT.UseRandomModels                  =  false
ENT.Timed                            =  false

ENT.Bursts                           =  1
ENT.RadRadius                        =  1000
ENT.Mass                             =  200
ENT.RadPower                         =  2000

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.



function ENT:SpawnFunction( ply, tr )
     if ( not tr.Hit ) then return end
	 self.GBOWNER = ply
     local ent = ents.Create( self.ClassName )
	 ent:SetPhysicsAttacker(ply)
     ent:SetPos( tr.HitPos + tr.HitNormal * 16 ) 
     ent:Spawn()
     ent:Activate()

     return ent
end


function ENT:Think()
    
    if (SERVER) then
        if !self:IsValid() then return end
        local pos = self:GetPos()
        
        if falloutlen == nil then
            CreateConVar("es_falloutlength", "1", { FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_NOTIFY } )
        end
        
        local falloutlen = GetConVar("es_falloutlength"):GetInt()
        
        for _, v in pairs( ents.FindByModel("models/props_lab/powerbox02d.mdl")) do
            if v.GeigerCounter == 1 then
                local dist = (self:GetPos() - v:GetPos()):Length()
                --local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                --local raddose = math.Round((200 * dist_modifier))
                local raddose = self.RadPower * inversesquare(dist)
                v.RadCount = v.RadCount + raddose
            end
        end
        
        for _, ply in pairs( player.GetAll() ) do
            local dist = (self:GetPos() - ply:GetPos()):Length()
            if dist<self.RadRadius and ply:IsPlayer() and ply:Alive() and ply:IsLineOfSightClear(self) then
                local dist = (self:GetPos() - ply:GetPos()):Length()
                --local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                --local raddose = math.Round((200 * dist_modifier))
                local raddose = self.RadPower * inversesquare(dist)
                local exposure = raddose/60
                addGeigerRads(ply,raddose)
                addRads(ply,exposure)
            end
        end
        
        for _, v in pairs( ents.FindByClass("npc_*") ) do
            local dist = (self:GetPos() - v:GetPos()):Length()
            if dist<self.RadRadius and v:IsNPC() and v:Health()>0 and v:IsLineOfSightClear(self) then
                local dist = (self:GetPos() - v:GetPos()):Length()
                --local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                --local raddose = math.Round((200 * dist_modifier))
                local raddose = self.RadPower * inversesquare(dist)
                local exposure = raddose/60
                addRads(v,exposure)
            end
        end
        
        self:NextThink(CurTime() + 0.25)
        return true
    end
end
