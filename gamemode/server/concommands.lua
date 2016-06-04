------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

LastTeamChangeTimes = {}

local School = { "Welcome to Factions!", "You can disable the music by typing fac_music 0 in console. To enable it again, simply type fac_music 1.", "Press F1 to see the help menu.", "Press F2 to change your team.", "F3 initiates a trade with another player.", "F4 allows you to purchase weapons.", "You earn money by mining space rocks and trading.", "In case you forget, you can find this and other useful information in the Quick Reference section of the F1 help menu.", "Good luck!" }
local function SchoolMe( ply, cmd, args, session )
	if not session then
		Factions.Notify( ply, School[1], "NOTIFY_GENERIC" )
		timer.Simple( 6, function() SchoolMe( ply, nil, nil, 2) end )
	elseif session > table.Count( School ) then
		return
	elseif session == 3 then
		Factions.Notify( ply, School[3], "NOTIFY_GENERIC", 14 )
		Factions.Notify( ply, School[4], "NOTIFY_GENERIC", 14, nil, nil, true )
		Factions.Notify( ply, School[5], "NOTIFY_GENERIC", 14, nil, nil, true )
		Factions.Notify( ply, School[6], "NOTIFY_GENERIC", 14, nil, nil, true )
		timer.Simple( 16, function() SchoolMe(ply, nil, nil, 7) end )
	else
		Factions.Notify( ply, School[session], "NOTIFY_GENERIC", 10 )
		timer.Simple( 12, function() SchoolMe(ply, nil, nil, session + 1) end )
	end
end
concommand.Add( "fac_schoolme", SchoolMe )

--------------------------------
--  Internal
--------------------------------

local flagmodels = {}
flagmodels[ TEAM_ALIENS ] = "models/katharsmodels/flags/flag36.mdl"
flagmodels[ TEAM_HUMANS ] = "models/katharsmodels/flags/flag27.mdl"
flagmodels.neutral        = "models/katharsmodels/flags/flag08.mdl"

local function CloseTeamMenu( ply, cmd, args )
	gamemode.Call( "ShowTeam", ply )
end
concommand.Add( "fac_closeteam", CloseTeamMenu )

function fac_PickTeam( ply, cmd )
	local now = CurTime()
	local iD = ply:UniqueID()

	if LastTeamChangeTimes[iD] then
		if (now - LastTeamChangeTimes[iD]) <= 10 then
			return
		end
	end

	LastTeamChangeTimes[iD] = now

	if cmd == "fac_Human" then
		ply:ChangeTeam( TEAM_HUMANS )
	elseif cmd == "fac_Alien" then
		ply:ChangeTeam( TEAM_ALIENS )
	end

	ply:SetNetworkedBool( "f2", false )
	
	umsg.Start("fac_hideteammenu", Player)
	umsg.End()
	
	if not plyvar[ply].InitTeamSpawn then
		gamemode.Call( "PlayerInitialTeamSpawn", ply )
	end
end
concommand.Add( "fac_Human", fac_PickTeam )
concommand.Add( "fac_Alien",  fac_PickTeam )

local function DropResource( ply, cmd, args )
	if not ply or not args[1] then return end
	
	local res, amt
	if string.find( args[1], "[$]" ) then
		res = "money"
		amt = string.gsub( args[1], "[$]", "" )
	elseif string.find( args[1], "g" ) then
		res = "rock1"
		amt = string.gsub( args[1], "g", "" )
	elseif string.find( args[1], "c" ) then
		res = "rock0"
		amt = string.gsub( args[1], "c", "" )
	else
		Factions.Notify( ply, "Invalid Drop Type. (Available Types: g, c, $) Example: !drop 100c", "NOTIFY_ERROR", 8 )
		return
	end
	
	amt = tonumber(amt)
	
	if not amt or amt <= 0 then
		Factions.Notify( ply, "Invalid Drop Amount. Example: !drop 100c", "NOTIFY_ERROR" )
		return
	end
	
	local plyamt = ply:GetNWInt( res )
	if amt > plyamt then
		Factions.Notify( ply, "You cannot drop more than you have!", "NOTIFY_ERROR" )
		return
	end
	
	local items = ents.Create("item")
		
		items:SetResource( res, amt )
		items:SetResource( "owner", ply )
		
		items:SetPos( ply:GetPos() + (ply:GetForward() * 50) + Vector( 0, 0, 50 ) )
		items:Spawn()
	items:Activate()
	
	ply:SetNWInt( res, plyamt - amt )
	umsg.Start( "DrawNotice", ply )
		umsg.String( res )
		umsg.Short( -amt )
	umsg.End()
end
concommand.Add( "fac_drop", DropResource )

local function ChooseSpawnpoint( ply, cmd, args )
	if args[1] == "Home Planet" then
		plyvar[ ply ].spawnpoint = nil
	else
		local flags = gmod.GetGamemode().flags
		
		for _,flag in pairs( flags ) do
			if flag.spawnname == args[1] then
				plyvar[ ply ].spawnpoint = flag
			end
		end
	end
end
concommand.Add( "fac_setspawnpoint", ChooseSpawnpoint )

local function SetSpawnpointName( ply, cmd, args )
	if not args then return end
	
	args = string.Explode( ":", args[1] )
	local flag = ents.GetByIndex( tonumber( args[1] ) )
	
	if not flag then return end
	
	local flags = gmod.GetGamemode().flags
	for _,f in pairs( flags ) do
		if f.spawnname == args[2] then
			ply:ChatPrint( "That name already exists." )
			timer.Simple( 2, function() TIMERShowSpawnpointSetBox(ply, flag:EntIndex()) end )
			return
		end
	end
	
	flag.spawnname = args[2]
end
concommand.Add( "fac_setspawnpointname", SetSpawnpointName )

function TIMERShowSpawnpointSetBox( ply, entid )
	umsg.Start( "ChooseSPName", ply )
		umsg.Short( entid )
	umsg.End()
end

local function Buy( ply, cmd, args )
	if not args[1] then return end
	if not Factions.Config.AllowFACSWEPS and not ply:IsAdmin() then
		Factions.Notify( ply, "The Spawning of SWEPS Is Currently Restricted", "NOTIFY_ERROR" )
		return
	elseif ply:IsAdmin() and not Factions.Config.AllowFACSWEPS and not Factions.Config.AllowAdminSWEPSpawn then
		Factions.Notify( ply, "The Spawning of SWEPS Is Currently Restricted", "NOTIFY_ERROR" )
		return
	end
	
	local give
	
	if string.find( args[1], "ammo." ) then
		local cost
		local amt = 50
		
		give = string.gsub( args[1], "ammo.", "")
		if give == "Pistol" or give == "pistol" then
			cost = Factions.Config.Weapons.Pistols.Ammo.Cost
		elseif give == "buckshot" then
			cost = Factions.Config.Weapons.Shotguns.Ammo.Cost
			amt = 5
		elseif give == "smg1" then
			cost = Factions.Config.Weapons.SMGs.Ammo.Cost
		elseif give == "AR2" then
			cost = 100
		elseif give == "AlyxGun" then
			cost = 150
		elseif give == "grenade" then
			cost = Factions.Config.Weapons.Equipment.Grenade.Cost
			amt = 1
		elseif give == "armor" then
			cost = Factions.Config.Weapons.Equipment.Armor.Cost
			amt = 100 - ply:Armor()
			if ply:Armor() >= 100 then
				Factions.Notify( ply, "You already have full armor.", "NOTIFY_ERROR" )
				return
			end
		elseif give == "medpack" then
			cost = Factions.Config.Weapons.Equipment.Health.Cost
			amt = 50 - ply:Health()
			if ply:Health() >= 50 then
				Factions.Notify( ply, "You already have full health.", "NOTIFY_ERROR" )
				return
			end
		else
			return
		end
		
		if ply:Money() < cost then
			Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..cost.. ")", "NOTIFY_ERROR" )
			return
		end

		ply:AddMoney(-cost)
		
		if give == "grenade" and not ply:HasWeapon("weapon_frag") then
			ply:Give("weapon_frag")
			return
		elseif give == "armor" then
			ply:SetArmor( ply:Armor() + amt )
			ply:PlaySound("items/ammopickup.wav")
			return
		elseif give == "medpack" then
			ply:SetHealth( ply:Health() + amt )
			ply:PlaySound("items/smallmedkit1.wav")
			return
		end
		
		ply:GiveAmmo( amt, give, true )
		if give == "AlyxGun" then
			give = "Mgun"
		elseif give == "AR2" then
			give = "Rifle"
		end
		ply:PlaySound("items/ammo_pickup.wav")
		ply:_Call("HUDAmmoPickedUp", give, amt)
	else
		local class, amt, ammotype = nil
		
		if ply:HasWeapon( args[1] ) then
			if args[1] == "weapon_knife" then
				Factions.Notify( ply, "You already have a knife!", "NOTIFY_ERROR" )
			elseif args[1] == "weapon_physgun" then
				Factions.Notify( ply, "You already have a physgun!", "NOTIFY_ERROR" )
			end
			if not ply:GetWeapon( args[1] ):GetTable().Primary then return end
			
			Buy( ply, "fac_buy", {'ammo.' ..ply:GetWeapon( args[1] ):GetTable().Primary.Ammo} )
			return
		end
		
		for _,tbl in pairs(Factions.Config.Weapons) do
			for k,tbl2 in pairs(tbl) do
				if type(tbl2) == "table" and args[1] == tbl2.ClassName then
					cost = tbl2.Cost
					ammotype = tbl2.AmmoType
				end
			end
		end

		if not cost then
			fac_Debug("Unable to find a cost for " .. tostring(args[1]))
			return
		end
		
		if ply:Money() < cost then
			Factions.Notify( ply, "You do not have enough money to do that! (Requires $" ..cost.. ")", "NOTIFY_ERROR" )
		else
			ply:AddMoney(-cost)
			MsgAll( "Giving "..ply:Nick().." a "..args[1].."\n" )
			ply:GiveWeapon( args[1] )
			
			ply:SelectWeapon( args[1] )
		end
	end
end
concommand.Add( "fac_buy", Buy )

local function RequestStools( ply, cmd, args ) --called if for some reason it bugged and the client was unable to load their stools file (or their stools file was malformed)
	if ply and ply:IsValid() then
		ply:UmsgLarge( "fac_stools", fac_Stools )
	end
end
concommand.Add( "fac_requeststools", RequestStools )

-------------------------------
--    Trade
-------------------------------

local function InitTrade( ply, cmd, args )
	if not args[1] or not ply or not ply:IsValid() then return end
	local targetply = nil
	
	for k,v in pairs( player.GetAll() ) do
		if v:Nick() == args[1] then
			targetply = v
		end
	end
	
	if not targetply then
		Factions.Notify( ply, "No such player '" ..tostring(args[1]).. "'", "NOTIFY_GENERIC", 10 )
		
		ply:SetNWBool( "showtrader", false )
		
		umsg.Start( "fac_hidetrademenu", ply )
		umsg.End()

		umsg.Start("ResetWaiting", ply)
		umsg.End()
		
		return
	end
	
	if targetply:GetNWBool("AwaitingTrade") or targetply:GetNWBool("showtrader") then
		Factions.Notify( ply, targetply:Nick() .. " Is Busy.", "NOTIFY_GENERIC", 10 )
		
		ply:SetNWBool( "showtrader", false )
		
		umsg.Start( "fac_hidetrademenu", ply )
		umsg.End()

		umsg.Start("ResetWaiting", ply)
		umsg.End()

		return
	end
	
	local table = { targetply:Nick() }
	table.page = 2
	
	Factions.Notify( targetply, ply:Nick().. " Is Requesting a Trade, Press F3 to Accept.", "NOTIFY_GENERIC", 10 )
	targetply:SetNWBool( "AwaitingTrade", true )
	
	if not plyvar[ply] then plyvar[ply] = {} end
	plyvar[ply].tradepartner = targetply
	plyvar[targetply].tradepartner = ply
	
	timer.Simple( 10, function() TradeDeny(ply, targetply) end )
end
concommand.Add( "fac_trade", InitTrade )

function TradeDeny( ply, targetply )
	if targetply:GetNWBool( "AwaitingTrade" ) then
		Factions.Notify( ply, targetply:Nick().. " Has Denied Your Request.", "NOTIFY_GENERIC", 6 )
		targetply:SetNWBool( "AwaitingTrade", false )
		ply:SetNWBool( "AwaitingTrade", false )
		
		umsg.Start( "fac_hidetrademenu", ply )
		umsg.End()
		
		ply:SetNWBool( "showtrader", false )
	end
end

local function TradeExit( ply, cmd, args )
	Factions.Notify( plyvar[ply].tradepartner, ply:Nick() .. " has aborted the trading process.", "NOTIFY_GENERIC", 6 )
	plyvar[ply].tradepartner:SetNWBool( "AwaitingTrade", false )
	ply:SetNWBool( "AwaitingTrade", false )
	
	umsg.Start( "fac_hidetrademenu", plyvar[ply].tradepartner )
	umsg.End()
		
	plyvar[ply].tradepartner:SetNWBool( "showtrader", false )
end
concommand.Add( "fac_TradeExit", TradeExit )

local function Offer( ply, cmd, args )
	if not args[1] then return end
	
	fac_Debug("Offering " .. tostring(args[1]) .. " to " .. tostring(plyvar[ply].tradepartner))
	
	ply:SetNWString( "MyOffer", args[1] )
	plyvar[ply].tradepartner:SetNWString( "HisOffer", args[1] )
end
concommand.Add( "fac_offer", Offer )

local function ClearTransactionData( ply, cmd, args )
	fac_Debug("Clearing Transaction Data")
	if plyvar then
		if plyvar[ply] then
			plyvar[ply].TradeAmts = nil
			if plyvar[ply].tradepartner then
				plyvar[ plyvar[ply].tradepartner ].TradeAmts = nil
				ply:SetNWString( "HisOffer", "" )
				ply:SetNWString( "MyOffer", "" )
				plyvar[ply].tradepartner:SetNWString( "MyOffer", "" )
				plyvar[ply].tradepartner:SetNWString( "MyOffer", "" )
			end
		end
	end
	
end
concommand.Add( "fac_cleartransact", ClearTransactionData )

local function Transact( ply, cmd, args )
	----------------Stuff Checks Out, Do The Trade!
	if plyvar[ply].TradeAmts and plyvar[ plyvar[ply].tradepartner ].TradeAmts then
		--subtract player's amt
		ply:SetNWInt( plyvar[ply].TradeAmts.type, ply:GetNWInt( plyvar[ply].TradeAmts.type ) - plyvar[ply].TradeAmts.amt )
		umsg.Start("DrawNotice", ply)
			umsg.String( plyvar[ply].TradeAmts.type )
			umsg.Short( -plyvar[ply].TradeAmts.amt )
		umsg.End()
		
		--give it to partner
		plyvar[ply].tradepartner:SetNWInt( plyvar[ply].TradeAmts.type, plyvar[ply].tradepartner:GetNWInt( plyvar[ply].TradeAmts.type ) + plyvar[ply].TradeAmts.amt )
		umsg.Start("DrawNotice", plyvar[ply].tradepartner)
			umsg.String( plyvar[ply].TradeAmts.type )
			umsg.Short( plyvar[ply].TradeAmts.amt )
		umsg.End()
			
		--subtract partner's amt
		plyvar[ply].tradepartner:SetNWInt( plyvar[ plyvar[ply].tradepartner ].TradeAmts.type, plyvar[ply].tradepartner:GetNWInt( plyvar[ plyvar[ply].tradepartner ].TradeAmts.type ) - plyvar[ plyvar[ply].tradepartner ].TradeAmts.amt )
		umsg.Start("DrawNotice", plyvar[ply].tradepartner)
			umsg.String( plyvar[ plyvar[ply].tradepartner ].TradeAmts.type )
			umsg.Short( -plyvar[ plyvar[ply].tradepartner ].TradeAmts.amt )
		umsg.End()
		
		--give it to player
		ply:SetNWInt( plyvar[ plyvar[ply].tradepartner ].TradeAmts.type, ply:GetNWInt( plyvar[ plyvar[ply].tradepartner ].TradeAmts.type ) + plyvar[ plyvar[ply].tradepartner ].TradeAmts.amt )
		umsg.Start("DrawNotice", ply)
			umsg.String( plyvar[ plyvar[ply].tradepartner ].TradeAmts.type )
			umsg.Short( plyvar[ plyvar[ply].tradepartner ].TradeAmts.amt )
		umsg.End()
		
		--you end up with money rocks?
		if ply:Team() == TEAM_ALIENS and ply:GetNWInt("rock0") > 0 then
			ply:AddMoney(ply:GetNWInt("rock0") * Factions.Config.RockMoneyTrade)
			umsg.Start("DrawNotice", ply)
				umsg.String( "rock0" )
				umsg.Short( -ply:GetNWInt("rock0") )
			umsg.End()
			ply:SetNWInt("rock0", 0)
		elseif ply:Team() == TEAM_HUMANS and ply:GetNWInt("rock1") > 0 then
			ply:AddMoney(ply:GetNWInt("rock1") * Factions.Config.RockMoneyTrade)
			umsg.Start("DrawNotice", ply)
				umsg.String( "rock1" )
				umsg.Short(-ply:GetNWInt("rock1"))
			umsg.End()
			ply:SetNWInt("rock1", 0)
		end
		
		--partner end up with money rocks?
		if plyvar[ply].tradepartner:Team() == TEAM_ALIENS and plyvar[ply].tradepartner:GetNWInt("rock0") > 0 then
			plyvar[ply].tradepartner:AddMoney(plyvar[ply].tradepartner:GetNWInt("rock0") * Factions.Config.RockMoneyTrade)
			umsg.Start("DrawNotice", plyvar[ply].tradepartner)
				umsg.String("rock0")
				umsg.Short(-plyvar[ply].tradepartner:GetNWInt("rock0"))
			umsg.End()
			plyvar[ply].tradepartner:SetNWInt("rock0", 0)
		elseif plyvar[ply].tradepartner:Team() == TEAM_HUMANS and plyvar[ply].tradepartner:GetNWInt("rock1") > 0 then
			plyvar[ply].tradepartner:AddMoney(plyvar[ply].tradepartner:GetNWInt("rock1") * Factions.Config.RockMoneyTrade)
			umsg.Start("DrawNotice", plyvar[ply].tradepartner)
				umsg.String( "rock1" )
				umsg.Short( -plyvar[ply].tradepartner:GetNWInt("rock1") )
			umsg.End()
			plyvar[ply].tradepartner:SetNWInt("rock1", 0)
		end

		Factions.Notify( ply, "Transaction Successful!", "NOTIFY_GENERIC" )
		Factions.Notify( plyvar[ply].tradepartner, "Transaction Successful!", "NOTIFY_GENERIC" )
			
		umsg.Start( "fac_hidetrademenu", ply )
		umsg.End()
		ply:SetNWBool( "showtrader", false )
		umsg.Start( "fac_hidetrademenu", plyvar[ply].tradepartner )
		umsg.End()
		plyvar[ply].tradepartner:SetNWBool( "showtrader", false )
			
		plyvar[ plyvar[ply].tradepartner ].TradeAmts = nil
		plyvar[ plyvar[ply].tradepartner ].tradepartner = nil
		plyvar[ply].tradepartner = nil
		plyvar[ply].TradeAmts = nil
		return
	end
	
	----------------Checking Your Variables
	
	local offer = ply:GetNWString( "MyOffer" )
	local amt, type = nil
		
	if string.find( offer, "[$]" ) then
		amt = string.gsub( offer, "[$]", "" )
		type = "money"
	elseif string.find( offer, "c" ) then
		amt = string.gsub( offer, "c", "" )
		type = "rock0"
	elseif string.find( offer, "g" ) then
		amt = string.gsub( offer, "g", "" )
		type = "rock1"
	else
		Factions.Notify( ply, "Your offer is invalid. Press F1 for help.", "NOTIFY_ERROR" )
		return
	end
	
	amt = tonumber(amt)
	
	if not amt or amt < 0 then
		Factions.Notify( ply, "Your offer is invalid. Press F1 for help.", "NOTIFY_ERROR" )
		return
	end
	
	if ply:GetNWInt(type) < amt then
		Factions.Notify( ply, "You cannot give more than you have.", "NOTIFY_ERROR" )
		return
	end
	
	----------------Check Your Partner's Variables
	
	offer = plyvar[ply].tradepartner:GetNWString( "MyOffer" )
	local hisamt, histype

	if string.find( offer, "[$]" ) then
		hisamt = string.gsub( offer, "[$]", "" )
		histype = "money"
	elseif string.find( offer, "c" ) then
		hisamt = string.gsub( offer, "c", "" )
		histype = "rock0"
	elseif string.find( offer, "g" ) then
		hisamt = string.gsub( offer, "g", "" )
		histype = "rock1"
	else
		Factions.Notify( ply, "Your partner's offer is invalid. Press F1 for help.", "NOTIFY_ERROR" )
		return
	end
	
	hisamt = tonumber(hisamt)
	
	if not hisamt then
		Factions.Notify( ply, "Your partner's offer is invalid. Press F1 for help.", "NOTIFY_ERROR" )
		return
	end
	
	if plyvar[ply].tradepartner:GetNWInt(histype) < hisamt then
		Factions.Notify( ply, "Your partner cannot give more than he/she has.", "NOTIFY_ERROR" )
		return
	end
	
	----------------Set Variables
	
	plyvar[ply].TradeAmts = {}
	plyvar[ply].TradeAmts.amt = amt
	plyvar[ply].TradeAmts.type = type
		
	plyvar[ plyvar[ply].tradepartner ].TradeAmts = {}
	plyvar[ plyvar[ply].tradepartner ].TradeAmts.amt = hisamt
	plyvar[ plyvar[ply].tradepartner ].TradeAmts.type = histype
	
	Factions.Notify( ply, "Requesting Completion of Transaction with " ..plyvar[ply].tradepartner:Nick(), "NOTIFY_GENERIC" )
	Factions.Notify( plyvar[ply].tradepartner, ply:Nick() .. " Is Requesting To Complete The Transaction.", "NOTIFY_GENERIC" )
end
concommand.Add( "fac_transact", Transact )

--------------------------------------
-- Player Called
--------------------------------------
local function fac_OneTwoAC() return {"0","1",""} end

local function AutoSpawnNPCS( ply, cmd, args )
	args = tonumber(args[1])

	if not args then
		Factions.CCPrintHelp( 'Enables or disables NPC auto spawning after a mode or map change.', {0, 1}, Factions.Config.AutoSpawnNPCS, ply )
		return
	end
	
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end
	
	local msg
	if args == 0 then
		msg = "NPC auto spawning off."
		Factions.Config.AutoSpawnNPCS = false
	else
		msg = "NPC auto spawning on."
		Factions.Config.AutoSpawnNPCS = true
	end

	if console then
		Msg('[FAC Config] ' ..msg.. '\n')
	else
		Factions.Notify( ply, msg, "NOTIFY_GENERIC" )
		ply:PrintMessage( HUD_PRINTCONSOLE, '[FAC Config] ' .. msg )
	end
end
concommand.Add( "fac_autospawnnpcs", AutoSpawnNPCS, fac_OneTwoAC )
local function SpawnNPCS( ply, cmd, args )
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end

	gamemode.Call("SpawnNPCS")
	if console then
		Msg('[FAC Config] NPCS spawned.\n')
	else
		Factions.Notify( ply, "NPCS spawned.", "NOTIFY_GENERIC" )
		ply:PrintMessage( HUD_PRINTCONSOLE, '[FAC Config] NPCS spawned.' )
	end
end
concommand.Add( "fac_spawnnpcs", SpawnNPCS )
local function RemoveNPCS( ply, cmd, args )
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end

	gamemode.Call("RemoveNPCS")
	if console then
		Msg('[FAC Config] NPCS removed.\n')
	else
		Factions.Notify( ply, "NPCS removed.", "NOTIFY_GENERIC" )
		ply:PrintMessage( HUD_PRINTCONSOLE, '[FAC Config] NPCS removed.' )
	end
end
concommand.Add( "fac_removenpcs", RemoveNPCS )

local function SetMode( ply, cmd, args )
	args = args[1]
	if args == "war" then
		args = "War"
	elseif args == "free" then
		args = "Free"
	end
	
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end
	
	if args ~= "War" and args ~= "Free" then
		Factions.CCPrintHelp( 'Changes the gamemode mode.', {"Free", "War"}, Factions.GetNWVar( "Mode", "" ), ply )
		return
	end
	
	if args == "War" then
		PropSpawningAllowed = false
	end
	gamemode.Call( "SetMode", args )
end
local function SetModeAC() return {"free", "war", ""} end
concommand.Add( "fac_mode", SetMode, SetModeAC() )

local function AutoTeamBalance_ConCommand( ply, cmd, args )
	args = tonumber(args[1])
	
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end
	
	if args ~= 1 and args ~= 0 then
		Factions.CCPrintHelp( 'Enables or disables AutoTeamBalance.', {0, 1}, Factions.Config.AutoTBDefault, ply )
		return
	end
	if args == 1 then
		Factions.Config.AutoTBDefault = true
		if console then
			Msg('[FAC Config] AutoTeamBalance Enabled.\n')
		else
			Factions.Notify( ply, "Auto Team Balance Enabled", "NOTIFY_GENERIC" )
			ply:PrintMessage( HUD_PRINTCONSOLE, 'AutoTeamBalance Enabled.' )
		end
	elseif args == 0 then
		Factions.Config.AutoTBDefault = false
		if console then
			Msg('[FAC Config] AutoTeamBalance Disabled.\n')
		else
			Factions.Notify( ply, "Auto Team Balance Disabled", "NOTIFY_GENERIC" )
			ply:PrintMessage( HUD_PRINTCONSOLE, 'AutoTeamBalance Disabled.' )
		end
	end
end
concommand.Add( "fac_autoteambalance", AutoTeamBalance_ConCommand, fac_OneTwoAC )

local function fac_FragileProps( ply, cmd, args )
	args = tonumber(args[1])
	
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end

	if args == 0 then
		Factions.Config.FragileProps = false
		if console then
			Msg('[FAC Config] Fragile Props Disabled.\n')
		else
			Factions.Notify( ply, "Fragile Props Disabled.", "NOTIFY_GENERIC" )
			ply:PrintMessage( HUD_PRINTCONSOLE, 'Fragile Props Disabled.' )
		end
	else
		Factions.Config.FragileProps = true
		if console then
			Msg('[FAC Config] Fragile Props Enabled\n')
		else
			Factions.Notify( ply, "Fragile Props Enabled.", "NOTIFY_GENERIC" )
			ply:PrintMessage( HUD_PRINTCONSOLE, 'Fragile Props Enabled.' )
		end
	end
end
concommand.Add( "fac_fragileprops", fac_FragileProps, fac_OneTwoAC )

local function fac_LimitRockRespawns( ply, cmd, args )
    args = tonumber(args[1])

    local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end

    if args == 1 then
		Factions.Config.LimitTheBigRocks = true
        if console then
            Msg('[FAC Config] Big rock spawns limited to ' .. Factions.Config.BigRockSpawnLimit .. '.\n')
		else
            Factions.Notify( ply, "Big rock spawns limited to " .. Factions.Config.BigRockSpawnLimit .. ".", "NOTIFY_GENERIC" )
            ply:PrintMessage( HUD_PRINTCONSOLE, 'Big rock spawns limited to ' .. Factions.Config.BigRockSpawnLimit .. '.\n' )
        end
    else
		Factions.Config.LimitTheBigRocks = false
        if console then
            Msg('[FAC Config] Unlimited big rock respawns enabled.\n')
        else
            Factions.Notify( ply, "Unlimited big rock respawns enabled.", "NOTIFY_GENERIC" )
            ply:PrintMessage( HUD_PRINTCONSOLE, 'Unlimited big rock respawns enabled.' )
        end
    end
end
concommand.Add( "fac_limit_rocks", fac_LimitRockRespawns, fac_OneTwoAC )

local function fac_MoneyReset( ply, cmd, args )
	args = tonumber(args[1])

	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end

    if args == 1 then
            Factions.Config.MoneyReset = true
            if console then
                    Msg("[FAC Config] Player money resetting enabled.\n")
            else
                    Factions.Notify( ply, "Player money resetting enabled.", "NOTIFY_GENERIC" )
                    ply:PrintMessage( HUD_PRINTCONSOLE, 'Player money resetting enabled.\n' )
            end
    else
            Factions.Config.MoneyReset = false
            if console then
                    Msg('[FAC Config] Player money resetting disabled.\n')
            else
                    Factions.Notify( ply, "Player money resetting disabled.", "NOTIFY_GENERIC" )
                    ply:PrintMessage( HUD_PRINTCONSOLE, 'Player money resetting disabled.' )
            end
    end
end
concommand.Add( "fac_moneyreset", fac_MoneyReset, fac_OneTwoAC )

local function fac_dmg( ply, cmd, arg )
	arg = tonumber(arg[1])
	
	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end

	if arg == -1 or arg == 1 or arg == 0 or arg == 2 then
		Factions.DMGVar = arg
		if console then
			Msg('[FAC Config] Damage type set to ' ..tostring(arg).. '!')
		else
			ply:PrintMessage( HUD_PRINTCONSOLE, '[FAC Config] Damage type set to ' ..tostring(arg).. '!')
		end
	else
		Factions.CCPrintHelp( 'Changes how players can take damage.', {-1, 0, 1}, Factions.DMGVar, ply )
	end
	
	local nick
	if console then nick = "Console" else nick = ply:Nick() end
	
	for k, v in pairs(player.GetAll()) do
		if arg == -1 then
			Factions.Notify( v, nick.. " has disabled all damage! (including fall damage)", "NOTIFY_GENERIC", 8, "Penis Face =P" )
		elseif arg == 0 then
			Factions.Notify( v, nick.. " has disabled damage between players and their props!", "NOTIFY_GENERIC", 8, "Penis Face =P" )
		elseif arg == 1 then
			Factions.Notify( v, nick.. " has enabled all damage!", "NOTIFY_GENERIC", 8, "Penis Face =P" )
		end
	end
	arg = nil
end
concommand.Add( "fac_dmg", fac_dmg )

local function fac_ff( ply, cmd, arg )
	arg = tonumber(arg[1])

	local mayWe, console = Factions.CCCheckPlayer( ply )
	if not mayWe then return end
	
	local nick
	if console then nick = "Console" else nick = ply:Nick() end
	
	if arg == 0 then
		Factions.FF = false
		Msg("[FAC Config] Friendly fire disabled.\n")
	elseif arg == 1 then
		Factions.FF = true
		Msg("[FAC Config] Friendly fire enabled.\n")
	else
		Factions.CCPrintHelp( 'Enables or Disables friendly fire between players.', {0, 1}, Factions.FF, ply )
		return
	end
	
	for k, v in pairs(player.GetAll()) do
		if arg == 0 then
			Factions.Notify( v, nick.. " has disabled friendly fire!", "NOTIFY_GENERIC", 8, "Penis Face =P" )
		elseif arg == 1 then
			Factions.Notify( v, nick.. " has enabled friendly fire!", "NOTIFY_GENERIC", 8, "Penis Face =P" )
		end
	end
end
concommand.Add( "fac_ff", fac_ff, fac_OneTwoAC )

local function fac_Help( ply, cmd, args )
	ply:PrintMessage( HUD_PRINTCONSOLE, '\n*******FAC HELP*******')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'Press f1 for a gui help menu, as this only lists console commands and their uses.\n\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'Also note that this is a brief overview.')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'Use the command without any arguments (something after the command, like 1 or 0 or "free") to get more indepth, specific help.')
	ply:PrintMessage( HUD_PRINTCONSOLE,  'Throughout the list I will abbreviate arguments with args.')
	ply:PrintMessage( HUD_PRINTCONSOLE,  '<A> stands for Admin Only, and means that the command can only be used by server administrators.\n\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_help        - shows this menu\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_dmg <args> <A> - sets the way that damage is handled in the game.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_ff <args> <A> - enables or disables friendly fire.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_autoteambalance <args> <A> - enables or disables auto team balance\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_fragileprops <args> <A> - Should props be destructible?\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_mode <args> <A> - Sets the current server mode of the gamemode.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_autospawnnpcs <args> <A> - Spawn npcs on capturable planets after every mode or map change. 1 to enable, 0 to disable.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_spawnnpcs <A> - Spawns npcs on capturable planets.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_removenpcs <A> - Removes all NPCS from the map.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_music <args> - enables or disables the music.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_nexttrack - plays the next track if music is enabled.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_showgui <args> - use 0 to hide the FAC gui, 1 to display it. (useful for screenshots)\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, 'fac_playsong <args> - plays a song, supports autocomplete.\n')
	ply:PrintMessage( HUD_PRINTCONSOLE, '*******FAC HELP*******\n')
end
concommand.Add( "fac_help", fac_Help )
concommand.Add( "FAC", fac_Help )

-----------------------------------
-- Testing Only
-----------------------------------
--[[
if game.SinglePlayer() then
	local function greedisgood( ply, cmd, args )
		if not ply:IsAdmin() then
			ply:PrintConsole( "Unknown command: greedisgood" )
			return
		end
		ply:SetNetworkedInt( "money", ply:GetNWInt("money") + 10000 )
	end
	concommand.Add( "greedisgood", greedisgood )
end
--]]
