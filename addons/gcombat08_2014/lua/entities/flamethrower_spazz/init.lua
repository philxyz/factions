AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

self.exploded = false
self.Entity:SetModel( "models/weapons/w_bugbait.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetColor(Color(0,0,0,0))

self.hasdamagecase = true

self.Target = self.Target or self.Entity

if self.Target == self.Entity then
local cooker = ents.Create("point_hurt")
cooker:SetPos(self.Entity:GetPos())
cooker:SetKeyValue("TargetName", "Flamethrower")
cooker:SetKeyValue("DamageRadius", 150)
cooker:SetKeyValue("Damage", 10)
cooker:SetKeyValue("DamageDelay", 0.1)
cooker:SetKeyValue("DamageType", 8)
cooker:Spawn()
cooker:Fire("turnon","",0)
cooker:SetParent(self.Entity)
else
	self:SetParent( self.Target )
	self:GetPhysicsObject():EnableCollisions( false )
end
end   

function ENT:gcbt_breakactions(damage, pierce)
--invulnerable
end

 function ENT:Think()
 if self.Target != self.Entity then  cbt_dealhcghit( self.Target, 30, 12, self:GetPos(), self:GetPos()) end
	if self.DieTime < CurTime() then self:Remove() end
end
 
 
