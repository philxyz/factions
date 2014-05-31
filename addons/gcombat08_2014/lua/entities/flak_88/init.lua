
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
	self.distance = 10000
	self.Entity:SetModel( "models/combatmodels/tank_gun.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(Color(100,40,255,255))

	self.val1 = 0
	self.val2 = 0
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	phys:SetMass( 3 ) 
	end 
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" , "Distance" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "FLAK_88" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:fireAPshell()
	if (self.ammos > 0) then
		local pos = self.Entity:GetPos()
		
		
		local trace = {}
		trace.start = self.Entity:GetPos() + self.Entity:GetUp() * 50
		trace.endpos = self.Entity:GetPos() + self.Entity:GetUp() * self.distance
		trace.filter = self.Entity 
		local tr = util.TraceLine( trace ) 
		
		if (tr.Hit && tr.Entity:IsValid()) then
			if ( !tr.Entity:IsWorld() || !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() || !tr.Entity:IsVehicle()) then
				local attack = cbt_dealhcghit( tr.Entity, 50, tr.HitNormal:Dot(self.Entity:GetUp() * -1) * 12, tr.HitPos, 		tr.HitPos)
			end
		end
	
		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 200, 50)
		
		cbt_hcgexplode( tr.HitPos, 50, 20, 2)
		
		self.reloadtime = CurTime() + 0.3
		
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
		util.Effect( "flakbeam", effectdata )
	
	end
end

function ENT:Think()

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
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
		self.shelltype = 1
		self.Entity:NextThink( CurTime() )
		return true
	end
	
	if (iname == "Distance") then
		self.distance = value
	end
	
end
 
 
