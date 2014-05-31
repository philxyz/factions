
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

-----------------------------------------------------------
-- Name: Initialize
-----------------------------------------------------------
function ENT:Initialize()
	self.stonemovers = {}

	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetMaxHealth(ENT.Health)
	self.Entity:SetHealth(ENT.Health)
	
	-- Wake the physics object up. It's time to have fun!
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
		phys:SetMass(ENT.Mass)
	end
end


-----------------------------------------------------------
--   Name: Physics
-----------------------------------------------------------

--this function is used to prevent players from pushing large rocks around with other props via the physgun. The table stonemovers is a table with all of the rocks that are potentially doing this
--when this function thinks that a player may be trying to cheat like this, it freezes the rock. Not the prettiest or most accurate way of doing this, but it gets the job done.
--when one of the rocks attempting to move the rock (a stonemover) is invalidated or is dropped by the player, the rock is unfrozen again (see ENT.Think)
function ENT:PhysicsCollide( data, physobj )
	local insert = true
	if self.Entity:GetClass() ~= "stone_small" and data.HitEntity:IsPlayerHolding() and not string.find( data.HitEntity:GetClass(), "stone" ) then
	
		self.Entity:GetPhysicsObject():EnableMotion( false )
		
		--fac_Debug( tostring(data.HitEntity).. " smacked into us, freezing rock" )
		
		for k, v in pairs(self.stonemovers) do
			insert = true
			if v == data.HitEntity then
				insert = false
				break
			end
		end
		
		if insert then
			table.insert( self.stonemovers, data.HitEntity )
		end
	end
end

function ENT:Think()
	self.stonemovers = self.stonemovers or {} --it starts thinking before its been initialized
	
	for k, v in pairs(self.stonemovers) do
		if not v:IsValid() or not v:IsPlayerHolding() then
			self.Entity:GetPhysicsObject():EnableMotion( true )
			table.remove( self.stonemovers, k )
		end
	end
	
	if self.Entity:GetClass() == "stone_small" and self.SmallRockRemovalTimer and self.SmallRockRemovalTimer < CurTime() and not self.Entity:IsPlayerHolding() then
		--fac_Debug( "Removing " ..tostring(self.Entity).. " (Lifetime Expired)" )
		self.Entity:Remove()
	end
end

function ENT:Touch()
end
function ENT:OnTouch()
end
function ENT:StartTouch()
end
function ENT:EndTouch()
end

function ENT:GravGunPickupAllowed( ply )
	self.SmallRockRemovalTimer = CurTime() + Factions.Config.RockRemovalTimer
	return true
end

function ENT:GravGunPunt( ply )
	self.SmallRockRemovalTimer = CurTime() + Factions.Config.RockRemovalTimer
	return true
end

function ENT:CanTool( ply )
	return ply:IsAdmin()
end

function ENT:PhysgunPickup( ply )
	return ply:IsAdmin()
end

-----------------------------------------------------------
-- Name: Types and Values
-----------------------------------------------------------

function ENT:SetType( type )
	if type == 0 then --humans start with this
		self.type = 0
		self.Entity:SetMaterial("rocks/rockwall015a")
		self.Entity:SetColor(Color(200,200,200,255))
	elseif type == 1 then --aliens start with this
		self.type = 1
		self.Entity:SetColor(Color(255,255,50,255))
	elseif type == 2 then --neutral
		self.type = 2
		self.Entity:SetMaterial("rocks/rockwall015a")
		self.Entity:SetColor(Color(255,193,193,255))
	end
end

function ENT:GetType()
	return self.type
end

function ENT:GetValue()
	return self.value or 1
end

-----------------------------------------------------------
-- Name: OnTakeDamage
-----------------------------------------------------------
function ENT:OnTakeDamage( dmginfo, Entity )
	local hp2 =	self.Entity:Health()
	local dmg = dmginfo:GetDamage()
	
	self.Entity:SetHealth(hp2 -dmg)
	self.Entity:TakePhysicsDamage( dmginfo )
	if (self.Entity:Health() < 1) then
		self.Entity:Break()
		Factions.SortRocks()
	else 
		return 
	end
end


-----------------------------------------------------------
-- Name: Use
-----------------------------------------------------------
function ENT:Use( activator, caller )
end

-----------------------------------------------------------
-- Name: StoneCreation
-----------------------------------------------------------

function ENT:Break()
	self.Entity:EmitSound("physics/concrete/concrete_break2.wav", 120, 100)
	local rannum = math.Rand(ENT.MinStones,ENT.MaxStones)
	for i = 1, rannum do
		local stone = ents.Create(ENT.Piece)
		stone:SetPos(self.Entity:GetPos() + i * Vector(math.Rand(-70,70), math.Rand(-70,70), 1))
		
		local phys = self.Entity:GetPhysicsObject()
		if not (phys:IsValid()) then return end
		
		phys:EnableGravity(false)
		stone:Spawn()
		self.Entity:Remove()
		phys:EnableGravity(true)
		stone:Activate()
		
		stone:SetType( self.Entity.type )
	end
end

function ENT:LotteryStone()
	local rand = {}
		rand[1] = math.random(1,2)
		rand[2] = math.random(1,4)
		rand[3] = math.random(1,8)
	
	local borders = Factions.GetEntBorders( self.Entity )
	for k,v in pairs(rand) do
		if v == 1 then
			local stone = ents.Create("stone_small")
			stone:SetPos( Vector( math.Rand(borders.x[1], borders.x[2]), math.Rand(borders.y[1], borders.y[2]), math.Rand(borders.z[1], borders.z[2]) ) )
			
			stone:Spawn()
			stone:Activate()
			
			stone:SetType( 2 )
		end
	end
end

function ENT:MakeSmallStones( ent, medium )
	local rand
	if medium then
		rand = 1
	else
		rand = math.Rand(2,6)
	end
	local borders = Factions.GetEntBorders( ent )
	for i = 1, rand do
		local stone
		
		if medium then
			stone = ents.Create("stone_medium")
		else
			stone = ents.Create("stone_small")
		end
		stone:SetPos( Vector( math.Rand(borders.x[1], borders.x[2]), math.Rand(borders.y[1], borders.y[2]), math.Rand(borders.z[1], borders.z[2]) ) )
		
		stone:Spawn()
		stone:Activate()
		
		stone:SetType( self.Entity.type )
		
		gamemode.Call( "Space_Affect", stone )
		stone:SetVelocity( Vector( math.random(1,5), math.random(1,5), math.random(1,5) ) )
	end
end
