------------------------------------------
-- Spacebuild Factions
-- Team Ring-Ding
------------------------------------------

function GM:SaveResources()
	if not self.DisableSaving then
		for k,v in pairs(player.GetAll()) do
			if plyvar[v].InitTeamSpawn then
				local u = v:UniqueID()

				plyvar[u] = plyvar[u] or {}
				plyvar[u].savedres = plyvar[u].savedres or {}
				plyvar[u].savedres.gold = v:GetNWInt(ROCK_GOLD)
				plyvar[u].savedres.chal = v:GetNWInt(ROCK_CHAL)
				plyvar[u].savedres.money = v:Money()
				plyvar[u].savedres.lastsave = CurTime()
				plyvar[u].savedres.weapons = {}

				for k,v in pairs( v:GetWeapons() ) do
					plyvar[u].savedres.weapons[k] = v:GetClass()
				end

				plyvar[u].savedres.ammo = v:GetAllAmmo()

				if plyvar[u].lastres ~= util.TableToKeyValues( plyvar[u].savedres ) then -- let's not save unless we have to
					file.Write( "factions/clientdata/" ..Factions.ConvertID( v ).. ".txt", util.TableToKeyValues( plyvar[u].savedres ))
				end

				plyvar[u].lastres = util.TableToKeyValues( plyvar[u].savedres )
			end
		end
	end
end

function Factions.Paychecks()
	local mode = Factions.GetNWVar( "Mode" )
	local flags = gmod.GetGamemode().flags
	
	if mode == "War" then --team based pay
		local Oflags = {}
		Oflags[ TEAM_HUMANS ] = {}
		Oflags[ TEAM_ALIENS ] = {}

		for _,flag in pairs( flags ) do
			if flag.fac_owner and flag.fac_owner:Team() == flag.ownerteam then
				flag.fac_owner:SetNWInt( "Score", flag.fac_owner:GetNWInt( "Score" ) + 4 )
				team.AddScore( flag.fac_owner:Team(), 4 )
							
				Oflags[ flag.fac_owner:Team() ][ flag:EntIndex() ] = flag
			elseif flag.fac_owner then
				team.AddScore( flag.ownerteam, 4 )
							
				Oflags[ flag.ownerteam ][ flag:EntIndex() ] = flag
			end
		end
		
		local Aamt = table.Count( Oflags[ TEAM_ALIENS ] )
		local Hamt = table.Count( Oflags[ TEAM_HUMANS ] )
		
		for _,ply in pairs( player.GetAll() ) do
			if ply:Team() == TEAM_HUMANS and Hamt > 0 then
				Factions.Notify( ply, "You have received $" .. Hamt*Factions.Config.PlanetIncome .. " for the " .. Hamt .. " planets that your team owns.", NOTIFY_GENERIC, 8 )
				ply:AddMoney(Hamt*Factions.Config.PlanetIncome)
			elseif ply:Team() == TEAM_ALIENS and Aamt > 0 then
				Factions.Notify( ply, "You have received $" .. Aamt*Factions.Config.PlanetIncome .. " for the " .. Aamt .. " planets that your team owns.", NOTIFY_GENERIC, 8 )
				ply:AddMoney(Aamt*Factions.Config.PlanetIncome)
			end
		end
			
	elseif mode == "Free" then --single based pay
		for _, pl in pairs( player.GetAll() ) do
			plyvar[ pl ].flags = 0
		end
		for _,flag in pairs( flags ) do
			if flag.fac_owner then
				plyvar[ flag.fac_owner ].flags = plyvar[ flag.fac_owner ].flags + 1
			end
		end
				
		for _,ply in pairs( player.GetAll() ) do
			if (plyvar[ ply ].flags or 0) > 0 then
				Factions.Notify( ply, "You have received $" .. plyvar[ ply ].flags*Factions.Config.PlanetIncome .. " for the " .. plyvar[ ply ].flags .. " planets that you own.", "NOTIFY_GENERIC", 8 )
							
				ply:AddMoney(plyvar[ ply ].flags*Factions.Config.PlanetIncome)
			end
			
			plyvar[ ply ].flags = 0
		end
	end
end
timer.Create( "Factions.Paychecks", 80, 0, Factions.Paychecks )

----------------------------------------------------
--       Utility
----------------------------------------------------

function Factions.AuthorizeEntPurchase( ply, e, ClassName )
	ply.fac_AuthorizedEnts = ply.fac_AuthorizedEnts or {}
	ply.fac_AuthorizedEnts.Ents = ply.fac_AuthorizedEnts.Ents or {}
	ply.fac_AuthorizedEnts.Models = ply.fac_AuthorizedEnts.Models or {}
	ply.fac_AuthorizedEnts.Classnames = ply.fac_AuthorizedEnts.Classnames or {}
	
	if type(e) == "Entity" then
		table.insert( ply.fac_AuthorizedEnts.Ents, e )
	elseif type(e) == "string" then
		table.insert( ply.fac_AuthorizedEnts.Models, string.lower(e) )
	elseif type(ClassName) == "string" then
		table.insert( ply.fac_AuthorizedEnts.Classnames, string.lower(ClassName) )
	end
end

function Factions.IsEntAuthorized( ply, e, removeFromTable, ClassName )
	ply.fac_AuthorizedEnts = ply.fac_AuthorizedEnts or {}
	ply.fac_AuthorizedEnts.Ents = ply.fac_AuthorizedEnts.Ents or {}
	ply.fac_AuthorizedEnts.Models = ply.fac_AuthorizedEnts.Models or {}
	ply.fac_AuthorizedEnts.Classnames = ply.fac_AuthorizedEnts.Classnames or {}
	
	if type(e) ~= "string" and e then
		for k,v in pairs( ply.fac_AuthorizedEnts.Ents ) do
			if v == e then
				if removeFromTable then
					ply.fac_AuthorizedEnts.Ents[k] = nil
				end
				
				return true
			end
		end
		
		return Factions.IsEntAuthorized( ply, e:GetModel(), removeFromTable, e:GetClass() )
	elseif e then
		e = string.lower(e)
	
		for k,v in pairs( ply.fac_AuthorizedEnts.Models ) do
			if v == e then
				if removeFromTable then
					ply.fac_AuthorizedEnts.Models[k] = nil
				end
				
				return true
			end
		end
	end
	
	if e and not ClassName then ClassName = e end
		
	if type(ClassName) == "string" then
		ClassName = string.lower(ClassName)
		
		for k,v in pairs( ply.fac_AuthorizedEnts.Classnames ) do
			if v == ClassName or ClassName == "gmod_" .. v then
				if removeFromTable then
					ply.fac_AuthorizedEnts.Classnames[k] = nil
				end
				
				return true
			end
		end
	end
	
	return false
end

local commonProps = {}
commonProps["prop_physics"] = Factions.Config.EntityCosts.props
commonProps["prop_vehicle"] = Factions.Config.EntityCosts.vehicles
commonProps["prop_ragdoll"] = Factions.Config.EntityCosts.ragdolls
commonProps["prop_effect"] = Factions.Config.EntityCosts.effects
commonProps["npc_"] = Factions.Config.EntityCosts.npcs
commonProps["weapon_"] = Factions.Config.EntityCosts.sweps

--scenario  1:  cost, costcharge, adminNotify, ClassNames, entsOrModels
--scenario 2: false, handlerFunc, { handlerFunc args }
--may return nil for all variables
--returns the cost for using a stool. ply,  stool, trace, leftclick and rightclick are optional. if ply and the player can use it, then it returns the total cost of everything (including duplications)
--and if its a duplication returns a second argument, costcharge, which is the actual amount to charge the player
--if we are allowing a player to do something because he is an admin it returns the notify to display to the admin as a third return value
--cost may return nil if its unable to figure out the cost of something (especially if ply is not given)
--if the ply and the player is not able to use it (might be restricted, or his args arent within min and max values) it returns false, the recommended function to display the error, and the arguments for this function in a table (use unpack)
function Factions.GetStoolCost( mode, ply, stool, trace, leftclick, rightclick )
	local cost
	local costCharge
	local adminNotify
	local ClassNames = {}
	local entsOrModels = {}
	
	local etype = "NOTIFY_ERROR"
	if ply and ply:IsAdmin() then etype = "NOTIFY_GENERIC" end

	if ply and mode == "adv_duplicator" then

		--special rules
		
		local advDup = stool:GetTable().Tool.adv_duplicator
		--grab the advDup table

		if not advDup.Entities or advDup:GetPasting() or not leftclick then return end --not gonna spawn anything
		
		cost  = Factions.GetEntitiesCost( advDup.Entities )
		costCharge = Factions.GetEntitiesCost( advDup.Entities, true )

		for k,v in pairs( advDup.Entities ) do
			local found
			for kk,vv in pairs(commonProps) do
				kk = string.lower(kk)
				
				if kk == string.lower(v.Class) or string.find(string.lower(v.Class),kk,nil,true) then
					found = true
					break
				end
			end
			
			if not found then
				table.insert(ClassNames,v.Class)
			end
		end

	elseif ply and mode == "duplicator" then
		local ents = ply:UniqueIDTable( "Duplicator" ).Entities --grab entities duplicator wants to paste

		if not ents or not leftclick then return end --not gonna spawn anything
	
		cost  = Factions.GetEntitiesCost( ents )
		costCharge = Factions.GetEntitiesCost( ents, true )
		
		for k,v in pairs( ents ) do
			table.insert(entsOrModels, v)
		end
		
	elseif ply and mode == "ol_stacker" then

		local stacker = stool:GetTable().Tool.ol_stacker

		local amt = stacker:GetClientNumber( "count" ) --how many is it going to spawn

		if ( not stacker:GetSWEP():CheckLimit( "props" ) ) or amt <= 0 then return end --not gonna spawn anything
		
		local ents = {}
		for k=1,amt do
			table.insert(entsOrModels, trace.Entity:GetModel())
			table.insert(ents, trace.Entity)
		end
		
		cost = Factions.GetEntitiesCost(ents)

	else
		--run through our stools table generated at GM:InitPostEntity

		local function dump(t, indnt)
			if indnt == nil then indnt = 0 end
			local tabs = ""
			for i=1, indnt do
				tabs = tabs .. " "
			end

			for k, v in pairs(t) do
				if type(k) == "table" then
				elseif (type(k) == "string" or type(k) == "number") and (type(v) == "string" or type(v) == "number") then
					print(tostring(k) .. ": " .. tostring(v))
				else
					dump(v, indnt + 1)
				end
			end
		end

		dump(fac_Stools)

		for m, tbl in pairs(fac_Stools) do

			if m == mode then
				local ClassName = m --the ClassName of the entity this stool is going to spawn

				if ply and tbl["type"] then --is it a combination stool?

					local found = false

					for typ, tbl2 in pairs(tbl.type) do
						if tbl.type.var and tbl.type.var ~= "" then
							local info = ply:GetInfo( mode .."_" .. tbl.type.var )

							if info == typ then
								tbl = tbl2
								ClassName = typ
								found = true
								break
							end
						end
					end
					if not found then
						return false, fac_Msg, { "var found in " .. mode .. ".type but unable to find a matching type for " .. tostring(ply:GetInfo( mode .."_" .. tbl["type"].var )) .. ". Error will occur as a result unless a default cost is set." }
					end
				end
				
				if tbl.ClassName then
					ClassName = tbl.ClassName
				end
				
				if ply and tonumber(tbl.restricted) == 1 then --restricted?

					if ply:IsAdmin() then
						adminNotify = "You are using a restricted stool, admin."
					else
						return false, Factions.Notify, { ply, "That Tool Is Restricted.", etype }
					end
				end
				
				if ply and type(tbl.restrictions) == "table" then --within acceptable values?

					for restrict,Tbl in pairs(tbl.restrictions) do

						
						if type(Tbl) == "table" and type(restrict) == "string" then

							local info = ply:GetInfo( mode .."_" .. restrict )


							if info and tonumber(info) then

								if Tbl.max and tonumber(Tbl.max) then

									if tonumber(info) > tonumber(Tbl.max) then
										adminNotify = "Your " .. mode .. " exceeds the maximum " .. restrict .. " allowed. (" ..Tbl.max.. ")"
										if not ply:IsAdmin() then return false, Factions.Notify, { ply, "Your " .. mode .. " exceeds the maximum " .. restrict .. " allowed. (" ..Tbl.max.. ")", etype } end
									end
								end
								if Tbl.min and tonumber(Tbl.min) then

									if tonumber(info) < tonumber(Tbl.min) then
										adminNotify = "Your " .. mode .. " is below the minumum " .. restrict .. " allowed. (" ..Tbl.min.. ")"
										if not ply:IsAdmin() then return false, Factions.Notify, { ply, "Your " .. mode .. " is below the minumum " .. restrict .. " allowed. (" ..Tbl.min.. ")", etype } end
									end
								end
							else
								return false, fac_Error, { "Found restriction and restrictions table for " .. mode .. ", but GetInfo(" .. mode .."_" .. restrict .. ") returned nil or could not be converted to a number(info = " ..tostring(info).. ")! Are you sure that you are using the lastest versions of Global RP and " .. mode .. "?" }
							end
						end
					end
				end
				
				if tbl.leftcost and leftclick then --different costs for right and left clicks?
					cost = tonumber(tbl.leftcost)
				elseif tbl.rightcost and rightclick then
					cost = tonumber(tbl.rightcost)
				else
					cost = tonumber(tbl.cost)
				end
				
				if trace and tbl.tracecost then --some stools upgrade an existing entity if they shoot one. check to see if this is the case
					
					if trace.Entity and trace.Entity:IsValid() and (trace.Entity:GetClass() == ClassName or trace.Entity:GetClass() == "gmod_" .. ClassName) then
						cost = tonumber(tbl.tracecost)
					end
				end
				
				table.insert(ClassNames,ClassName)
				
				break
			end
		end
	end
	
	return cost, costCharge, adminNotify, ClassNames, entsOrModels
end

function Factions.GetEntitiesCost( ents, ignoreCommonProps ) --returns the cost of a table of entities
	local cost = 0

	for k, ent in pairs(ents) do

		-- Get the name of the type of the entity
		local typ = type(ent)

		if (typ == "table" or typ == "Entity" or typ == "Vehicle" or typ == "NPC") and ((ent.IsValid and ent:IsValid()) or ent.Class) then
			local ClassName = ent.Class
			if (ent and ent.IsValid and ent:IsValid()) then ClassName = ent:GetClass(); end
			ClassName = string.lower(ClassName)
			local found
			
			if ClassName == "transformer" then
				found = true
				cost = cost + Factions.Config.TransformerSpawnCost
			end
			
			if not ignoreCommonProps and not found then
				for i, tCost in pairs(commonProps) do --is it a common prop?
					i = string.lower(i)
					if i == ClassName or string.find(ClassName,i,nil,true) then
						cost = cost + tCost
						found = true
						break
					end
				end
			end
			
			if not found then
				--if it was spawned from a stool, grab the cost from our table
				for k, T in pairs(fac_Stools) do
					if type(T) == "table" and not found then
						if type(k) == "string" then
							k = string.lower(k)
							if T.ClassName then T.ClassName = string.lower(T.ClassName) end
						
							if ( "gmod_" .. k == ClassName ) then
								found = true
							elseif ( k == ClassName ) and not cost then
								found = true
							elseif T.ClassName and (T.ClassName == ClassName or "gmod_" .. T.ClassName == ClassName) then
								found = true
							end
							if found and T.cost then
								cost = cost + tonumber(T.cost)
								break
							end
						end
						if T.type and T.var then
							for classn,tbl2 in pairs(T.type) do
								if ( tbl2 and tbl2[classn] ) then classn = tbl2[classn] end
								
								if string.lower(classn) == string.lower(ClassName) then
									cost = cost + tonumber(tbl2.cost)
									found = true
									break
								end
							end
						end
					end
				end
			end
			
			if not found then
				--fac_Debug("Unable to find a cost for " ..tostring(ClassName))
			end
		else
			--fac_Debug( tostring(k).. " is not a valid entity. (Expected table with table.Class or entity, got " ..tostring(ent).. ")")
		end
	end
	
	return cost
end

-----------------------------------------------------------
-- Buying and Selling Ents
-----------------------------------------------------------

function Factions.StoolPurchase( ply, trace, mode, internalCall ) --the player purchases entities through a stool
	
	if internalCall then return end -- game.SinglePlayer() or

	if not gamemode.Call( "CanTool", ply, trace, mode, true ) then return false end
	--make sure that all the other CanTool hooks say we can do this first, so we know its going to get done before we start subtracting money
	
	if ply:KeyDown(IN_RELOAD) then return end --we don't charge for reloading
	
	local money = ply:Money()
	
	local cost, costCharge, adminNotify, ClassNames, entsOrModels = Factions.GetStoolCost( mode, ply, ply:GetWeapon("gmod_tool"), trace, ply:KeyDown(IN_ATTACK), ply:KeyDown(IN_ATTACK2) )
	
	if cost then --scenario  1:  cost, costcharge, adminNotify, ClassName
		if adminNotify then ply:Notify( adminNotify, "NOTIFY_GENERIC" ) end

		--do they have enough money?
		if cost > 0 then
			if money < cost then
				Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..cost.. ")", "NOTIFY_ERROR" )
				return false
			else
				for k,v in pairs( ClassNames ) do
					Factions.AuthorizeEntPurchase( ply, nil, v )
				end
				for k,v in pairs( entsOrModels ) do
					Factions.AuthorizeEntPurchase( ply, v )
				end
			
				if type(costCharge) == "number" then
					ply:AddMoney(-costCharge) --for duplications, necessary to avoid charging someone twice for common props
				else
					ply:AddMoney(-cost)
				end
			end
		else
			for k,v in pairs( ClassNames ) do
				Factions.AuthorizeEntPurchase( ply, nil, v )
			end
			for k,v in pairs( entsOrModels ) do
				Factions.AuthorizeEntPurchase( ply, v )
			end
		end
		
		return true
	elseif cost == false and costCharge then --scenario 2: false, handlerFunc, { handlerFunc args }
		costCharge( unpack( adminNotify ) )
	end
	
	for k,v in pairs(fac_Stools) do --is this stool already in our database?
		if k == mode then return end
	end
	
	--we weren't able to find anything. lets add this stool to our database!
	fac_Msg("Unable to find stool '" .. mode .. "' in the Factions stools file (data/factions/stools.txt). Adding stool to the Factions stools file with defaults.")
	
	fac_Stools[mode] = {}
	fac_Stools[mode].restricted = 0
	fac_Stools[mode].cost = 0

	file.Write( "factions/stools.txt", util.TableToKeyValues( fac_Stools ) )
end
hook.Add( "CanTool", "[FAC] StoolPurchase", Factions.StoolPurchase )

function Factions.SellProp( ent )
	if (not ent:IsValid()) or string.find(ent:GetClass(),"stone") then return end

	local tbl = ent:GetTable()
	
	if not tbl then return end
	if (type(tbl) ~= "table") then return end
	if ((type(tbl.cbt) == "table" and type(tbl.cbt.health) == "number" and tbl.cbt.health <= 0) or (type(tbl.health) == "number" and tbl.health <= 0 and type(tbl.maxhealth) == "number" and tbl.maxhealth > 0) or (tbl.healthset and ent:Health() <= 0)) then return end --make sure it didn't die of natural causes (nobody killed it, they really did sell it)
	
	--determine the owner and the cost of the entity
	local ply = Factions.GetEntOwner( ent )
	local cost = Factions.GetEntitiesCost( ent:GetTable() )
	
	--were we able to find a player and a cost?
	if (not (type(ply) == "Player") or not ply:IsValid() or type(cost) ~= "number") then return end
	
	local authorized = Factions.IsEntAuthorized( ply, ent, true )
	if authorized then
		-- give them back half of what they paid. depreciation sucks.
		ply:AddMoney(math.floor(cost/2.0))
	elseif ent:GetClass() ~= "base_gmodentity" then --adv dup likes to spawn base entities
		fac_Msg("Unauthorized entity spawn " .. tostring(ent) .. ". Unable to reimburse removal.")
	end
end
hook.Add( "EntityRemoved", "[FAC] Factions.SellProp", Factions.SellProp )

local function SpawnCar( ply, mdl )
	if not PropSpawningAllowed then return false end

	if ply:Money() < Factions.Config.EntityCosts.vehicles then
		Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..Factions.Config.EntityCosts.vehicles.. ")", "NOTIFY_ERROR" )
		return false
	else
		Factions.AuthorizeEntPurchase( ply, mdl )
		ply:AddMoney(-Factions.Config.EntityCosts.vehicles)
		fac_Msg( ply:Nick().. " has spawned a vehicle"  )
		return true
	end
end
hook.Add( "PlayerSpawnVehicle", "SpawnCar", SpawnCar )

local function SpawnProp( ply, mdl )
	if not PropSpawningAllowed then return false end

	if ply:Money() < Factions.Config.EntityCosts.props then
		Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..Factions.Config.EntityCosts.props.. ")", "NOTIFY_ERROR" )
		return false
	else
		Factions.AuthorizeEntPurchase( ply, mdl )
		ply:AddMoney(-Factions.Config.EntityCosts.props)
		fac_Msg( ply:Nick().. " has spawned a prop (" ..mdl.. ")"  )
		return true
	end
end
hook.Add( "PlayerSpawnProp", "SpawnProp", SpawnProp )

local function SpawnRagdoll( ply, mdl )
	if not PropSpawningAllowed then return false end

	if ply:Money() < Factions.Config.EntityCosts.ragdolls then
		Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..Factions.Config.EntityCosts.ragdolls.. ")", "NOTIFY_ERROR" )
		return false
	else
		Factions.AuthorizeEntPurchase( ply, mdl )
		ply:AddMoney(-Factions.Config.EntityCosts.ragdolls)
		fac_Msg( ply:Nick().. " has spawned a ragdoll (" ..mdl.. ")"  )
		return true
	end
end
hook.Add( "PlayerSpawnRagdoll", "SpawnRagdoll", SpawnRagdoll )

local function SpawnEffect( ply, mdl )
	if not PropSpawningAllowed then return false end

	if ply:Money() < Factions.Config.EntityCosts.effects then
		Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..Factions.Config.EntityCosts.effects.. ")", "NOTIFY_ERROR" )
		return false
	else
		Factions.AuthorizeEntPurchase( ply, nil, "prop_effect" )
		ply:AddMoney(-Factions.Config.EntityCosts.effects)
		fac_Msg( ply:Nick().. " has spawned a ragdoll (" ..mdl.. ")"  )
		return true
	end
end
hook.Add( "PlayerSpawnEffect", "SpawnEffect", SpawnEffect )

local function SpawnSent( ply, class )
	if not PropSpawningAllowed then return false end

	local SentCost = Factions.Config.EntityCosts.sents
	if class == "transformer" then return end --deals with it in spawn function
	if class == "gmod_wire_hoverdrivecontroler" then
		if Factions.GetNWVar( "Mode" ) == "War" then
			Factions.Notify( ply, "Hoverdrives are restricted in War mode.", "NOTIFY_ERROR" )
			return false
		end
		SentCost = Factions.Config.HoverDriveCost
	end
	
	
	if ply:Money() < SentCost then
		Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..SentCost.. ")", "NOTIFY_ERROR" )
		return false
	else
		Factions.AuthorizeEntPurchase( ply, nil, class )
		ply:AddMoney(-SentCost)
		fac_Msg( ply:Nick().. " has spawned a "..tostring(class) )
		return true
	end
end
hook.Add( "PlayerSpawnSENT", "SpawnSENT", SpawnSent )

local function SpawnNPC( ply, npc, weapon )
	if not PropSpawningAllowed then return false end

	if ply:Money() < Factions.Config.EntityCosts.npcs then
		Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..Factions.Config.EntityCosts.npcs.. ")", "NOTIFY_ERROR" )
		return false
	else
		Factions.AuthorizeEntPurchase( ply, nil, npc )
		ply:AddMoney(-Factions.Config.EntityCosts.npcs)
		if weapon and weapon ~= "" then
			fac_Msg( ply:Nick().. " has spawned an " ..tostring(npc).. " equipped with a " ..weapon )
		else
			fac_Msg( ply:Nick().. " has spawned an " ..tostring(npc) )
		end
		return true
	end
end
hook.Add( "PlayerSpawnNPC", "SpawnNPC", SpawnNPC )

local function SpawnSWEP( ply, _, wep )
	if not PropSpawningAllowed then return false end

	local admin = ply:IsAdmin()

	if not Factions.Config.AllowSpawnmenuSWEPS then
		local exception
		for k,v in pairs(Factions.Config.AllowedSWEPS) do
			if v == wep.PrintName or v == wep.ClassName then
				exception = true
				break
			end
		end
				
		if not exception then
			if admin and Factions.Config.AllowAdminSWEPSpawn then return true end
			return false
		end
	end
		
	if admin and wep.AdminSpawnable then return true end
	return wep.Spawnable
end
hook.Add( "PlayerSpawnSWEP", "SpawnSWEP", SpawnSWEP )
hook.Add( "PlayerGiveSWEP", "GiveSWEP", SpawnSWEP )

