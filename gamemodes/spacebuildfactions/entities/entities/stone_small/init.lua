AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "stone_small" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()

	local i = math.random( 1, 4 )
	
	if i == 1 then
		self.Entity:SetModel( "models/props_wasteland/rockgranite03a.mdl" )
	elseif i == 2 then
		self.Entity:SetModel( "models/props_wasteland/rockgranite03b.mdl" )
	elseif i == 3 then
		self.Entity:SetModel( "models/props_wasteland/rockgranite03c.mdl" )
	elseif i == 4 then
		self.Entity:SetModel( "models/props_wasteland/rockgranite03a.mdl" )
	end
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMaxHealth(800)
	self.Entity:SetHealth(800)
	
	-- Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:SetMass(100)
	end
	self.Entity:SetVar( "NotPhysable", true )
	self.value = 1
	
	self.SmallRockRemovalTimer = CurTime() + Factions.Config.RockRemovalTimer
end

function ENT:Break()
end
