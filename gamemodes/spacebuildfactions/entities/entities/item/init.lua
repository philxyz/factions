AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	
	local ent = ents.Create( "item" )
	ent:SetPos( SpawnPos + Vector( 0, 0, -15 ) )
	ent:PointAtEntity( ply )
	ent:SetAngles( Angle(0, ent:GetAngles().y, 0) )
	ent:Spawn()
	ent:Activate()
	
	ent:SetResource( "money", 100 )
	
	return ent

end

-----------------------------------------------------------
--  Name: Initialize
-----------------------------------------------------------
function ENT:Initialize()
	self.Entity:SetModel( "models/weapons/w_suitcase_passenger.mdl" )
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
	if not self.ammo then self.ammo = {} end
	if not self.weapons then self.weapons = {} end
	if not self.res then self.res = {} end
	if not self.usetimer then self.usetimer = 0 end
end

function ENT:Use( ply )
	if self.usetimer > CurTime() then return end
	if self.res.owner:IsValid() and self.res.owner:Team() == ply:Team() and self.res.owner ~= ply then return end
	
	for k,v in pairs(self.res) do
		if k ~= "owner" and v > 0 then
			--should we convert any gold or chalc to money?
			if (ply:Team() == TEAM_HUMANS and k == ROCK_GOLD) or ((ply:Team() == TEAM_ALIENS and k == ROCK_CHAL)) then
				ply:SetNetworkedInt( "money", ply:GetNetworkedInt( "money" ) + Factions.Config.RockMoneyTrade * v )
				umsg.Start("DrawNotice", ply)
					umsg.String( "$" )
					umsg.Short( Factions.Config.RockMoneyTrade * v )
				umsg.End()
				
			else
				umsg.Start( "DrawNotice", ply )
					umsg.String( k )
					umsg.Short( v )
				umsg.End()
				ply:SetNetworkedInt( k, ply:GetNetworkedInt(k) + v )
			end
		end
	end
	for k,v in pairs(self.weapons) do
		ply:GiveWeapon( v )
	end
	for k,v in pairs(self.ammo) do
		ply:GiveAmmo( v, k, true )
	end
	self.Entity:Remove()
	
	ply:SendLua( "surface.PlaySound( 'items/ammo_pickup.wav' )" )
	
	self.usetimer = CurTime() + 3
end

function ENT:SetResource( key, value )
	if not self.res then self.res = {} end
	self.res[key] = value
	
	if key == "owner" then
		self:SetOverlayText( "Owner: " .. value:Nick() )
	end
end

function ENT:AddWeapon( weapon )
	if not self.weapons then self.weapons = {} end
	table.insert( self.weapons, weapon )
end

function ENT:SetAmmo( key, value )
	if not self.ammo then self.ammo = {} end
	self.ammo[key] = value
end

-----------------------------------------------------------
-- Name: Don'ts
-----------------------------------------------------------

function ENT:GravGunPickupAllowed( ply )
	if ply:IsAdmin() or self.res.owner == ply then return true end
	return false
end

function ENT:GravGunPunt( ply )
	if ply:IsAdmin() or self.res.owner == ply then return true end
	return false
end

function ENT:PhysgunPickup( ply )
	if ply:IsAdmin() or self.res.owner == ply then return true end
	return false
end

function ENT:CanTool( ply )
	return false
end
