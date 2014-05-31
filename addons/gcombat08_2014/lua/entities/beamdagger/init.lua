
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
	self.Entity:SetModel( "models/props_c17/metalPot001a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(Color(40,40,40,255))

          
	
	
	self.Inputs = Wire_CreateInputs( self.Entity, { "Sword" } )
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "beamdagger" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:fireAPshell()

		local pos = self.Entity:GetPos()
		
		local physo = self.Entity:GetPhysicsObject()
		
		local trace = {}
		trace.start = self.Entity:GetPos() + self.Entity:GetUp() * 5
		trace.endpos = self.Entity:GetPos() + self.Entity:GetUp() * 160
		trace.filter = self.Entity 
		local tr = util.TraceLine( trace ) 
		
		if (tr.Hit && tr.Entity:IsValid()) then
			if ( !tr.Entity:IsWorld() || !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() || !tr.Entity:IsVehicle()) then
				local damagemod = (physo:GetVelocity():Length() * physo:GetAngleVelocity():Length()) / 100
				local attack = cbt_dealnrghit( tr.Entity, 10 + damagemod, 12, tr.HitPos,tr.HitPos)
			end
		end
	
		

		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 5)
		util.Effect( "sword_ray", effectdata )
		

end

function ENT:Think()

		if (self.infire == true) then self:fireAPshell() end
	
	self.Entity:NextThink( CurTime())
	return true

end

function ENT:TriggerInput(iname, value)

	if (iname == "Sword") then
		if (value == 1 && self.infire == false) then self.infire = true end
		if (value == 0 && self.infire == true) then self.infire = false end
		self.Entity:NextThink( CurTime() )
		return true
	end
	
end
 
 
