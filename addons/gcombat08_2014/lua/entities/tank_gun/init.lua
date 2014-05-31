
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   
	
	math.randomseed(CurTime())
	self.ammomodel = "models/props_c17/canister01a.mdl"
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
	self.clip = 100
	
	self.expl = {}
	self.expl[1] = "weapons/explode3.wav"
	self.expl[2] = "weapons/explode4.wav"
	self.expl[3] = "weapons/explode5.wav"
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
		phys:SetMass( 20 ) 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire AP round" , "Fire HE round" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "tank_gun" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:fireAPshell()
	
	if (self.ammos > 0) then
		local ent = ents.Create( "tankshell" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 60)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.armed = false
		self.reloadtime = CurTime() + 10
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:AddVelocity( self:GetUp() * -800 ) 
		end
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
		effectdata:SetNormal( self:GetUp() )
		util.Effect( "cannon_flare", effectdata )
		self:EmitSound(self.expl[ math.random(1,3) ] , 160, 130 ) 
	end
	
end

function ENT:fireHEshell()

	if (self.ammos > 0) then
		local ent = ents.Create( "hetankshell" )
		ent:SetPos( self.Entity:GetPos() +  self.Entity:GetUp() * 60)
		ent:SetAngles( self.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		self.armed = false
		self.reloadtime = CurTime() + 10
		
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:AddVelocity( self:GetUp() * -800 ) 
		end
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
		effectdata:SetNormal( self:GetUp() )
		util.Effect( "cannon_flare", effectdata )
		self:EmitSound(self.expl[ math.random(1,3) ] , 160, 130 )
	end

end

function ENT:Think()
	
	if (self.reloadtime > CurTime()) then
		self.armed = false
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if (self.armed == true) then
		if (self.clip >= 100) then
			if (self.shelltype == 1) then
				self:fireAPshell()
			else
				self:fireHEshell()
			end
		end
	elseif (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
		if (self.infire == true) then self.armed = true end
	end

end

function ENT:TriggerInput(iname, value)

	if (iname == "Fire AP round") then
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
		self.shelltype = 1
		self.Entity:NextThink( CurTime() )
		return true
	end

	if (iname == "Fire HE round") then
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
		self.Entity:NextThink( CurTime() )
		self.shelltype = 2
		return true
	end

end
 
 
