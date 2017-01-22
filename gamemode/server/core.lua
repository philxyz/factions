------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------
local cfgfil
local health

----------------------------------------------------
--  Developer Functions
----------------------------------------------------
--these are functions that fellow lua coders can feel free to call

----------------------------------------------------
--        Others
----------------------------------------------------
--functions that don't really fit anywhere else

function GM:Overwrite()
end

function GM:CanDrive(ply, ent)
	return false
end

function GM:CanProperty(ply, property, ent)
	local isAdmin = ply:IsSuperAdmin() or ply:IsAdmin()
	
	if isAdmin and property == "remover" then return true end
end

function GM:InitPostEntity()
	gamemode.Call( "BuildPlanetsTable" )
	
	local args = Factions.Config.DefaultMode
	if args ~= "Free" and args ~= "War" then
		fac_Error( 'Invalid or unset default mode! Possible values are: "War", or "Free".\nSetting mode to "Free"', "gamemodes/factions/gamemode/config.lua" )
		
		gamemode.Call( "SetMode", "Free", true )
		
		return
	end
	
	gamemode.Call( "SetMode", args, true )
end

function GM:SetMode( mode, quiet )
	if mode ~= "Free" and mode ~= "War" then return end
	if mode == self.Mode and not quiet then return end
	
	fac_Msg("Loading default " ..mode.. " mode settings.")
	
	self.Mode = mode
	
	--SetGlobalString( "fac_Mode", mode )
	Factions.SetNWVar( "Mode", mode ) --garry's global variables are all messed up and buggy so i had to make some of my own that actually work
	
	team.SetScore( TEAM_HUMANS, 0 )
	team.SetScore( TEAM_ALIENS, 0 )
	
	gamemode.Call( "SaveResources" )
	gamemode.Call( "SpawnFlags" )
	
	if Factions.Config.AutoSpawnNPCS then
		gamemode.Call( "RemoveNPCS" )
		gamemode.Call( "SpawnNPCS" )
	end
	
	Factions.DMGVar = Factions.Config.DMGVar

	for _,ply in pairs( player.GetAll() ) do
		if not quiet then
			Factions.Notify( ply, "A server administrator has changed the mode to " .. mode .. ".", "NOTIFY_GENERIC", 8 )
		end
		
		ply:SetNWInt( "Score", 0 )
		ply:SetNWInt( "Planets", 0 )
		
		if mode == "War" then
			for k, v in pairs(SPropProtection["Props"]) do
				for _, plpl in ipairs(player.GetAll()) do
					if(v[1] == plpl:SteamID() and v[2]:IsValid()) then
						v[2]:Remove()
						SPropProtection["Props"][k] = nil
					end
				end
			end
			for k, v in ipairs(player.GetAll()) do
				v:SetFrags(0)
				v:SetDeaths(0)
			end
			Factions.Notify( ply, "Props removed, Money and Rock counts ZEROED (to prevent cheating). The space-race is on!", "NOTIFY_GENERIC", 8 )
			ply:SetNWInt("money", 0)
			ply:SetNWInt( ROCK_GOLD, 0 )
			ply:SetNWInt( ROCK_CHAL, 0 )
			ply:StripWeapons()
			ply:StripAmmo()
		
			local weapons = ply:GetWeapons()
			local ammo    = ply:GetAllAmmo()
			
			plyvar[ ply ].spawnpoint = nil
			ply:Spawn()
			for k,v in pairs(weapons) do
				ply:Give( v:GetClass(), true )
			end
			for k,v in pairs(ammo) do
				ply:GiveAmmo( v, k, true )
			end
			
			self.DisableSaving = true
			PropSpawningAllowed = true
		elseif mode =="Free" then
			if not quiet then
				local u = ply:UniqueID()
				
				if type(plyvar[u]) == "table" and type(plyvar[u].savedres) == "table" then
					ply:SetNWInt("money", plyvar[u].savedres.money)
					ply:SetNWInt( ROCK_GOLD, plyvar[u].savedres.gold )
					ply:SetNWInt( ROCK_CHAL, plyvar[u].savedres.chal )
					
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
			end
			
			self.DisableSaving = false
		end
	end
end

------------------------------------------
--    Planets
------------------------------------------

local flagmodels = {}
flagmodels[ TEAM_ALIENS ] = "models/katharsmodels/flags/flag36.mdl"
flagmodels[ TEAM_HUMANS ] = "models/katharsmodels/flags/flag27.mdl"
flagmodels.neutral        = "models/katharsmodels/flags/flag08.mdl"

function GM:CapturePlanet( ply, flag )
	if self.Mode == "Free" then
		if flag.fac_owner and flag.fac_owner:IsValid() then
			for _,pl in pairs( player.GetAll() ) do
				Factions.Notify( pl, ply:Nick() .. " has stolen " .. flag.fac_owner:Nick() .. "'s planet!" , "NOTIFY_GENERIC", 8, "cool" )
			end
			
			flag.fac_owner:SetNWInt( "Planets", flag.fac_owner:GetNWInt( "Planets" ) - 1 )
			
			if plyvar[ flag.fac_owner ].spawnpoint == flag then plyvar[ flag.fac_owner ].spawnpoint = nil end
		else
			for _,pl in pairs( player.GetAll() ) do
				Factions.Notify( pl, ply:Nick() .. " has captured a planet!" , "NOTIFY_GENERIC", 8, "yeah" )
			end
		end
		
		flag:SetOverlayText( "This Planet Belongs To: " .. ply:Nick() )
		flag.fac_owner = ply
		
		ply:SetNWInt( "Planets", ply:GetNWInt( "Planets" ) + 1 )
		
	elseif self.Mode == "War" then
		local Steam
		local stolen
		if ply:Team() == TEAM_HUMANS then
			Steam = "Humans"
			
			if flag.fac_owner and flag.fac_owner:IsValid() then
				Factions.SetNWVar( "AliensPlanets", Factions.GetNWVar( "AliensPlanets", 0 ) - 1 )
				stolen = "Aliens"
			end
			Factions.SetNWVar( "HumansPlanets", Factions.GetNWVar( "HumansPlanets", 0 ) + 1 )
			
		elseif ply:Team() == TEAM_ALIENS then
			Steam = "Aliens"
			
			if flag.fac_owner and flag.fac_owner:IsValid() then
				Factions.SetNWVar( "HumansPlanets", Factions.GetNWVar( "HumansPlanets", 0 ) - 1 )
				stolen = "Humans"
			end
			Factions.SetNWVar( "AliensPlanets", Factions.GetNWVar( "AliensPlanets", 0 ) + 1 )
		end
		team.AddScore( ply:Team(), 10 )
		flag.fac_owner = ply
		flag.ownerteam = ply:Team()
		
		if flag.homeplanet then
			for _, pl in pairs( player.GetAll() ) do
				Factions.Notify( pl, ply:Nick() .. " has captured the " .. team.GetName( flag.homeplanet ) .. " home planet! All " .. team.GetName( ply:Team() ) .. " receive $1000. Restarting in 30 seconds." , "NOTIFY_GENERIC", 30, "mmmhmm" )
			
				if pl:Team() == ply:Team() then
					pl:AddMoney(1000)
				end
			end
			
			timer.Simple( 30, function() gamemode.Call("SetMode", "War", true) end )
			
			Factions.DMGVar = DMG_GODMODE
			
			return
		end
	
		for _,pl in pairs( player.GetAll() ) do
			if not stolen then
				Factions.Notify( pl, ply:Nick() .. " has captured a planet for the " .. Steam .. "!" , "NOTIFY_GENERIC", 8, "eyep" )
			else
				Factions.Notify( pl, ply:Nick() .. " has stolen a planet from the " .. stolen .. " for the " .. Steam .. "!" , "NOTIFY_GENERIC", 8, "yeah, why not" )
			end
		end
		
	end
	
	umsg.Start( "ChooseSPName", ply )
		umsg.Short( flag:EntIndex() )
	umsg.End()
	
	flag:SetModel( flagmodels[ ply:Team() ] )
	ply:SetNWInt( "Score", ply:GetNWInt( "Score" ) + 10 )
end

function GM:BuildPlanetsTable()
	print("Calling BuildPlanetsTable()")

	self.fac_Planets = {}

	local fac_Planets = self.fac_Planets --because I can

	if CAF ~= nil then
		-- Spacebuild 3 or 4
		local SBEnvs = CAF.GetAddon("Spacebuild").GetPlanets()
		for k,v in pairs(SBEnvs) do
			local p = (v.GetPos and v.GetPos()) or v:getPosition() -- GetPos() = SB3, getPosition = SB4
			table.insert(fac_Planets, {pos = p, radius = (v.size or v.radius)}) -- size = SB3, radius = SB4
			print("Found " .. ((v.GetPos and "SB3 Planet") or (v.getPosition and "SB4 Environment")) .. " of radius " .. (v.GetPos and tostring(v.size) or (v.getPosition and tostring(v.radius))))
		end
	else
		-- Scan the first 40 environments for planets (Spacebuild 2)
		for k=1, 40 do
			local x, isPlanet, _pos, _rad = SB_Get_Environment_Info(k)
			if isPlanet then table.insert(fac_Planets, {pos = _pos, radius = _rad}) end
		end
	end
	
	for k,p in pairs(fac_Planets) do
		local sphere_ents = ents.FindInSphere( p.pos, p.radius )

		for _,ent in pairs( sphere_ents ) do
			local class = ent:GetClass()
			
			if string.find( class, "info_spawn" ) then
				p.homePlanet = string.gsub( class, "info_spawn_", "" )
			end
			
			if class == "fac_flag" then
				p.flagSpawn = ent:GetPos() + Vector( 0,0,50 )
			end
			
			if p.homePlanet and p.flagSpawn then break end
		end
	end
	
	self.fac_Planets = fac_Planets
end

function GM:SpawnFlags() --spawn capture flags on planets
	if self.flags then
		for _,flag in pairs( self.flags ) do
			if flag:IsValid() then
				flag:Remove()
			end
		end
	end
	self.flags = {}
	self.planetInfos = {}
	
	Factions.SetNWVar( "AlienPlanets", 1 )
	Factions.SetNWVar( "HumanPlanets", 1 )

	for k, p in pairs(self.fac_Planets) do
		local sphere_ents = ents.FindInSphere( p.pos, p.radius )

		if not p.homePlanet then
			p.flag = ents.Create( "flag" )

			if p.flagSpawn then
				p.flag:SetPos(p.flagSpawn)
				p.flag:Spawn()
				p.flag:Activate()
				p.flag:GetPhysicsObject():EnableMotion(false)
				p.flag.frozen = true
			else
				p.flag:SetPos(p.pos + Vector(0, 0, 1000))

				p.flag:Spawn()
				p.flag:Activate()
			end

			table.insert( self.flags, p.flag )
		else
			if self.Mode == "War" then
				p.flag = ents.Create( "flag" )

				if p.flagSpawn then
					p.flag:SetPos( p.flagSpawn )
					p.flag:Spawn()
					p.flag:Activate()
					p.flag:GetPhysicsObject():EnableMotion( false )
					p.flag.frozen = true
					p.flag.spawnname = "Home Planet"
				else
					p.flag:SetPos(p.pos + Vector(0, 0, 1000))

					p.flag:Spawn()
					p.flag:Activate()
				end

				if p.homePlanet == "alien" then
					p.flag.homeplanet = TEAM_ALIENS
				elseif p.homePlanet == "human" then
					p.flag.homeplanet = TEAM_HUMANS
				end

				p.flag:SetModel( flagmodels[ p.flag.homeplanet ] )
				p.flag.color = team.GetColor( p.flag.homeplanet )

				table.insert( self.flags, p.flag )
			end
		end
	end
end

function GM:SpawnNPCS()
	self.npcs = self.npcs or {}

	for k, p in pairs(self.fac_Planets) do
		if not p.homePlanet then
			local npcGroup = math.random(1, table.Count(Factions.Config.planetNPCS))
			local tbl = Factions.Config.planetNPCS[npcGroup]
			
			for npcClass,amt in pairs( tbl.npcs ) do
				for i=1, amt do
					local NPCData = list.Get( "NPC" )[ npcClass ]
					local npc = ents.Create( NPCData.Class )
					
					if IsValid( npc ) then
						npc:SetPos( Vector( math.Rand( p.pos.x - (p.radius / 2), p.pos.x + (p.radius / 2) ), math.Rand( p.pos.y - (p.radius / 2), p.pos.y + (p.radius / 2) ), p.pos.z + 1000 ) )
							
						--garry's stuff that i'm using from sandbox/gamemode/commands.lua
						if ( NPCData.Model ) then
							npc:SetModel( NPCData.Model )
						end
						local SpawnFlags = bit.bor(SF_NPC_FADE_CORPSE, SF_NPC_ALWAYSTHINK)
						if ( NPCData.SpawnFlags ) then SpawnFlags = bit.bor(SpawnFlags, NPCData.SpawnFlags) end
						if ( NPCData.TotalSpawnFlags ) then SpawnFlags = NPCData.TotalSpawnFlags end
						npc:SetKeyValue( "spawnflags", SpawnFlags )
						if ( NPCData.KeyValues ) then
							for k, v in pairs( NPCData.KeyValues ) do
								npc:SetKeyValue( k, v )
							end		
						end
						if ( NPCData.Skin ) then
							npc:SetSkin( NPCData.Skin )
						end
						--

						if tbl.weapons and tbl.weapons[npcClass] then
							npc:SetKeyValue( "additionalequipment", tbl.weapons[npcClass] )
						end

						npc:Spawn()
						npc:Activate()
						npc:DropToFloor()
							
						table.insert(self.npcs, npc)
					end
				end
			end
		end
	end
	
	for k,npc in pairs(self.npcs) do
		if SPACEBUILD and npc.grav == 0 then --SB1
			npc:Remove()
			self.npcs[k] = nil
			fac_Debug( "removing " .. npc:GetClass() .. " (" ..tostring(npc).. "), npc not found on a planet!")
		end
		if SPACEBUILD2 and not SB_OnEnvironment(npc:GetPos()) then --SB2
			npc:Remove()
			self.npcs[k] = nil
			fac_Debug( "removing " .. npc:GetClass() .. " (" ..tostring(npc).. "), npc not found on a planet!")
		end
		if SPACEBUILD3 then
			fac_Error("no known spacebuild 3 on-planet check", "sv_core: SpawnNPCS")
		end
	end
end

function GM:RemoveNPCS()
	self.npcs = self.npcs or {}

	for _,npc in pairs(self.npcs) do
		if npc:IsValid() then
			npc:Remove()
		end
	end
end

--------------------------------------
-- Rock Handlers
--------------------------------------

local ALLSMALLROCKS = {}
function Factions.SortRocks()

	local human_points = ents.FindByClass( "rock_human" )
	local alien_points = ents.FindByClass( "rock_alien" )
	if not alien_points[1] or not human_points[1] then return end
	
	local sphereEnts = {}
	ROCKS = ROCKS or {}
	ROCKS.human = ROCKS.human or {}
	ROCKS.alien = ROCKS.alien or {}
	
	local internal_human_rocks = {}
	local internal_alien_rocks = {}
	for k,v in pairs(human_points) do
		table.insert( internal_human_rocks, ents.FindInSphere( v:GetPos(), 500 ) )
	end
	for k,v in pairs(alien_points) do
		table.insert( internal_alien_rocks, ents.FindInSphere( v:GetPos(), 500 ) )
	end
	local allrocks = ents.FindInBox( Vector(-16384, -16384, -16384), Vector(16383, 16383, 16383) )
	
	for a,b in pairs(internal_human_rocks) do
		for k,v in pairs(internal_human_rocks[a]) do
			if string.find( v:GetClass(), "stone" ) then
				if v:GetType() ~= 2 then
					v:SetType( 0 )
					
					ROCKS.human[ v:EntIndex() ] = v
				end
			end
		end
	end
	
	for a,b in pairs(internal_alien_rocks) do
		for k,v in pairs(internal_alien_rocks[a]) do
			if string.find( v:GetClass(), "stone" ) then
				if v:GetType() ~= 2 then
					v:SetType( 1 )
					
					ROCKS.alien[ v:EntIndex() ] = v
				end
			end
		end
	end
	
	for k,v in pairs(allrocks) do
		if string.find( v:GetClass(), "stone" ) then
			if v:GetClass() == "stone_small" then
				ALLSMALLROCKS[ v:EntIndex() ] = v
			end
			if not v:GetType() then
				v:SetType( 2 )
			end
		end
	end
	
	for a,b in pairs(ROCKS) do --invalid rocks check
		for k,v in pairs(ROCKS[a]) do
			if not v:IsValid() then
				ROCKS[a][k] = nil
			else
				--check if the rock is floating around in space
				if v.grav == 0 then --SB1
					ROCKS[a][k] = nil
				end
				if SPACEBUILD2 and not SB_OnEnvironment(v:GetPos()) then --SB2
					ROCKS[a][k] = nil
				end
				if SPACEBUILD3 then
					fac_Error("no known spacebuild 3 on-planet check", "sv_core: Factions.SortRocks")
				end
			end
		end
	end
	
	Factions.CheckRockRespawn()
end

local RespawnWait = 0
local rockSpawnLimit = 0
function Factions.CheckRockRespawn()

	values = {}
	values.human = 0
	values.alien = 0
	
	local rtype = {}
	rtype.human = 0
	rtype.alien = 1
	
	for a,b in pairs(ROCKS) do
		local SmallRocks = {}
		
		for k,v in pairs(b) do
			if not v:IsValid() then
				table.remove( b, k )
			else
				values[a] = values[a] + v:GetValue()
				SmallRocks[ v:EntIndex() ] = v
			end
		end
		
		if values[a] < Factions.Config.RockRegenMinimumRockValue and RespawnWait < CurTime() and (not Factions.Config.LimitTheBigRocks or (Factions.Config.LimitTheBigRocks and Factions.Config.BigRockSpawnLimit < 3)) then
			local spawnpoints = ents.FindByClass( "rock_" .. a )
			
			local spawnpoint = spawnpoints[ math.random( 1, table.Count( spawnpoints ) ) ]
			if not spawnpoint then fac_Debug("No usable rock spawnpoints, returning") return end
			
			fac_Debug("Rocks are low, spawning another " .. tostring(a) .. " rock.")
			local rock = ents.Create( "stone_large" )
					
			rock:SetType( rtype[a] )
			rock:SetPos( spawnpoint:GetPos() + Vector( 0, 0, 1500 ) )
			rock:Spawn()
			rock:Activate()
			
			values[a] = values[a] + 80
			ROCKS[a][ rock:EntIndex() ] = rock
			
			Factions.Config.BigRockSpawnLimit = Factions.Config.BigRockSpawnLimit + 1
			RespawnWait = CurTime() + Factions.Config.RockRegenRespawnWait
		end
		
		if table.Count( SmallRocks ) > Factions.Config.MaxTeamSmallRocks then
			fac_Debug( "Max Team Small Rocks Exceeded By " ..tostring( table.Count( SmallRocks ) - Factions.Config.MaxTeamSmallRocks ) )
			local num = 0
			for var = 1, ( table.Count( SmallRocks ) - Factions.Config.MaxTeamSmallRocks ) do
				
				for k,v in pairs( ROCKS[a] ) do
					if v:IsValid() and v:GetClass() == "stone_small" then
						if num >= var then break end
						
						--fac_Debug( "Removing " ..tostring(v) )
						v:Remove()
						table.remove( ROCKS[a], k )
						
						num = num + 1
						
						break
					end
				end
			end
		end
	end
	
	for k,v in pairs( ALLSMALLROCKS ) do
		if not v:IsValid() then
			ALLSMALLROCKS[k] = nil
		end
	end
	
	if table.Count( ALLSMALLROCKS ) > Factions.Config.MaxSmallRocks then
		fac_Debug( "Max Universal Small Rocks Exceeded By " ..tostring( table.Count( ALLSMALLROCKS ) - Factions.Config.MaxSmallRocks ) )
		
		local num = 0
		for var = 1, ( table.Count( ALLSMALLROCKS ) - Factions.Config.MaxSmallRocks ) do
		
			for k,v in pairs( ALLSMALLROCKS ) do
				if v:IsValid() then
					if num >= var then break end
							
					v:Remove()
					table.remove( ALLSMALLROCKS, k )
							
					num = num + 1
					
					break
				end
			end
		end
	end
end
timer.Create( "[FAC] RockRegen", 10, 0, Factions.SortRocks )

function GM:PlayerSay( ply, text, toall )
	-- This function clobbers Spacebuild 2 and 3 code, here is the replacement
	--self.BaseClass:PlayerSay( ply, text, toall )
	if ply:IsAdmin() then
		if (string.sub(text, 1, 10 ) == "!freespace") then
			self:RemoveSBProps()
			return text
		elseif (string.sub(text, 1, 10 ) == "!freeworld") then
			self:RemoveSBProps(true)
			return text
		end
	end
	-- End Spacebuild Code
	
	if string.sub( text, 1, 5 ) == "!help" then
		ply:ChatPrint("Open your console for a list of available chat commands.")
		ply:PrintConsole("Available Chat Commands:")
		ply:PrintConsole("!drop number$,c,g   drops a resource in a suitcase")
		ply:PrintConsole("!radiofreq number   sets your radio frequency")
		ply:PrintConsole("//text              talk in radio chat on frequency set by !radiofreq")
		ply:PrintConsole("/text               local chat in a radius of " ..Factions.Config.LocalChatArea)
		if ply:IsAdmin() then
			ply:PrintConsole("!forcealien player  forces a player to the alien team (admin only)")
			ply:PrintConsole("!forcehuman player  forces a player to the human team (admin only)")
			ply:PrintConsole("!removenpcs         removes all npcs from the map" )
		end
		
		return text
	end

	if string.sub( text, 1, 5 ) == "!drop" then
		ply:ConCommand( 'fac_drop ' ..string.sub( text, 7 ).. '\n' )
		
		return text
	end
	
	if string.sub( text, 1, 12 ) == "!forcealien " then
		if not ply:IsAdmin() then
			Factions.Notify( ply, "That Command Is Admin Only, " ..ply:Nick(), "NOTIFY_ERROR" )
			
			return ""
		end
	
		local text2 = string.sub( text, 13 )
		
		if not text2 or text2 == "" then return text end
		
		local victim = Factions.GetPlayerFromString( text2 )
		if not victim then
			Factions.Notify( ply, "No Matching Players", "NOTIFY_ERROR" )
			
			return ""
		end
		
		victim:ChangeTeam( TEAM_ALIENS )
		
		return text
	end
	
	if string.sub( text, 1, 12 ) == "!forcehuman " then
		if not ply:IsAdmin() then
			Factions.Notify( ply, "That Command Is Admin Only, " ..ply:Nick(), "NOTIFY_ERROR" )
			
			return ""
		end
	
		local text2 = string.sub( text, 13 )
		
		if not text2 or text2 == "" then return text end
		
		local victim = Factions.GetPlayerFromString( text2 )
		if not victim then
			Factions.Notify( ply, "No Matching Players", "NOTIFY_ERROR" )
			
			return ""
		end
		
		victim:ChangeTeam( TEAM_HUMANS )
		
		return text
	end
	
	if string.lower(string.sub( text, 1, 1 )) == "!removenpcs" then
		if not ply:IsAdmin() then
			Factions.Notify( ply, "That Command Is Admin Only, " ..ply:Nick(), "NOTIFY_ERROR" )
			
			return ""
		end
		
		gamemode.Call("RemoveNPCS")
		
		return text
	end
	
	if string.sub( text, 1, 11 ) == "!radiofreq " then
		local freq = string.sub( text, 12 )
		freq = tonumber(freq)
		
		if not freq then return "" end
		
		if freq > 120 or freq < 50 then
			ply:ChatPrint( "[FAC] Radio Frequencys Must Be Between 50 and 120." )
			return ""
		end
		
		freq = math.Round( freq * 10 ) / 10 --round it to 1 decimal place
		
		ply.RadioFreq = freq
		
		ply:ChatPrint( "[FAC] Radio Frequency Set To " ..freq )
		
		return ""
	end
	
	-- Team Chat
	if not toall then
		if not game.SinglePlayer() then
			Msg( ply:Name() .. " (TEAM): " .. text .. '\n' )
		end
		for k,v in pairs( player.GetAll() ) do
			if v:Team() == ply:Team() then
				v:ChatPrint( ply:Name() .. " (TEAM): " .. text )
			end
		end
		
		return ""
	end
	
	-- Radio
	if string.sub( text, 1,2 ) == "//" then
		ply.RadioFreq = ply.RadioFreq or 98.1
		
		if not game.SinglePlayer() then
			Msg( ply:Name() .. " (RADIO " ..ply.RadioFreq.. "): " .. string.sub( text, 3 ) .. '\n' )
		end
		
		for k,v in pairs( player.GetAll() ) do
			if v.RadioFreq == ply.RadioFreq then
				v:ChatPrint( ply:Name() .. " (RADIO " ..ply.RadioFreq.. "): " .. string.sub( text, 3 ) )
			end
		end
		
		return ""
	end
	
	-- Local Chat
	if string.sub( text, 1, 1 ) == "/" then
		if not game.SinglePlayer() then
			Msg( ply:Name() .. " (LOCAL): " ..string.sub( text, 2 ).. "\n" )
		end
			
		for k,v in pairs( ents.FindInSphere( ply:GetPos(), Factions.Config.LocalChatArea ) ) do
			if v:IsValid() and v:IsPlayer() then
				v:ChatPrint( ply:Name() .. " (LOCAL): " .. string.sub( text, 2 ) )
			end
		end
		
		return ""
	end
		
	return text
end

------------------------------------
-- Disply Menus
------------------------------------

function GM:ShowHelp( ply ) --f1
	local helpmenu = ply:GetNWBool( "showhelp" )
	if helpmenu then
		umsg.Start("fac_hidehelpmenu", ply)
		umsg.End()
	else
		umsg.Start("fac_showhelpmenu", ply)
		umsg.End()
	end
	ply:SetNWBool( "showhelp", not helpmenu )
end

function GM:ShowTeam( ply ) --f2
	ply:SetNetworkedInt( "Menu", 0 )
	if ply:GetNetworkedBool( "f2" ) then
		ply:SetNetworkedBool( "f2", false )
		umsg.Start("fac_hideteammenu", Player)
		umsg.End()
	else
		ply:SetNetworkedBool( "f2", true )
		umsg.Start("fac_showteammenu", ply)
		umsg.End()
	end
end

function GM:ShowSpare1( ply ) --f3
	if ply:GetNWBool( "showtrader" ) then
		ply:SetNWBool( "showtrader", false )
		umsg.Start("fac_hidetrademenu", ply)
		umsg.End()
		return
	end
	
	local trading = ply:GetNWBool( "AwaitingTrade" )
	if trading and plyvar[ply].tradepartner then
		plyvar[ply].tradepartner:SetNWBool( "AwaitingTrade", false )
		ply:SetNWBool( "AwaitingTrade", false )
		local table = { plyvar[ply].tradepartner:UserID() }
		table.page = 2
		
		umsg.Start( "TradePartnerReady", plyvar[ply].tradepartner )
		umsg.End()
		
		umsg.Start( "fac_showtrademenu", ply )
			umsg.String( util.TableToKeyValues( table ) )
		umsg.End()
		ply:SetNWBool( "showtrader", true )
		return
	end

	local sphereEnts = ents.FindInSphere( ply:GetPos(), 200 )
	for k, v in pairs(sphereEnts) do
		if v:IsPlayer() and v:IsValid() and v ~= ply then
		else
			sphereEnts[k] = nil
		end
	end
	if table.Count(sphereEnts) == 0 or not table.Count(sphereEnts) then
		Factions.Notify( ply, "There are no nearby players to trade with.", "NOTIFY_ERROR" )
		return
	else
		local players = {}
		for k,v in pairs(sphereEnts) do
			table.insert( players, v:UserID() )
		end
		players.page = {}
		players.page = 1
		sphereEnts = nil
		umsg.Start("fac_showtrademenu", ply)
			umsg.String(util.TableToKeyValues(players))
		umsg.End()
		ply:SetNWBool( "showtrader", true )
	end
end

function GM:ShowSpare2( ply ) --f4
	if ply:Alive() and ply:Team() ~= TEAM_SPECTATOR then --buy weapons
		swepmenu = ply:GetNWBool( "showswep" )
		if swepmenu then
			umsg.Start("hideswepmenu", ply)
			umsg.End()
		else
			umsg.Start("showswepmenu", ply)
			umsg.End()
		end
		ply:SetNWBool( "showswep", not swepmenu )
	else --choose spawnpoint
		spawnmenu = ply:GetNWBool( "spawnmenu" )
		if spawnmenu then
			umsg.Start("fac_hidespawnmenu", ply)
			umsg.End()
		else
			local flags = gmod.GetGamemode().flags
			local spawns = {}
			
			table.insert( spawns, "Home Planet" )
			
			for _,flag in pairs( flags ) do
				if flag.spawnname and ( flag.fac_owner == ply or flag.homeplanet == ply:Team() or ( Factions.GetNWVar( "Mode" ) == "War" and flag.ownerteam == ply:Team() ) ) then
					if flag.spawnname ~= "Home Planet" then
						table.insert( spawns, flag.spawnname )
					end
				end
			end
		
			umsg.Start( "fac_showspawnmenu", ply )
				umsg.String( util.TableToKeyValues( spawns ) )
			umsg.End()
		end
		ply:SetNWBool( "spawnmenu", not spawnmenu )
	end
end

--------------------------------------------------------
-- Player Combat Handlers
--------------------------------------------------------

function GM:PlayerShouldTakeDamage( ply, attacker )

	-- Global godmode, players can't be damaged in any way
	if  Factions.DMGVar == DMG_GODMODE then return false end

	-- player vs player damage
	if ( attacker:IsValid() and attacker:IsPlayer() ) then
		if ply == attacker then
			return true
		elseif Factions.DMGVar == DMG_PLYOFF then
			return false
		elseif Factions.DMGVar == DMG_ALL and not Factions.FF then
			if attacker:Team() == ply:Team() then
				return false
			else
				return true
			end
		end
	end
	
	-- Default, let the player be hurt
	return true

end

function Factions.DoPlayerDeath( ply, attker )
	--make the suitcase, set it's resources
		local ore = math.Clamp( ply:GetNWInt("rock0"), 0, Factions.Config.MaxDropChalc )
		local gold = math.Clamp( ply:GetNWInt("rock1"), 0, Factions.Config.MaxDropGold )
		local money = math.Round( math.Clamp( ply:GetNWInt("money") / 2, 0, Factions.Config.MaxDropMoney ) )
		local items = ents.Create("item")
		
		items:SetResource( "rock0", ore )
		items:SetResource( "rock1", gold )
		items:SetResource( "money", money )
		items:SetResource( "owner", ply )
		
		for k,v in pairs(ply:GetWeapons()) do
			items:AddWeapon( v:GetClass() )
		end
		for k,v in pairs(ply:GetAllAmmo()) do
			items:SetAmmo( k, v )
		end
		
		ply:AddMoney(-money)
		ply:SetNWInt( ROCK_GOLD, ply:GetNWInt( ROCK_GOLD ) - gold )
		ply:SetNWInt( ROCK_CHAL, ply:GetNWInt( ROCK_CHAL ) - ore )
		
		items:SetPos(ply:GetPos() + Vector(0,0,10))
		items:Spawn()
		items:Activate()
	
	umsg.Start( "DrawNotice", ply )
		umsg.String( "rock1" )
		umsg.Short( -gold )
	umsg.End()
	
	umsg.Start( "DrawNotice", ply )
		umsg.String( "rock0" )
		umsg.Short( -ore )
	umsg.End()
	
	umsg.Start( "DrawNotice", ply )
		umsg.String( "$" )
		umsg.Short( -money )
	umsg.End()
	
	ply:StripWeapons()
	ply:StripAmmo()
	
	local mode = Factions.GetNWVar( "Mode", "" )
	if mode == "War" and attker:IsPlayer() and attker:Team() ~= ply:Team() then
		team.AddScore( attker:Team(), 1 )
		
		attker:SetNWInt( "Score", attker:GetNWInt( "Score" ) + 1 )
		
	elseif mode == "War" and attker:IsPlayer() and attker:Team() == ply:Team() then
		team.AddScore( attker:Team(), -1 )
		
		attker:SetNWInt( "Score", attker:GetNWInt( "Score" ) - 1 )
		
	end
	
	plyvar[ply].Active = false
	
	
	ply:ModifyScreenColor( Color( -255, -255, -255 ), true )
	
	umsg.Start( "DrawRespawnTimer", ply )
		umsg.Short( Factions.Config.PlayerRespawnTime )
	umsg.End()
	
	ply:Lock()
	timer.Simple( Factions.Config.PlayerRespawnTime + 0.1, function() ply:Spawn() end )
	timer.Simple( Factions.Config.PlayerRespawnTime, function() ply:UnLock() end )
end
hook.Add("DoPlayerDeath", "[FAC] Factions.DoPlayerDeath", Factions.DoPlayerDeath)
