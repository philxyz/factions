
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

self.exploded = false
self.armed = true

self.flightvector = self.Entity:GetUp() * 100
self.Entity:SetModel( "models/combatmodels/tankshell.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3           
self.Entity:SetColor(Color(0,255,0,255))

self:Think()
 
end   

 function ENT:Think()
	
	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector * 3 
		trace.filter = self.Entity 
	local tr = util.TraceLine( trace )
	
	if (tr.Hit && !tr.HitSky) then
		if ( self.exploded == false ) then
			util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 100)
	
			local effectdata = EffectData()
			effectdata:SetOrigin(self.Entity:GetPos())
			effectdata:SetStart(self.Entity:GetPos())
			util.Effect( "big_splosion", effectdata )
			self.exploded = true
			self.Entity:Remove()
			return true
		end
	end
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(0,0,-1)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
