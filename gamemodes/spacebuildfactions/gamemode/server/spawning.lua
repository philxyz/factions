------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------
local civmodel = { "models/player/Group01/female_04.mdl",
			"models/player/Group01/female_06.mdl",
			"models/player/Group01/female_07.mdl",
			"models/player/Group01/male_02.mdl",
			"models/player/Group01/male_03.mdl",
			"models/player/Group01/male_08.mdl" }

local alienmodels = { "models/alien_red.mdl" }--, "models/alien_green.mdl", "models/alien_blue.mdl" }

ROCKS = {}
ROCKS.human = {}
ROCKS.alien = {}
function GM:PlayerInitialSpawn( ply )--the player has "spawned" as a spectator, giving him a chance to pick his team
	-- Clobbered Spacebuild 3 function re-declared here
	if self.GetPlanets then
		self.BaseClass:PlayerInitialSpawn(ply)
		if Environments and table.Count(Environments) > 0 then
			for k, v in pairs(Environments) do
				if v.IsPlanet and v:IsPlanet() then
					SendColorAndBloom(v, ply)
				elseif v.IsStar and v:IsStar() then
					SendSunBeam(v, ply)
				end
			end
		end
	end
	-- End Spacebuild Code

	plyvar[ ply ] = {}

	Factions.SortRocks()

	ply:SetTeam(TEAM_SPECTATOR)

	--ply:Umsg( "showmenu" )
	umsg.Start( "fac_showteammenu", ply )
	umsg.End()
	
	ply:UmsgLarge( "addonsongs", fac_addonsongs )
	--ply:UmsgLarge( "fac_stools", fac_Stools )
	
	for k, v in pairs(player.GetAll()) do
		if v ~= ply then
			v:ChatPrint( ply:Nick().. " Has Joined The Game." )
		end
	end
	ply:ModifyScreenColor( Color( -255, -255, -255 ), true )
end

function GM:PlayerInitialTeamSpawn( ply ) --the player has picked his team and is ready to go for the first time
	local u = ply:UniqueID()
	if not plyvar[u] then
		plyvar[u] = {}
		plyvar[u].savedres = {}
		
		if file.Exists( "factions/clientdata/" .. Factions.ConvertID( ply ) .. ".txt", "DATA" ) then --load  player resource data from server files
			plyvar[u].savedres = util.KeyValuesToTable(file.Read( "factions/clientdata/" ..Factions.ConvertID( ply ).. ".txt", "DATA" ))
			if not plyvar[u].savedres.lastsave then plyvar[u].savedres.lastsave = 1 end
			
			if not (Factions.Config.MoneyReset and (((CurTime() - plyvar[u].savedres.lastsave)/60.0) > Factions.Config.MoneyTimeout)) then
				if not self.DisableSaving then
					ply:SetNWInt( ROCK_GOLD, plyvar[u].savedres.gold )
					ply:SetNWInt( ROCK_CHAL, plyvar[u].savedres.chal )
					ply:SetNWInt("money", plyvar[u].savedres.money)
				
					if plyvar[u].savedres.weapons then
						for k,v in pairs( plyvar[u].savedres.weapons ) do
							ply:GiveWeapon( v )
						end
					end
					if plyvar[u].savedres.ammo then
						for k,v in pairs( plyvar[u].savedres.ammo ) do
							ply:GiveAmmo( v, k )
						end
					end
				end
			
				Factions.Notify( ply, "Welcome back " .. ply:Nick() .. ", your resources have been saved!", "NOTIFY_GENERIC", 15 )
			else
				Factions.Notify( ply, "Welcome back " .. ply:Nick() .. ", you were gone more than " .. Factions.Config.MoneyTimeout .. " minutes so your resources were lost!", "NOTIFY_GENERIC", 15 )
			end
		else
			ply:SetNWInt("money", 500)
		end
	else
		-- for the case where a lastsave point has not yet been created
        if not plyvar[u].savedres.lastsave then plyvar[u].savedres.lastsave = 1 end

		if Factions.Config.MoneyReset and (((CurTime() - plyvar[u].savedres.lastsave)/60.0) > Factions.Config.MoneyTimeout) then
			plyvar[u] = {}
			plyvar[u].savedres = {}
			Factions.Notify( ply, "Welcome back " .. ply:Nick() .. ", you were gone more than " .. Factions.Config.MoneyTimeout .. " minutes so your resources were lost!", "NOTIFY_GENERIC", 15 )
		else
			if (plyvar[u].savedres.gold or plyvar[u].savedres.chal) and plyvar[u].savedres.money then --load player resource data from server variables
				if not self.DisableSaving then
					ply:SetNWInt( ROCK_GOLD, plyvar[u].savedres.gold )
					ply:SetNWInt( ROCK_CHAL, plyvar[u].savedres.chal )
					ply:SetNWInt("money", plyvar[u].savedres.money)
			
					if plyvar[u].savedres.weapons and plyvar[u].savedres.ammo then
						for k,v in pairs( plyvar[u].savedres.weapons ) do
							ply:GiveWeapon( v )
						end
						for k,v in pairs( plyvar[u].savedres.ammo ) do
							ply:GiveAmmo( v, k )
						end
					end
				end
				Factions.Notify( ply, "Welcome back " .. ply:Nick() .. ", your resources have been saved!", "NOTIFY_GENERIC", 15 )
			end
		end
	end
	
	umsg.Start("schooltime", ply)
	umsg.End()
	
	plyvar[ply].InitTeamSpawn = true
end

function GM:PlayerSpawn( ply )
	if plyvar[ ply ].spawnpoint then
		ply:SetPos( ply:GetPos() + Vector( 0, -40, 0 ) )
	end

	ply:SetColor(Color(255, 255, 255, 255))
	ply:StripWeapons()
	ply:StripAmmo()
	ply:UnSpectate()
	ply:UnLock()
	ply:SetNetworkedBool( "showtop", false )
	
	if ply:Team() == TEAM_HUMANS then
		ply:SetHealth(50)
		ply:SetArmor(0)
		ply:Give( "weapon_physcannon" )
		ply:Give( "gmod_tool" )
		ply:Give( "gmod_camera" )
		ply:Give( "weapon_crowbar" )
		ply:SelectWeapon( "weapon_physcannon" )
		ply:SetModel(civmodel[ math.random( 1, 6 )])
		plyvar[ply].Active = true
		ply:ModifyScreenColor( Color( -255, -255, -255 ) )
	end
		
	if ply:Team() == TEAM_ALIENS then
		ply:SetHealth(50)
		ply:SetArmor(0)
		ply:Give( "weapon_physcannon" )
		ply:Give( "gmod_tool" )
		ply:Give( "gmod_camera" )
		ply:Give( "weapon_crowbar" )
		ply:SelectWeapon( "weapon_physcannon" )
		--ply:SetModel( alienmodels[ math.random( 1, 3 ) ] )
		ply:SetModel( alienmodels[1] )
		plyvar[ply].Active = true
		ply:ModifyScreenColor( Color( -255, -255, -255 ) )
	end
	
	if ply:Team() == TEAM_SPECTATOR then --spectators
		ply:Lock()
		ply:SetMoveType(0)
		ply:Spectate( OBS_MODE_FIXED )
		ply:SetColor(Color(0, 0, 0, 0))
	end
	
	gamemode.Call("BalanceTeams")
end

----------------------------------------------
-- Select Spawnpoint
----------------------------------------------

function GM:PlayerSelectSpawn( ply )
	if plyvar[ ply ].spawnpoint then
		return plyvar[ ply ].spawnpoint
	else
		return gamemode.Call( "DefaultSpawn", ply )
	end
end

function GM:DefaultSpawn( pl )
	self.SpawnPoints = self.SpawnPoints or {}
		
	if not self.SpawnPoints[1] and not self.SpawnPoints.Human and not self.SpawnPoints.Alien then
		local humanpoints = ents.FindByClass( "info_spawn_human" )
		local alienpoints = ents.FindByClass( "info_spawn_alien" )
		if humanpoints[1] and alienpoints[1] then
			self.SpawnPoints.Human = humanpoints
			self.SpawnPoints.Alien = alienpoints
		else
			fac_Error( 'Map Compiled Incorrectly! Unable to find useable Factions spawnpoints. Human spawnpoints should have the classname of "info_spawn_human", and alien spawnpoints should have the classname of "info_spawn_alien".' )
		end
	end
	if not self.SpawnPoints[1] and not self.SpawnPoints.Human and not self.SpawnPoints.Alien then
		self.LastSpawnPoint = 0
		self.SpawnPoints = ents.FindByClass( "info_player_start" )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_deathmatch" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_combine" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_rebel" ) )
			
		-- CS Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_counterterrorist" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_terrorist" ) )
			
		-- DOD Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_axis" ) )
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "info_player_allies" ) )

		-- (Old) GMod Maps
		self.SpawnPoints = table.Add( self.SpawnPoints, ents.FindByClass( "gmod_player_start" ) )
			
		-- If any of the spawnpoints have a MASTER flag then only use that one.
			
		for k, v in pairs( self.SpawnPoints ) do
			if ( v:HasSpawnFlags( 1 ) ) then
				self.SpawnPoints = {}
				self.SpawnPoints[1] = v
			end
		end
	end
	
	if not self.SpawnPoints[1] and not self.SpawnPoints.Human and not self.SpawnPoints.Alien then
		fac_Error( 'Map Compiled Incorrectly! Unable to find any usable spawnpoints!' )
		self.SpawnPoints[1] = 1
		return nil
	end
	
	local ChosenSpawnPoint = nil
	for i=0, 6 do
		if not self.SpawnPoints[1] then
			if pl:Team() == TEAM_HUMANS then
				ChosenSpawnPoint = self.SpawnPoints.Human[ math.random( 1, table.getn(self.SpawnPoints.Human) ) ]
			else
				ChosenSpawnPoint = self.SpawnPoints.Alien[ math.random( 1, table.getn(self.SpawnPoints.Alien) ) ]
			end
		end
		ChosenSpawnPoint = ChosenSpawnPoint or self.SpawnPoints[ math.random( 1, table.getn(self.SpawnPoints) ) ]
		
		if ( ChosenSpawnPoint and
			ChosenSpawnPoint:IsValid() and
			ChosenSpawnPoint:IsInWorld() and
			ChosenSpawnPoint ~= pl:GetVar( "LastSpawnpoint" ) and
			ChosenSpawnPoint ~= self.LastSpawnPoint ) then
			
			self.LastSpawnPoint = ChosenSpawnPoint
			pl:SetVar( "LastSpawnpoint", ChosenSpawnPoint )
			
			return ChosenSpawnPoint
		end
	end
	
	return ChosenSpawnPoint
end

----------------------------------------------
-- Auto Team Balance
----------------------------------------------
function GM:BalanceTeams()
	if not Factions.Config.AutoTBDefault then return false end
	
	local bigteam = nil
	local smallteam = nil
	if (team.NumPlayers( TEAM_HUMANS ) - team.NumPlayers( TEAM_ALIENS )) > 1 then
		bigteam = TEAM_HUMANS
		smallteam = TEAM_ALIENS
	elseif (team.NumPlayers( TEAM_ALIENS ) - team.NumPlayers( TEAM_HUMANS )) > 1 then
		bigteam = TEAM_ALIENS
		smallteam = TEAM_HUMANS
	else
		return false
	end
	
	local userids = {}
	for k,v in pairs(player.GetAll()) do
		if v:Team() == bigteam and not v:IsAdmin() then
			userids[ v:UserID() ] = v
		end
	end
	target = userids[ table.maxn( userids ) ]
	
	if not target then return false end
	
	for k, v in pairs(player.GetAll()) do
		Factions.Notify( v, "Teams Unbalanced, Moving " .. target:Nick() .. " To The " .. team.GetName( smallteam ) .. " Team.", "NOTIFY_GENERIC" )
	end
	
	timer.Simple( 1, function() target:ChangeTeam(smallteam, true) end )
	
	return true
end

function GM:CanPlayerJoinTeam( ply, newteam )
	if not Factions.Config.AutoTBDefault then return true end
	
	if ply and newteam then
		local curteam = ply:Team()
		
		if newteam == curteam then return true end
	
		local big = (team.NumPlayers( newteam ) + 1)
		
		local small
		if curteam ~= TEAM_SPECTATOR then
			small = (team.NumPlayers( curteam ) - 1)
		else --player doesn't have a team yet
			if newteam == TEAM_HUMANS then
				curteam = TEAM_ALIENS
			else
				curteam = TEAM_HUMANS
			end
			small = team.NumPlayers( curteam )
		end
		
		if big < 0 then big = 0 end
		if small < 0 then small = 0 end
		
		local diff = big - small
		if diff > 1 then
			return false
		else
			return true
		end
	end
	
	return false
end
