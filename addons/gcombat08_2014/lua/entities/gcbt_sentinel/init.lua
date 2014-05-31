AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

local shootsound = Sound( "Weapon_AR2.Single" )

function ENT:Initialize()

	
	self.hasdamagecase = true
	
	
	self.Entity:SetModel( "models/props_combine/combine_emitter01.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys1 = self:GetPhysicsObject()
	if phys1:IsValid() then
		phys1:Wake()
		phys1:SetMass( 100 )
	end

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "sentry_gun" )
		ent:SetPos( SpawnPos )
		ent:SetOwner(ply)
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:gcbt_breakactions(damage, pierce)
	self.hasdamagecase = false
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		util.Effect( "sapper_explosion", effectdata )
		cbt_hcgexplode( self.Entity:GetPos(), 75, 200, 2)
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 400, 100)
		self.Entity:Remove()
end

function ENT:Think()
	
	local targets = diplomacy.GetAligned(self:GetOwner(), -1) 
	local fnl = {}
	
	--if #targets == 0 then fnl = ents.FindByClass( "npc_combine_s" ) else fnl = targets end
	
	fnl = ents.FindByClass( "npc_combine_s" ) 
	
	self.target = self.Entity
	local distance = 3000
	local pos = self:GetPos()
	for _,b in pairs(fnl) do
		dst = pos:Distance(b:GetPos())
		if dst < distance then
			self.target = b
			distance = dst
		end
	end
	
	if self.target == self.Entity then
		self:NextThink( CurTime()+1)
		return true 
	end
	
	local normal = ((self.target:GetPos() + Vector(0, 0, 40)) - self:GetPos())
	
	if normal:DotProduct(self:GetForward()) > 0.2 then 
		
		local shootOrigin = self.Entity:GetPos() + self.Entity:GetForward() * 10 + self.Entity:GetUp() * 20
		
		local bullet = {}
			bullet.Num 			= 1
			bullet.Src 			= shootOrigin
			bullet.Dir 			= normal
			bullet.Spread 		= Vector(0.2,0.2, 0)
			bullet.Tracer		= 1
			bullet.TracerName 	= "AirboatGunHeavyTracer"
			bullet.Force		= 100
			bullet.Damage		= 10
			bullet.Attacker 	= ply
		self:FireBullets( bullet )
		self:EmitSound( shootsound )
		self:NextThink( CurTime()+0.1)
		return true
	end
end



