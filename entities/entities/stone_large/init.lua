AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 80
	
	local ent = ents.Create( "stone_large" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	Factions.SortRocks()
	
	return ent
end

-----------------------------------------------------------
--  Name: Initialize
-----------------------------------------------------------
function ENT:Initialize()
	local i = math.random( 1, 4 )
	
	if i == 1 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff05a.mdl" )
	elseif i == 2 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff05b.mdl" )
	elseif i == 3 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff05e.mdl" )
	elseif i == 4 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff05f.mdl" )
	end
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMaxHealth(1000)
	self.Entity:SetHealth(1000)
	
	-- Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:SetMass(5000)
	end
	self.Entity:SetVar( "NotPhysable", true )
	self.value = 80
end

function ENT:Break()
	self.Entity:EmitSound("physics/concrete/concrete_break2.wav", 120, 100)
	for i = 1, math.Rand(4,5) do
		local stone = ents.Create("stone_medium")
		stone:SetPos(self.Entity:GetPos() + i * Vector(math.Rand(-70,70), math.Rand(-70,70), 1))

		stone:Spawn()
		stone:SetGravity( 0 )
		stone:Activate()
			
		stone:SetType( self.Entity.type )
			
		gamemode.Call( "Space_Affect", stone )
	end
	
	self:LotteryStone()
	self:MakeSmallStones( self.Entity )
	
	self.Entity:Remove()
end
