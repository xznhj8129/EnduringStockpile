AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )


ENT.Spawnable                         =  false
ENT.AdminSpawnable                    =  false

ENT.PrintName                         =  "Radioactive Crater"
ENT.Author                            =  "snowfrog"
ENT.Contact                           =  ""

function ENT:Initialize()
    if (SERVER) then
        self:SetModel("models/props_junk/watermelon01_chunk02c.mdl")
        self:SetSolid( SOLID_NONE )
        self:SetMoveType( MOVETYPE_NONE )
        self:SetUseType( ONOFF_USE ) 
        self.Bursts = 0
        self.HBOWNER = self:GetVar("HBOWNER")
        self.RadRadius = self:GetVar("Rad_Radius")
        if self.RadRadius==nil then
           self.RadRadius=500
        end
    end
end

-- crater entity
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
                -- tracer to find how far entity is from ground
                local tracedata2    = {}
                tracedata2.start    = v:GetPos() + Vector(0,0,0)
                tracedata2.endpos   = tracedata2.start - Vector(0, 0, 2000)
                tracedata2.filter   = self.Entity
                --tracedata2.mask     = MASK_WATER + CONTENTS_TRANSLUCENT
                local trace2 = util.TraceLine(tracedata2)
                self.TraceHitPos = trace2.HitPos
                local v_dist = v:GetPos():Distance(trace2.HitPos)
                if v_dist<2000 then
                    if v_dist<10 then v_dist = 0 end
                    local dist = (self:GetPos() - v:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    local v_dist_modifier = math.Clamp((2000-v_dist) / v_dist, 0, 1)
                    time_modifier = math.pow(((400*falloutlen)-self.Bursts) / (400*falloutlen), 6)
                    local raddose = (10000 * dist_modifier * time_modifier * v_dist_modifier)
                    v.RadCount = v.RadCount + raddose
                end
            end
        end
        
        for _, ply in pairs( player.GetAll() ) do
            local dist = (self:GetPos() - ply:GetPos()):Length()
            if dist<self.RadRadius and ply:IsPlayer() and ply:Alive() then
                -- tracer to find how far entity is from ground
                local tracedata2    = {}
                tracedata2.start    = ply:GetPos() + Vector(0,0,0)
                tracedata2.endpos   = tracedata2.start - Vector(0, 0, 2000)
                tracedata2.filter   = self.Entity
                --tracedata2.mask     = MASK_WATER + CONTENTS_TRANSLUCENT
                local trace2 = util.TraceLine(tracedata2)
                self.TraceHitPos = trace2.HitPos
                local v_dist = ply:GetPos():Distance(trace2.HitPos)
                if v_dist<2000 then
                    if v_dist<10 then v_dist = 0 end
                    --PrintMessage( HUD_PRINTCONSOLE, "Tracedist: "..v_dist)
                    local dist = (self:GetPos() - ply:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    local v_dist_modifier = math.Clamp((2000-v_dist) / v_dist, 0, 1)
                    time_modifier = math.pow(((400*falloutlen)-self.Bursts) / (400*falloutlen), 6)
                    local raddose = (10000 * dist_modifier * time_modifier * v_dist_modifier)
                    local exposure = raddose/60
                    --PrintMessage( HUD_PRINTCONSOLE, "RD "..raddose )
                    addGeigerRads(ply,raddose)
                    addRads(ply,exposure)
                end
            end
        end
        
        for _, v in pairs( ents.FindByClass("npc_*") ) do
            local dist = (self:GetPos() - v:GetPos()):Length()
            if dist<self.RadRadius and v:IsNPC() and v:Health()>0 then
                -- tracer to find how far entity is from ground
                local tracedata2    = {}
                tracedata2.start    = v:GetPos() + Vector(0,0,0)
                tracedata2.endpos   = tracedata2.start - Vector(0, 0, 2000)
                tracedata2.filter   = self.Entity
                --tracedata2.mask     = MASK_WATER + CONTENTS_TRANSLUCENT
                local trace2 = util.TraceLine(tracedata2)
                self.TraceHitPos = trace2.HitPos
                local v_dist = v:GetPos():Distance(trace2.HitPos)
                if v_dist<2000 then
                    if v_dist<10 then v_dist = 0 end
                    local dist = (self:GetPos() - v:GetPos()):Length()
                    local dist_modifier = math.Clamp((self.RadRadius - dist) / self.RadRadius, 0, 1)
                    local v_dist_modifier = math.Clamp((2000-v_dist) / v_dist, 0, 1)
                    time_modifier = math.pow(((400*falloutlen)-self.Bursts) / (400*falloutlen), 6)
                    local raddose = (10000 * dist_modifier * time_modifier * v_dist_modifier)
                    local exposure = raddose/60
                    addRads(v,exposure)
                end
            end
        end
        
        self.Bursts = self.Bursts + 0.25
        if (self.Bursts >= (300*falloutlen)) then
            self:Remove()
        end
        self:NextThink(CurTime() + 0.25)
        return true
    end
end

function ENT:Draw()
    return true
end
