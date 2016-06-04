AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 250
	
	local ent = ents.Create( "stone_huge" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end

function ENT:Initialize()
	local i = math.random( 1, 4 )
		
	if i == 1 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff_cluster01a.mdl" )
	elseif i == 2 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff_cluster01b.mdl" )
	elseif i == 3 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff_cluster02a.mdl" )
	elseif i == 4 then
		self.Entity:SetModel( "models/props_wasteland/rockcliff_cluster02b.mdl" )
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
		phys:SetMass(7000)
	end
	self.Entity:SetVar( "NotPhysable", true )
	self.value = 160
end

function ENT:Break()
	self.Entity:EmitSound("physics/concrete/concrete_break2.wav", 120, 100)
	
	local amt
	local pos
	if self.Entity:GetModel() == "models/props_wasteland/rockcliff_cluster01a.mdl" or self.Entity:GetModel() == "models/props_wasteland/rockcliff_cluster01b.mdl" then 
		amt = 3
		face = "forward"
		pos = self.Entity:GetPos() - (self.Entity:GetForward() * 600)
	else
		amt = 2
		face = "right"
		pos = self.Entity:GetPos() - (self.Entity:GetRight() * 600)
	end
	

	for i = 1, amt do
		if face == "forward" then
			pos = pos + (self.Entity:GetForward() * 300)
		else
			pos = pos + (self.Entity:GetRight() * 300)
		end
		local stone = ents.Create("stone_large")

		stone:SetPos(pos)
		
		stone:Spawn()
		stone:SetGravity( 0 )
		stone:Activate()
			
		stone:SetType( self.Entity.type )
			
		gamemode.Call( "Space_Affect", stone )
	end
	
	self:MakeSmallStones( self.Entity )
	self:MakeSmallStones( self.Entity, true )
	self:LotteryStone()
	
	self.Entity:Remove()
end
--[[
HitEntity	=	Entity [58][prop_physics]
HitPos	=	510.0935 353.3315 70.2794
OurOldVelocity	=	247.4127 549.1508 88.5145
HitObject	=	Physics Object [models/Combine_Helicopter/helicopter_bomb01.mdl]
DeltaTime	=	0.18428340554237
TheirOldVelocity	=	2.5403 3.0668 -9.1729
Speed	=	408.96075439453
HitNormal	=	0.0850 -0.3739 0.9235
--]]
