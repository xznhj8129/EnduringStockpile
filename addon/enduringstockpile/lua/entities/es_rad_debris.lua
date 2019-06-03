AddCSLuaFile()

DEFINE_BASECLASS( "es_base_dumb" )

ENT.Spawnable			             =  true
ENT.AdminSpawnable		             =  true

ENT.PrintName		                 =  "Radioactive debris"
ENT.Author			                 =  "snowfrog"
ENT.Category                         =  "EnduringStockpile"
ENT.Model                            =  ""

ENT.RadRadius                        =  10000
ENT.Mass                             =  100
ENT.RadPower                         =  1000

ENT.GBOWNER                          =  nil             -- don't you fucking touch this.

function ENT:Initialize()
 if (SERVER) then
     local modellist = {"models/props_debris/concrete_spawnchunk001c.mdl",
                        "models/props_debris/concrete_spawnchunk001d.mdl",
                        "models/props_debris/concrete_spawnchunk001e.mdl",
                        "models/props_debris/concrete_spawnchunk001f.mdl",
                        "models/props_debris/concrete_spawnchunk001g.mdl",
                        "models/props_debris/concrete_spawnchunk001h.mdl",
                        "models/props_debris/concrete_spawnchunk001i.mdl",
                        "models/props_debris/concrete_spawnchunk001j.mdl",
                        "models/props_debris/concrete_spawnchunk001k.mdl"}
    self:SetModel( modellist[math.random(9)] )
    self:LoadModel()
    self:PhysicsInit( SOLID_VPHYSICS )
    self:SetSolid( SOLID_VPHYSICS )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:SetUseType( ONOFF_USE ) -- doesen't fucking work
    self.EntList={}
    self.EntCount = 0
    local phys = self:GetPhysicsObject()
    local skincount = self:SkinCount()
    if (phys:IsValid()) then
     phys:SetMass(self.Mass)
     phys:Wake()
    end
 end
end

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
                if dist<self.RadRadius then
                    local raddose = self.RadPower * inversesquare(dist)
                    v.RadCount = v.RadCount + raddose
                end
            end
        end
        
        for _, ply in pairs( player.GetAll() ) do
            local dist = (self:GetPos() - ply:GetPos()):Length()
            if dist<self.RadRadius and ply:IsPlayer() and ply:Alive() and ply:IsLineOfSightClear(self) then
                local dist = (self:GetPos() - ply:GetPos()):Length()
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
                local raddose = self.RadPower * inversesquare(dist)
                local exposure = raddose/60
                addRads(v,exposure)
            end
        end
        
        self:NextThink(CurTime() + 0.25)
        return true
    end
end
