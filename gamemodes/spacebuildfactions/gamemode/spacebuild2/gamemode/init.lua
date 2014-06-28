------------------------------------------------
	-- SPACEBUILD2 GAMEMODE
	
	-- Made by SB Team, original made by Shanjaq, GMod 13 fixes included by philxyz

------------------------------------------------
Complete_Planet_Backup = {}
-- Send to client
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "cl_sun.lua" )
AddCSLuaFile( "shared.lua" )

-- Include files for use in here
include( 'shared.lua' )
include( 'environments.lua' )
include( 'hooks.lua' )
include( 'volumes.lua' )
include( 'brush_environments.lua' )

util.PrecacheSound( "Player.FallGib" )
util.PrecacheSound( "HL2Player.BurnPain" )

local version = "SVN(1.0.7)"

local function registerPF()
	if SVX_PF then
		function SB2_isActive()
			return true
		end
		PF_RegisterPlugin("Spacebuild2", version, SB2_isActive, nil, nil, "Gamemode")
		PF_RegisterConVar("Spacebuild2", "SB_NoClip", "1", "Spacebuild Noclip System")
		PF_RegisterConVar("Spacebuild2", "SB_PlanetNoClipOnly", "1", "Planet only Noclip")
		PF_RegisterConVar("Spacebuild2", "SB_AdminSpaceNoclip", "1", "Admins allowed to noclip in space")
		PF_RegisterConVar("Spacebuild2", "SB_SuperAdminSpaceNoclip", "1", "Superadmins allowed to noclip in space")
	else
		CreateConVar( "SB_NoClip", "1" )
		CreateConVar( "SB_PlanetNoClipOnly", "1" )
		CreateConVar( "SB_AdminSpaceNoclip", "1" )
		CreateConVar( "SB_SuperAdminSpaceNoclip", "1" )
	end
end
timer.Simple(5, registerPF)--Needed to make sure the Plugin Framework gets loaded first



local NextUpdate = 0
local NextUpdateTime

InSpace = 0
SetGlobalInt("InSpace", 0)
TrueSun = nil
SunAngle = nil
SB_DEBUG = false --Turn this off if you don't want to get debug data in console!!

include( 'enviro_setup.lua' )

local Energy_Increment = 5
local Coolant_Increment = 5

function GM:Think()
	if (InSpace == 0) then return end
	if CurTime() < (NextUpdateTime or 0) then return end
	self:Space_Affect_Players()
	if NextUpdate == 1 then
		SB_Planet_Quake()
		for _, class in ipairs( self.affected ) do
			local ents = ents.FindByClass( class )
			for _, ent in ipairs( ents ) do
				if not ent.IsInBrushEnv then
					self:Space_Affect_Ent( ent )
				end
			end
		end
		local ents = ents.FindByClass( "entityflame" )
		for _, ent in ipairs( ents ) do
			ent:Remove()
		end
		NextUpdate = 0
	else
		NextUpdate = 1
	end
	NextUpdateTime = CurTime() + 0.5
end

function GM:Space_Affect_Shared( ent, gravity)
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end
	if (not gravity) or (gravity == 0) then
		phys:EnableGravity( false )
		phys:EnableDrag( false )
		ent:SetGravity(0.00001)
		ent.gravity = 0
		if not ent.spawn then
			ent.spawn = true 
		end
	else
		ent:SetGravity(gravity)
		ent.gravity = gravity
		phys:EnableGravity( true )
		phys:EnableDrag( true )
	end	
end

function GM:GetTemperature(ent, ltemp, stemp, sunburn)
	local entpos = ent:GetPos()
	local temperature = 14
	local trace = {}
	
	print("SB2 DEBUG: TrueSun = " .. tostring(TrueSun))
	if not ( TrueSun == nil ) then
		SunAngle = (entpos - TrueSun)
		SunAngle:Normalize()
		
		print("SB2 DEBUG: SunAngle = " .. tostring(SunAngle))
		
		local startpos = (entpos - (SunAngle * 4096))
		trace.start = startpos
		trace.endpos = entpos + Vector(0,0,30)
	
		local tr = util.TraceLine( trace )
		
		if (tr.Hit) then
			if (tr.Entity == ent) then
				if (ent:IsPlayer()) then
					if sunburn and (sunburn == 1) then
						if (ent:Health() > 0) then
							ent:TakeDamage( 5, 0 )
							ent:EmitSound( "HL2Player.BurnPain" )
						end
					end
				end
				temperature = ltemp
			else
				temperature = stemp
			end
		else
			temperature = ltemp
		end
	else
		temperature = ltemp
	end
	
	return temperature
end

function GM:GravityCheck(ent)
	local trace = {}
	local pos = ent:GetPos()
	trace.start = pos
	trace.endpos = pos - Vector(0,0,512)
	trace.filter = { ent }
	local tr = util.TraceLine( trace )
	if (tr.Hit) then
		if (tr.Entity.grav_plate == 1) then
			return true
		else
			return false
		end
	else
		return false
	end
end

function GM:Space_Affect_Players()
	for _, ply in pairs(player:GetAll()) do
		if not ply.IsInBrushEnv then 
			if not ply:Alive() then ply.planet = nil end
			local pos = ply:GetPos()
			local onplanet, num = SB_OnEnvironment(pos)
			if onplanet then
				local valid, planet, pos , radius, gravity, habitat, air, co2, n, atmosphere, pressure, ltemperature, stemperature, sunburn = SB_Get_Environment_Info(num)
				if not ply.planet or ply.reset or not (ply.planet == num) then
					if valid then
						self:Space_Affect_Shared( ply, gravity)
						ply.planet = num
						ply.onplanet = planet
						if ply.suit then
							ply.suit.atmosphere = atmosphere
							ply.suit.pressure = pressure
							ply.suit.habitat = habitat
							ply.suit.pair = air
							ply.suit.co2 = co2
							ply.suit.n = n
							if planet then
								ply.suit.temperature = self:GetTemperature(ply, ltemperature, stemperature, sunburn)
							else
								ply.suit.temperature = ltemperature
							end
						end	
						if ply.reset then
							ply.reset = false
						end					
					end
				end
				if ply.suit and ply.onplanet then
					ply.suit.temperature = self:GetTemperature(ply, ltemperature, stemperature, sunburn)
				end
				if gravity ~= 1 then
					if self:GravityCheck(ply) then
						ply:SetGravity(1)
					else
						ply:SetGravity(gravity)
					end
				end
			else
				if ply.planet or not ply.spawn or ply.reset then
					self:Space_Affect_Shared(ply)
					ply.planet = nil
					ply.onplanet = false
					if ply.suit then
						ply.suit.atmosphere = 0
						ply.suit.pressure = 0
						ply.suit.habitat = 0
						ply.suit.pair = 0
						ply.suit.co2 = 0
						ply.suit.n = 0
						ply.suit.temperature = 14
					end
					if not ply:InVehicle() or not game.SinglePlayer() then
						if not AllowAdminNoclip(ply) then
							if ply:GetMoveType() == MOVETYPE_NOCLIP then
								ply:SetMoveType(MOVETYPE_WALK)
							end
						end
					end
					if ply.reset then
						ply.reset = false
					end
				end
				if self:GravityCheck(ply) then
					ply:GetPhysicsObject():EnableGravity( true )
					ply:GetPhysicsObject():EnableDrag( true )
					ply:SetGravity(1)
				else
					ply:GetPhysicsObject():EnableGravity( false )
					ply:GetPhysicsObject():EnableDrag( false )
					ply:SetGravity(0.00001)
				end
			end
		end
	end
end

function GM:Space_Affect_Ent(ent)
	if (ent.IsInBrushEnv or
	not ent:IsValid())
	or not ent:GetPhysicsObject():IsValid() 
	or ent:GetPhysicsObject():IsAsleep()
	or ent:IsPlayer() 
	then return end
	local pos = ent:GetPos()
	local onplanet, num = SB_OnEnvironment(pos, ent.num, nil, ent.IgnoreClasses) --ignoreClasses so the check won't check if the ent is in an environment that exists out of the certain ent
	if SB_DEBUG then Msg(ent:GetClass().." is on environment("..num..")\n") end
	if onplanet then
		local valid, planet, _ , ig, gravity, habitat, air, co2, n, atmosphere, pressure,  ltemperature, stemperature, sunburn = SB_Get_Environment_Info(num)
		if not ent.planet or not (ent.planet == num) or ent.reset then
			if valid then
				self:Space_Affect_Shared( ent, gravity)
				ent.planet = num
				ent.onplanet = planet
				if ent.environment then
					ent.environment.atmosphere = atmosphere
					ent.environment.pressure = pressure
					ent.environment.habitat = habitat
					ent.environment.air = air
					ent.environment.co2 = co2
					ent.environment.n = n
					if planet then
						ent.environment.temperature = self:GetTemperature(ent, ltemperature, stemperature, sunburn)
					else
						ent.environment.temperature = ltemperature
					end
				end	
				if ent.reset then
					ent.reset = false
				end			
			end
		end
		if ent.environment and ent.onplanet then
			ent.environment.temperature = self:GetTemperature(ent, ltemperature, stemperature, sunburn)
			if not SB2_Override_HeatDestroy and ent.environment.temperature > 100000 and sunburn == 1 then
				ent:Remove()
			end
		end
	else
		if ent.planet or not ent.spawn or ent.reset then
			if ent.environment and ent.environment.type and ent.environment.type == "TerraForm" then
				local tf = SB_GetTerraformer(ent.planet)
				if ent.planet and tf and tf == ent then 
					if SB_RemTerraformer(ent.planet, ent) and ent.Active == 1 then
						SB_Terraform_UnStep(ent, ent.planet)
					end
				end
				ent.planetset = false
				if ent.reset then
					ent.reset = false
				end
			end
			self:Space_Affect_Shared(ent)
			ent.planet = nil
			ent.onplanet = false
			if ent.environment then
				ent.environment.atmosphere = 0
				ent.environment.pressure = 0
				ent.environment.habitat = 0
				ent.environment.air = 0
				ent.environment.co2 = 0
				ent.environment.n = 0
				ent.environment.temperature = 14
			end
			if ent.reset then
				ent.reset = nil
			end
		end
	end
end


-- Initialization functions

function GM:InitPostEntity()
	self:Register_Environments()
	self:Register_Sun()
	self:AddSentsToList()
end

function GM:SB_SentCheck(ply, ent)
	if not (ent and ent:IsValid()) then return end
	local c = ent:GetClass()
	if table.HasValue(self.affected, c) then return end
	table.insert(self.affected, c)
end
function GM:SB_Ragdoll(ply)
	if ply:GetRagdollEntity() and ply:GetRagdollEntity():IsValid() then
		ply:GetRagdollEntity():SetGravity(0)
	else
		ply:CreateRagdoll()
		ply:GetRagdollEntity():SetGravity(0)
	end
end

-- DPF: Overriding original PlayerSpawn
---------------------------------------------------------
--   Name: gamemode:PlayerSpawn( )
--   Desc: Called when a player spawns
---------------------------------------------------------
function GM:PlayerSpawn( pl )

	--
	-- If the player doesn't have a team in a TeamBased game
	-- then spawn him as a spectator
	--
	if ( self.TeamBased and ( pl:Team() == TEAM_SPECTATOR or pl:Team() == TEAM_UNASSIGNED ) ) then

		self:PlayerSpawnAsSpectator( pl )
		return
	
	end

	-- Stop observer mode
	pl:UnSpectate()

	-- Call item loadout function
	hook.Call( "PlayerLoadout", GAMEMODE, pl )
	
	-- Set player model
	hook.Call( "PlayerSetModel", GAMEMODE, pl )
	
	-- Set the player's speed
	GAMEMODE:SetPlayerSpeed( pl, 250, 500 )
	
end

hook.Add( "PlayerSpawnedSENT", "SBSpawnedSent", GM.SB_SentCheck)
hook.Add("PlayerKilled","SBRagdoll",GM.SB_Ragdoll)
