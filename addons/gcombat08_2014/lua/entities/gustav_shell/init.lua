
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

	self.exploded = false
	self.armed = true
	self.smoking = false
	self.flightvector = self.Entity:GetUp() * 200
	self.Entity:SetModel( "models/combatmodels/gshell.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3
 
end   


 function ENT:Think()
	
	local pos = self.Entity:GetPos()
	local trace = {}
	trace.start = self.Entity:GetPos()
	trace.endpos = self.Entity:GetPos() + self.flightvector * 3 
	trace.filter = self.Entity 
	local tr = util.TraceLine( trace ) 
	
	if (tr.Hit && !tr.HitSky) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "Explosion", effectdata )
		util.Effect( "gustav_impact", effectdata )
		
		if (tr.Entity:IsValid()) then
			local attack = cbt_dealhcghit( tr.Entity, 10000, 100, self.Entity:GetPos() , self.Entity:GetPos())
			if (attack == 0) then
				brokedshell = ents.Create("prop_physics")
				brokedshell:SetPos(self.Entity:GetPos())
				brokedshell:SetAngles(self.Entity:GetAngles())
				brokedshell:SetModel( "models/combatmodels/gshell.mdl" )
				brokedshell:PhysicsInit( SOLID_VPHYSICS )
				brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
				brokedshell:SetSolid( SOLID_VPHYSICS )
				brokedshell:Activate()
				brokedshell:Spawn()
				brokedshell:Fire("Kill", "", 20)
				local phys = brokedshell:GetPhysicsObject()  	
				if (phys:IsValid()) then  
					phys:SetVelocity( self.Entity:GetPhysicsObject():GetVelocity())
				end
			end
		end

 

		self.exploded = true
		self.Entity:Remove()
	end
 		
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(0,0,-1)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
