
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

math.randomseed(CurTime())
self.exploded = false
self.armed = true
self.ticking = true
self.smoking = false
self.flightvector = self.Entity:GetUp() * 250
self.Entity:SetModel( "models/combatmodels/tankshell.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3            

self.hit = Sound("weapons/physcannon/energy_sing_flyby1.wav")

self:Think()
 
end   

 function ENT:Think()


	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector
		trace.filter = self.Entity 
	local tr = util.TraceLine( trace )
	
	if (tr.Hit) then
		if ( self.exploded == false ) then
			local effectdata1 = EffectData()
			effectdata1:SetOrigin(tr.HitPos)
			effectdata1:SetStart(tr.HitPos)
			util.Effect( "ener_fail", effectdata1 )
			
			if ( self.exploded == false && self.ticking == true ) then
				self:EmitSound(self.hit, 100, 100)
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
				if (tr.Entity:IsWorld() || tr.Entity:IsPlayer() || tr.Entity:IsNPC()) then
					self.exploded = true
					self.Entity:Remove()
					return true
				end
 
    
				local attack = cbt_dealnrghit( tr.Entity, 200, 5, tr.HitPos , tr.HitPos)

				

				self.exploded = true
				self.Entity:Remove()
			end
		end
	end

	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
