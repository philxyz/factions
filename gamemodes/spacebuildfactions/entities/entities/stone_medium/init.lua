AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 80
	
	local ent = ents.Create( "stone_medium" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()

	local i = math.random( 1, 3 )
	
	if i == 1 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff07b.mdl" )
	elseif i == 2 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff06d.mdl" )
	elseif i == 3 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff06i.mdl" )
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
		phys:SetMass(4000)
	end
	self.Entity:SetVar( "NotPhysable", true )
	self.value = 20
end

function ENT:Break()
	self.Entity:EmitSound("physics/concrete/concrete_break2.wav", 120, 100)
	local borders = Factions.GetEntBorders( self.Entity )
	for i = 1, math.Rand(20,25) do
		
		local stone = ents.Create("stone_small")
		stone:SetPos( Vector( math.Rand(borders.x[1], borders.x[2]), math.Rand(borders.y[1], borders.y[2]), math.Rand(borders.z[1], borders.z[2]) ) )

		stone:Spawn()
		stone:SetGravity( 0 )
		stone:Activate()
			
		stone:SetType( self.Entity.type )
			
		gamemode.Call( "Space_Affect", stone )
	end
	
	self:LotteryStone()
	
	self.Entity:Remove()
end
