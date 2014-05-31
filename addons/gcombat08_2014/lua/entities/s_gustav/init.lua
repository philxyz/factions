
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
	self.Entity:SetModel( "models/combatmodels/s_gustav.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	
	self.val1 = 0
	self.val2 = 0
	RD_AddResource(self.Entity, "Munitions", 0)
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
		phys:SetMass(20000)
	end 
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" , "Shots Remaining" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "s_gustav" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:fireAPshell()

	if (self.ammos > 0) then
		local ent = ents.Create( "gustav_shell" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 1870)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:setstuff( 200, 7)
		ent:Spawn()
		ent:Activate()
		self.armed = false
		self.reloadtime = CurTime() + 10
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:SetVelocity( self.Entity:GetUp() * -10000 ) 
		end 

		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 1870)
		effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 1870)
		util.Effect( "Explosion", effectdata )
		
	end

end

function ENT:Think()

	local ammo = RD_GetResourceAmount(self, "Munitions")
	local remain = math.Round(ammo / 4000)
	Wire_TriggerOutput(self.Entity, "Shots Remaining", remain)
	
	if (self.reloadtime > CurTime()) then
		self.armed = false
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end

	if (self.armed == true) then
		if (ammo >= 4000) then
			if (self.shelltype == 1) then
				self:fireAPshell()
			else
				self:fireHEshell()
			end
		RD_ConsumeResource(self, "Munitions", 4000)
		end
	elseif (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
		if (self.infire == true) then self.armed = true end
	end

end

function ENT:TriggerInput(iname, value)

	if (iname == "Fire") then
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
		self.shelltype = 1
		self.Entity:NextThink( CurTime() )
		return true
	end

end
 
 
