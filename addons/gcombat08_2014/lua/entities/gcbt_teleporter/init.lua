AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

function ENT:Initialize()

	self.hasdamagecase = true
	
	self.Entity:SetModel( "models/props_combine/combine_emitter01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.link = self.Entity
	
	self:SetNetworkedBool( "hasport", false )
	
end

function ENT:LinkPorter( ent , dometoo )
	if self:GetClass() == ent:GetClass() then
		if dometoo then ent:LinkPorter( self.Entity , false )end
		self.link = ent
		self:SetNetworkedBool( "hasport", true )
	end
end

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gcbt_teleporter" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:Touch( hitEnt ) 
	if self:GetClass() == hitEnt:GetClass() then self:LinkPorter( hitEnt ) end
end

function ENT:gcbt_breakactions(damage, pierce)
	//I nvulnerable
end

function ENT:Think()
	if self.link == self.Entity then return end
	
	local pos = self:GetPos()
	
	local targetangle = self.link:GetAngles()
	
	
	local llist = ents.FindInSphere( self:GetPos(), 100)
	
	for _,p in pairs(llist) do
		if p:IsPlayer() then 
			if (pos - p:GetPos()):GetNormalized():DotProduct(self:GetForward()) < -0.6 && p:GetVelocity():DotProduct( self:GetForward() ) < 0 then
				local effectdata = EffectData()
					effectdata:SetOrigin(p:GetPos() + Vector(0, 0, 30))
				util.Effect( "teleporter_magic", effectdata )
				
				local pspeed = p:GetVelocity():Length()
				
				p:SnapEyeAngles(Angle( targetangle.p, targetangle.y, 0))
				p:SetPos(self.link:GetPos() + (self.link:GetForward() * 120) + (self.link:GetUp() * 10))
				p:SetVelocity( (self.link:GetForward() * pspeed) - p:GetVelocity())
				
				effectdata = EffectData()
					effectdata:SetOrigin(p:GetPos() + Vector(0, 0, 30))
				util.Effect( "teleporter_magic", effectdata )
			end
		end
	end
	
	self:NextThink(CurTime() + 0.1)
	return true
end



