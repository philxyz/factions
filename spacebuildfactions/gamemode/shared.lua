------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

include("sh_spropprotection.lua")

GM.Name			= "Spacebuild Factions"
GM.Author		= "Team Ring-Ding"
GM.Email		= "Ring2Ding@gmail.com"
GM.Website		= "http://sbfactions.blogspot.com/"

GM.SPACEBUILD		= true -- Activate the installed Spacebuild Addon

--Enumerations--
TEAM_HUMANS		= 101
TEAM_ALIENS		= 202

DMG_GODMODE		= -1 --players and their props will not take damage
DMG_PLYOFF		= 0 --players can't damage eachother or their props
DMG_ALL			= 1 --allow all damage

ROCK_CHAL= "rock0" --humans start with this
ROCK_GOLD= "rock1" --aliens start with this
ROCK_LOTTERY= "rock2" --neutral

AMMOTYPES = { "Pistol", "pistol", "buckshot", "smg1", "AR2", "AlyxGun", "grenade", "357", "XBowBolt", "RPG_Round", "SMG1_Grenade", "Sniper_Round" }

DeriveGamemode( "sandbox" )

Factions = {}

Factions.Version = string.gsub( GM.Name, "Factions ", "" )

--this table is not necessarily accurate client-side and may not work for later version of these addons
Factions.Addons = {}
Factions.Addons.Lifesupport = (LIFESUPPORT ~= nil)
Factions.Addons.Gcombat = (COMBATDAMAGEENGINE and type(gcombat) == "table")
Factions.Addons.WeightStool = file.Exists("../lua/weapons/gmod_tool/stools/weight.lua", "LUA")
Factions.Addons.Phx = file.Exists("../lua/autorun/phx_content.lua", "LUA")
Factions.Addons.SBMP = (type(SBMP) == "table")
Factions.Addons.CDS = (type(cds_damageent) == "function")
Factions.Addons.AdvDup = (type(AdvDupe) == "table")
Factions.Addons.ULX = (type(util) == "table" and type(ulx) == "table")

local function TeamSetup()
	team.SetUp(TEAM_HUMANS, "Humans", Color(80, 100, 255, 200))
	team.SetUp(TEAM_ALIENS, "Aliens", Color(50, 150, 50, 160))
	team.SetUp(TEAM_CONNECTING, "Joining", Color(50, 50, 50, 20))
	team.SetUp(TEAM_UNASSIGNED, "Error", Color(150, 50, 50, 20))
	team.SetUp(TEAM_SPECTATOR, "None", Color(50, 50, 50, 255))
end
TeamSetup()
hook.Add("PlayerSpawn", "TeamSetup, shared.lua", TeamSetup)

function GM:PhysgunPickup( ply, ent )
	-- Some entities specifically forbid physgun interaction
	
	if ( ent:GetTable().PhysgunDisabled ) then print("physgun interaction DISABLED"); return false end

	-- Don't pick up players
	if ( ent:GetClass() == "player" ) and not ply:IsAdmin() then return false end

	if ent:IsValid() then
		if ent:GetTable().PhysgunPickup then
			print ("this entity defines a PhysgunPickup method")
			local rtn = ent:GetTable():PhysgunPickup( ply )
			ent:SetVar( "IsPhysed", rtn )
			return rtn
		end
	end
	local rtn = self.BaseClass:PhysgunPickup( ply, ent )
	ent:SetVar( "IsPhysed", rtn )
	return rtn
end

function GM:PhysgunDrop( ply, ent )
	ent:SetVar( "IsPhysed", false )
end

function Factions.UlxLog( msg )
	if Factions.Addons.ULX then
		if util.tobool( GetConVarNumber( "ulx_logEvents" ) ) then
			ulx.logString( msg )
		end
	end
	return msg
end

function fac_Debug( msg )
	local str
	if string.find( msg, "\n" ) then
		str = "[FAC Debug] " ..tostring(msg)
	else
		str = "[FAC Debug] " ..tostring(msg).. "\n"
	end
	Msg(str)
end

function fac_Msg( msg )
	local str
	if string.find( msg, "\n" ) then
		str = "[FAC] " ..tostring(msg)
	else
		str = "[FAC] " ..tostring(msg).. "\n"
	end
	Msg(str)
end

function fac_Error( msg, where, line )
	for k, v in pairs(player.GetAll()) do
		Factions.Notify( v, "An error has occured, see the console for more information.", "NOTIFY_ERROR" )
	end
	
	local str
	if msg and where and line then
		str = "**********************************************************\n          FAC ERROR! ("
		..tostring(where).. ", line:" ..tostring(line).. ")\n" ..tostring(msg).. "\n**********************************************************\n"
	elseif msg and where then
		str = "**********************************************************\n          FAC ERROR! (" ..tostring(where).. ")\n" ..tostring(msg).. "\n**********************************************************\n"
	elseif msg then
		str = "**********************************************************\n                 FAC ERROR!\n" ..tostring(msg).. "\n**********************************************************\n"
	end
	
	Msg(str)
end

function fac_Output( str, thing ) --prints to console what thing is
	Msg("[FAC Debug] " .. str .. " = '")
	if type(thing) == "table" then PrintTable(thing)
	else Msg(tostring(thing)) end
	Msg("'\n")
end
