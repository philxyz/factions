AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

if not transpiece then
	transpiece = {}
end
if not rocks then
	rocks = {}
end

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local money = ply:GetNWInt("money")
	if money < Factions.Config.TransformerSpawnCost then
		Notify( ply, "You do not have enough money to do that! (Requires $" ..Factions.Config.TransformerSpawnCost.. ")", "NOTIFY_ERROR" )
		return
	else
		Factions.AuthorizeEntPurchase( ply, nil, "transformer" )
		umsg.Start("DrawNotice", ply)
			umsg.String( "$" )
			umsg.Short( -Factions.Config.TransformerSpawnCost )
		umsg.End()
		ply:SetNWInt( "money",money - Factions.Config.TransformerSpawnCost )
	end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	
	local ent = ents.Create( "transformer" )
	ent:SetPos( SpawnPos + Vector( 0, 0, -15 ) )
	ent:PointAtEntity( ply )
	ent:SetAngles( Angle(0, ent:GetAngles().y, 0) )
	
	ent:GetTable().spawned = true
	
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:Initialize()
	transpiece[self.Entity] = {}
	rocks[self.Entity] = {}

	self.Entity:SetModel( "models/props_combine/combine_interface001.mdl" )
	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:EnableGravity(true)
		
		if self.spawned then
			phys:EnableDrag(true)
			phys:EnableMotion(true)
		else
			phys:EnableDrag(false)
			phys:EnableMotion(false)
		end
		
		phys:SetMass( 200 )
	end
	
	self.Entity:Activate()
	
	-- Vector(  forth/ -back,      right/ -left,       up/ -down  )
	
	transpiece[self.Entity][1] = ents.Create("prop_physics") --Circle
		util.PrecacheModel("models/props_wasteland/laundry_washer001a.mdl")
		transpiece[self.Entity][1]:SetModel("models/props_wasteland/laundry_washer001a.mdl")
		transpiece[self.Entity][1]:SetAngles(self.Entity:GetAngles())
		transpiece[self.Entity][1]:SetPos(self.Entity:GetPos() + (self.Entity:GetForward() * -62) + (self.Entity:GetUp() * 35))
		
	transpiece[self.Entity][2] = ents.Create("prop_physics") --Tube
		util.PrecacheModel("models/props_wasteland/laundry_washer003.mdl")
		transpiece[self.Entity][2]:SetModel("models/props_wasteland/laundry_washer003.mdl")
		transpiece[self.Entity][2]:SetAngles(self.Entity:GetAngles() + Angle(0, 90, 0))
		transpiece[self.Entity][2]:SetPos( transpiece[self.Entity][1]:GetPos() + (self.Entity:GetUp() * -10) + (self.Entity:GetRight() * 4) )
		
	transpiece[self.Entity][3] = ents.Create("prop_physics") --Laundry Cart
		util.PrecacheModel("models/props_wasteland/laundry_cart001.mdl")
		transpiece[self.Entity][3]:SetModel("models/props_wasteland/laundry_cart001.mdl")
		transpiece[self.Entity][3]:SetAngles(self.Entity:GetAngles() + Angle(0, 90, 75))
		transpiece[self.Entity][3]:SetPos(transpiece[self.Entity][1]:GetPos() + (self.Entity:GetForward() * -25) + (self.Entity:GetUp() * 52))

	
	for k,v in pairs( transpiece[self.Entity] ) do
		v:PhysicsInit( SOLID_VPHYSICS )
		v:SetMoveType( MOVETYPE_VPHYSICS )
		v:SetSolid( SOLID_VPHYSICS )
		
		v:Spawn()
		local phys = v:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:EnableGravity(true)
			
			if self.spawned then
				phys:EnableDrag(true)
				phys:EnableMotion(true)
			else
				phys:EnableDrag(false)
				phys:EnableMotion(false)
			end
		end
		v:Activate()
		
		--local tbl = v:GetTable()
		v.CanTool = self.CanTool
		v.PhysgunPickup = self.PhysgunPickup
		--v.IsWorld = self.Entity.IsWorld --only here so that gcombat won't hurt us if we aren't player spawned
		
		self.Entity:DeleteOnRemove( v )
		
		v.spawned = self.spawned
		v:SetKeyValue( "classname", "transformer" )
		
		--PrintTable( v:GetKeyValues() )

		if self.spawned then --we only need to bind and weld if the player spawned it, no point otherwise (takes up memory and entities)
			local weld = constraint.Weld( self.Entity, v, 0, 0, 0, true )
				self.Entity:DeleteOnRemove( weld )
				v:DeleteOnRemove( weld )
			
			local nocollide = constraint.NoCollide( self.Entity, v, 0, 0 )
				self.Entity:DeleteOnRemove( nocollide )
				v:DeleteOnRemove( nocollide )
		end
	end
	
	local constraints = {}
	if self.spawned then --we only need to bind and weld if the player spawned it, no point otherwise (takes up memory and entities)
		for k,v in pairs( transpiece[self.Entity] ) do --nocollide and weld every piece of the transformer
			for a,b in pairs( transpiece[self.Entity] ) do
				if v ~= b and constraints[b] ~= v and constraints[v] ~= b then
					local weld = constraint.Weld( b, v, 0, 0, 0, true )
						if weld then
							v:DeleteOnRemove( weld )
							b:DeleteOnRemove( weld )
						end
					
					local nocollide = constraint.NoCollide( b, v, 0, 0 )
						if nocollide then
							v:DeleteOnRemove( nocollide )
							b:DeleteOnRemove( nocollide )
						end
						
					constraints[b] = v --attempt to prevent unneccessary welds and nocollides (causes crashes with too many constraints)
				end
			end
		end
	end
end

function ENT:Use( ply )
	for k, v in pairs(rocks[self.Entity]) do
		if v:IsValid() then
			v:EmitSound("ambient/levels/citadel/weapon_disintegrate1.wav", 120, 100)
			
			local ed = EffectData()
				ed:SetEntity( v )
				util.Effect( "entity_remove", ed, true, true )
				
			local TeamNum = v:GetType()
			
			if (ply:Team() == TEAM_HUMANS and TeamNum == 1) or (ply:Team() == TEAM_ALIENS and TeamNum == 0) then
				ply:SetNetworkedInt( "money", ply:GetNetworkedInt( "money" ) + Factions.Config.RockMoneyTrade + Factions.Config.RockMoneyTeam )
				umsg.Start("DrawNotice", ply)
					umsg.String( "$" )
					umsg.Short( Factions.Config.RockMoneyTrade + Factions.Config.RockMoneyTeam )
				umsg.End()
			
			elseif TeamNum == 2 then
				ply:SetNetworkedInt( "money", ply:GetNWInt( "money" ) + Factions.Config.RockMoneyRed )
				umsg.Start("DrawNotice", ply)
					umsg.String( "$" )
					umsg.Short( Factions.Config.RockMoneyRed )
				umsg.End()
				
			else
				ply:SetNetworkedInt( "money", ply:GetNetworkedInt( "money" ) + Factions.Config.RockMoneyTeam )
				ply:SetNetworkedInt( "rock" ..tostring( TeamNum ), ply:GetNWInt( "rock" ..tostring( TeamNum ) ) + 1 )
				umsg.Start("DrawNotice", ply)
					umsg.String( "$" )
					umsg.Short( Factions.Config.RockMoneyTeam )
				umsg.End()
				umsg.Start("DrawNotice", ply)
					umsg.String( "rock" ..tostring( TeamNum ) )
					umsg.Short( 1 )
				umsg.End()
			end
			
			v:Remove()
			table.remove( rocks[self.Entity], k )
		end
	end
end

function ENT:Think()
	if not transpiece[self.Entity][1]:IsValid() then return end

	local sphere = ents.FindInSphere(transpiece[self.Entity][1]:GetPos() + (self.Entity:GetUp() * 52), 30)
	for k, v in pairs(rocks[self.Entity]) do
		for a, b in pairs(sphere) do
			if v == b then
				break
			end
			if k == table.getn(rocks[self.Entity]) then
				table.remove( rocks[self.Entity], k )
			end
		end		
	end
	
	for k, v in pairs(sphere) do
		if v:GetClass() == "stone_small" then
			for a, b in pairs(rocks[self.Entity]) do
				if b == v then
					return
				end
			end
			table.insert( rocks[self.Entity], v )
		end
	end
end

function ENT:CanTool() return self.spawned or false; end
function ENT:PhysgunPickup() return self.spawned or false; end
--function () return !self.spawned or false; end

--First Transformer Design:
--[[
transpiece[self.Entity][1] = ents.Create("prop_physics") --Laundry Cart
		util.PrecacheModel("models/props_wasteland/laundry_cart001.mdl")
		transpiece[self.Entity][1]:SetModel("models/props_wasteland/laundry_cart001.mdl")
		transpiece[self.Entity][1]:SetAngles(self.Entity:GetAngles() + Angle(0, 90, -20))
		transpiece[self.Entity][1]:SetPos(self.Entity:GetPos() + (self.Entity:GetForward() * -5) + (self.Entity:GetUp() * 78))
		
	transpiece[self.Entity][2] = ents.Create("prop_physics") --Rock Escalator
		util.PrecacheModel("models/props_wasteland/prison_heater001a.mdl")
		transpiece[self.Entity][2]:SetModel("models/props_wasteland/prison_heater001a.mdl")
		transpiece[self.Entity][2]:SetAngles(self.Entity:GetAngles() + Angle(-30, 0, 0))
		transpiece[self.Entity][2]:SetPos(transpiece[self.Entity][1]:GetPos() + (self.Entity:GetForward() * -22) + (self.Entity:GetUp() * -8))
	
	transpiece[self.Entity][3] = ents.Create("prop_physics") --Machine (Laundry Dryer)
		util.PrecacheModel("models/props_wasteland/laundry_dryer001.mdl")
		transpiece[self.Entity][3]:SetModel("models/props_wasteland/laundry_dryer001.mdl")
		transpiece[self.Entity][3]:SetAngles(self.Entity:GetAngles())
		transpiece[self.Entity][3]:SetPos(self.Entity:GetPos() + (self.Entity:GetForward() * -60) + (self.Entity:GetUp() * 60))
	
	transpiece[self.Entity][4] = ents.Create("prop_physics") --Tube
		util.PrecacheModel("models/props_wasteland/laundry_washer003.mdl")
		transpiece[self.Entity][4]:SetModel("models/props_wasteland/laundry_washer003.mdl")
		transpiece[self.Entity][4]:SetAngles(self.Entity:GetAngles() + Angle(0, 90, 0))
		transpiece[self.Entity][4]:SetPos(transpiece[self.Entity][3]:GetPos() + (self.Entity:GetRight() * 84) + (self.Entity:GetUp() * -33))
	
	transpiece[self.Entity][5] = ents.Create("prop_physics") --Tube Ending Container (Laundry Washer)
		util.PrecacheModel("models/props_wasteland/laundry_washer001a.mdl")
		transpiece[self.Entity][5]:SetModel("models/props_wasteland/laundry_washer001a.mdl")
		transpiece[self.Entity][5]:SetAngles(self.Entity:GetAngles())
		transpiece[self.Entity][5]:SetPos(transpiece[self.Entity][4]:GetPos() + (self.Entity:GetRight() * 85) + (self.Entity:GetUp() * 7))
		
		

/*---------------------------------------------------------
   Name: OnTakeDamage
---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo, Entity )
end

/*---------------------------------------------------------
   Name: PhysicsCollide
---------------------------------------------------------*/
function ENT:PhysicsCollide( data, physobj )
end

function ENT:PhysicsUpdate()
end

--]]	
