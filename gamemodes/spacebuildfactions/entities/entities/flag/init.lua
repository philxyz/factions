AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

local flagmodels = {}
flagmodels[ TEAM_ALIENS ] = "models/katharsmodels/flags/flag36.mdl"
flagmodels[ TEAM_HUMANS ] = "models/katharsmodels/flags/flag27.mdl"
flagmodels.neutral        = "models/katharsmodels/flags/flag08.mdl"

function ENT:SpawnFunction( ply, tr )

	if ( not tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 15
	
	local ent = ents.Create( "flag" )
	ent:SetPos( SpawnPos + Vector( 0, 0, -15 ) )
	ent:PointAtEntity( ply )
	ent:SetAngles( Angle(0, ent:GetAngles().y, 0) )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

-----------------------------------------------------------
-- Name: Initialize
-----------------------------------------------------------
function ENT:Initialize()
	self.Entity:SetModel( flagmodels.neutral )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:EnableGravity(true)
		phys:EnableDrag(true)
	end
	
	self.CaptureTimer = 0
	self.color = color_white
	
	self.Entity:StartMotionController()
end

-----------------------------------------------------------
--  Capture
-----------------------------------------------------------

function ENT:Think()
	if self.user and self.user:IsValid() then
		if self.user:GetPos():Distance( self.Entity:GetPos() ) > 100 or not self.user:Alive() then
			self:SetProgress( self.user, 120 )
		else
			local starttime = self.CaptureCompleteAt - 45

			if ( ( CurTime() - starttime ) / 45 ) * 100 >= 100 then
				gamemode.Call( "CapturePlanet", self.user, self.Entity )
				self.color = team.GetColor( self.user:Team() )
			end
			
			self:SetProgress( self.user, ( ( CurTime() - starttime ) / 45 ) * 100, self.color, team.GetColor( self.user:Team() ) )
			
		end
	end
	
	self:NextThink( CurTime() + 1 )
end

function ENT:Use( ply )
	if (self.antispam or 0) > CurTime() then return end

	if Factions.GetNWVar( "Mode" ) == "War" then
		if self.ownerteam and self.ownerteam == ply:Team() then return end
		if self.homeplanet and self.homeplanet == ply:Team() then return end
	
		-- make sure that if its a homeplanet flag, the team doesn't have any other flags  left--
		local flags = gmod.GetGamemode().flags
		local Oflags = {}
		Oflags[ TEAM_ALIENS ] = {}
		Oflags[ TEAM_HUMANS ] = {}
		
		for _,fl in pairs( flags ) do
			if fl.fac_owner and fl.fac_owner:IsValid() and fl.ownerteam then
				Oflags[ fl.ownerteam ][ fl:EntIndex() ] = fl
			end
		end
		
		if self.homeplanet and table.Count( Oflags[ self.homeplanet ] ) > 0 then
			if table.Count( Oflags[ self.homeplanet ] ) > 0 then
				Notify( ply, "You must first capture all of the team's other planets before capturing this one." , "NOTIFY_ERROR" )
				return
			end
		end
		
	elseif Factions.GetNWVar( "Mode" ) == "Free" then
		if self.fac_owner == ply then return end
	end
	
	if not self.user then
		self.CaptureCompleteAt = CurTime() + 45
		self.user = ply
		self.ProgressBar = 0
		self:NextThink( CurTime() )
	end
	
	self.antispam = CurTime() + 3
end

function ENT:SetProgress( ply, prog, color1, color2 )
	umsg.Start( "SetProgress", ply )
		umsg.Short( prog )
		
		if color1 and color2 then
			umsg.Short( color1.r )
			umsg.Short( color1.g )
			umsg.Short( color1.b )
			
			umsg.Short( color2.r )
			umsg.Short( color2.g )
			umsg.Short( color2.b )
		end
	umsg.End()
	
	self.ProgressBar = prog
	if prog >= 100 then
		self.ProgressBar = nil
		self.user = nil
		self.CaptureCompelteAt = nil
	end
end

-----------------------------------------------------------
-- Physics
-----------------------------------------------------------

function ENT:PhysicsSimulate( phys, deltatime )
	phys:Wake( )
			
	self.ShadowParams = { }
	self.ShadowParams.secondstoarrive = 1
	self.ShadowParams.pos = self.Entity:GetPos()
	self.ShadowParams.angle = Angle( 0, self.Entity:GetAngles().y, 0 )
	self.ShadowParams.maxangular = 5000
	self.ShadowParams.maxangulardamp = 10000
	self.ShadowParams.maxspeed = 1000000
	self.ShadowParams.maxspeeddamp = 0
	self.ShadowParams.dampfactor = 1.4
	self.ShadowParams.teleportdistance = 0
	self.ShadowParams.deltatime = deltatime
			
	phys:ComputeShadowControl( self.ShadowParams )
end

function ENT:PhysicsCollide( data, physobj )
	if not self.frozen then
		if data.HitEntity and data.HitEntity:IsWorld() then
			physobj:EnableMotion( false )
			self.frozen = true
		elseif data.HitEntity then
			data.HitEntity:Remove() --nothing shall stand in our way!
		end
	end
end

-----------------------------------------------------------
--   Name: Donts
-----------------------------------------------------------

function ENT:GravGunPickupAllowed( ply )
	return false
end

function ENT:GravGunPunt( ply )
	return false
end

function ENT:PhysgunPickup( ply )
	return false
end

function ENT:CanTool( ply )
	return false
end
