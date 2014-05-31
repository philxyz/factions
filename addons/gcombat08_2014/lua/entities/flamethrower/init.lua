
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   
	
	self.ammos = 6
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.shelltype = 42
	
	self.infire = false
	self.Entity:SetModel( "models/combatmodels/tank_gun.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(Color(255,0,0,255))

	self.val1 = 0
	self.val2 = 0
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	phys:SetMass( 3 ) 
	end 
	
	self:SetNetworkedBool( "fire", false)
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "flamethrower" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:fireAPshell()
	if (self.ammos > 0) then
		local pos = self.Entity:GetPos()
		
		local speed = self:GetVelocity():Length()
		
		local trace = {}
		trace.start = self.Entity:GetPos() + self.Entity:GetUp() * 50
		trace.endpos = self.Entity:GetPos() + self.Entity:GetUp() * 2000 * math.Clamp((1 - (speed - 500)), 0.1, 1)
		trace.filter = self.Entity 
		local tr = util.TraceLine( trace ) 
		
		local massivecheck = ( !tr.Entity:IsWorld() || !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() || !tr.Entity:IsVehicle())
		
		local ent = self.Entity
		
		if tr.Hit then
			ent = ents.Create( "flamethrower_spazz" )
				ent:SetPos( tr.HitPos + tr.HitNormal * 8)
				ent.DieTime = CurTime() + 3 * (1 - tr.Fraction)
				
		end
		
		if (tr.Hit && tr.Entity:IsValid()) then
		
			if massivecheck then
				local attack = cbt_dealhcghit( tr.Entity, 20 * (1 - tr.Fraction), 4, tr.HitPos, 		tr.HitPos)
					if attack == 1 && ent != self.Entity then
						ent.Target = tr.Entity
					end
			end
		end
		if ent != self.Entity then
			ent:Spawn()
			ent:Activate()
			ent:GetPhysicsObject():Wake()
			ent:GetPhysicsObject():AddVelocity( self:GetUp() * 10000 + VectorRand() * 6000)
		end
		
		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, tr.Fraction * 100, 50)
		
		self.reloadtime = CurTime() + 0.1
	
	end
end

function ENT:Think()
	if !self.infire then self.armed = false end
	if (self.reloadtime > CurTime()) then
		self.armed = false
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if (self.armed == true) then
			self:fireAPshell()
	elseif (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
		if (self.infire == true) then self.armed = true end
	end
	
end

function ENT:TriggerInput(iname, value)

	if (iname == "Fire") then
		if (value == 1 && self.infire == false) then self.infire = true; self:SetNetworkedBool( "fire", true) end
		if (value == 0 && self.infire == true) then self.infire = false; self:SetNetworkedBool( "fire", false) end
		self.shelltype = 1
		self.Entity:NextThink( CurTime() )
		return true
	end
	
end
 
 
