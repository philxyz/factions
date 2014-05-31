------------------------------------------
-- Spacebuild Factions
-- Team Ring-Ding
------------------------------------------

Msg("\n\n-------------------------------------------\n")
Msg("Loading Factions Server, derived from sandbox\n")
Msg("-------------------------------------------\n")

plyvar = {}

-- Enums used for some functions in Spacebuild3
SB_AIR_O2 = 0
SB_AIR_CO2 = 1
SB_AIR_N = 2
SB_AIR_H = 3

------------------------------------------
-- Load Spacebuild
------------------------------------------
Msg("Loading Spacebuild 2 by LS/RD/SB Team\n")

include("spacebuild2/gamemode/init.lua")
AddCSLuaFile("spacebuild2/gamemode/cl_init.lua")

------------------------------------------
-- Load Factions
------------------------------------------
Msg("Loading Factions Server Files\n")

-- Never change this, it's a lock for while switching to war mode.
-- Yeah, I know it's hacky but so is the rest of the gamemode so I'm not too worried
-- philxyz
PropSpawningAllowed = true

include( "shared.lua" )
include( "config.lua" )
include( "server/spawning.lua" )
include( "server/concommands.lua" )
include( "server/core.lua" )
include( "server/defaults.lua" )
include( "server/utility.lua" )
include( "server/entdamagesystem.lua" )
include( "server/sv_orbit.lua" )
include( "server/moneysystem.lua" )

Msg("Adding Client Side Lua Files to Download Lists\n")
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "config.lua" )
AddCSLuaFile( "client/core.lua" )
AddCSLuaFile( "client/utility.lua" )
AddCSLuaFile( "client/jukebox.lua" )
AddCSLuaFile( "client/usermessages.lua" )
AddCSLuaFile( "client/concommands.lua" )
AddCSLuaFile( "client/spawnmenu.lua" )

AddCSLuaFile( "client/GUI/buttontext.lua" )
AddCSLuaFile( "client/GUI/textnotices.lua" )
AddCSLuaFile( "client/GUI/flagvgui.lua" )
AddCSLuaFile( "client/GUI/modifyscreencolor.lua" )
AddCSLuaFile( "client/GUI/spawnpointmenu/spawnpointmenu.lua" )
AddCSLuaFile( "client/GUI/helpmenu/helpmenu.lua" )
AddCSLuaFile( "client/GUI/teammenu/team.lua" )
AddCSLuaFile( "client/GUI/scoreboard/cl_scoreboard.lua" )
AddCSLuaFile( "client/GUI/scoreboard/player_frame.lua" )
AddCSLuaFile( "client/GUI/scoreboard/player_row.lua" )
AddCSLuaFile( "client/GUI/scoreboard/scoreboard.lua" )
AddCSLuaFile( "client/GUI/statusbar/statusbar.lua" )
AddCSLuaFile( "client/GUI/swepmenu/swepmenu.lua" )
AddCSLuaFile( "client/GUI/swepmenu/button.lua" )
AddCSLuaFile( "client/GUI/trademenu/trademenu.lua" )
AddCSLuaFile( "client/GUI/spawnmenu/creationmenu/weapons.lua" )
AddCSLuaFile( "client/GUI/spawnmenu/controls/fac_weaponbutton.lua" )

Msg("\n--------------------\n")
Msg("Mounting Resources\n")
Msg("--------------------\n")
------------------------------------------
-- Mount Resources
------------------------------------------

local vortcolors = { "red" }--, "green", "blue" }
local flagmdlend = { ".dx80.vtx", ".dx90.vtx", ".mdl", ".phy", ".sw.vtx", ".vvd" }
local materials  = { ".vtf", ".vmt" }

for k,v in pairs( vortcolors ) do
	resource.AddFile("models/alien_" ..v.. ".dx80.vtx")
	resource.AddFile("models/alien_" ..v.. ".dx90.vtx")
	resource.AddFile("models/alien_" ..v.. ".mdl")
	resource.AddFile("models/alien_" ..v.. ".phy")
	resource.AddFile("models/alien_" ..v.. ".sw.vtx")
	resource.AddFile("models/alien_" ..v.. ".vvd")
	resource.AddFile("models/alien_" ..v.. ".xbox.vtx")
end

for k,v in pairs( flagmdlend ) do
	resource.AddFile( "models/katharsmodels/flags/flag08" .. v )
	resource.AddFile( "models/katharsmodels/flags/flag27" .. v )
	resource.AddFile( "models/katharsmodels/flags/flag36" .. v )
end

Msg( "\n" )

for k,v in pairs( materials ) do
	resource.AddFile( "materials/katharsmodels/flags/flag08" .. v )
	resource.AddFile( "materials/katharsmodels/flags/flag27" .. v )
	resource.AddFile( "materials/katharsmodels/flags/flag36" .. v )
	--[[
	resource.AddFile( "materials/gui/menu/main_off" .. v )
	resource.AddFile( "materials/gui/menu/main_alien" .. v )
	resource.AddFile( "materials/gui/menu/main_human" .. v )
	
	resource.AddFile( "materials/gui/helpmenu/help_bg" .. v )
	
	resource.AddFile( "materials/gui/scoreboard/alienheader2" .. v )
	resource.AddFile( "materials/gui/scoreboard/bg" .. v )
	resource.AddFile( "materials/gui/scoreboard/humanheader2" .. v )
	resource.AddFile( "materials/gui/scoreboard/logo" .. v )
	
	resource.AddFile( "materials/gui/swepmenu/base" .. v )
	resource.AddFile( "materials/gui/swepmenu/button" .. v )
	resource.AddFile( "materials/gui/swepmenu/button2" .. v )
	--]]
end
resource.AddFile("materials/rocks/rockwall015a.vmt")

Msg( "\n" )

resource.AddFile("resource/fonts/middages.ttf")

Msg( "\n" )

if file.Exists("factions/stools.txt", "DATA") then
	fac_Stools = util.KeyValuesToTable( file.Read("factions/stools.txt", "DATA") )
	
	if type(fac_Stools) ~= "table" or type(fac_Stools.turret) ~= "table" or type(fac_Stools.turret.cost) ~= "number" then
		fac_Error("Factions stools file malformed! Replacing the malformed file with a default stools file. The malformed file has been saved to: data/factions/malformed_stools.txt", "data/factions/stools.txt")
		file.Write("factions/malformed_stools.txt", file.Read("factions/stools.txt", "DATA"))
		file.Write("factions/stools.txt", Factions.DefaultTools)
			
		fac_Stools = util.KeyValuesToTable( Factions.DefaultTools )
	elseif not fac_Stools.ver or tonumber(fac_Stools.ver) < 2 then
		fac_Msg("Factions stools file is outdated. Saving old file to: data/factions/old_stools.txt")
		file.Write("factions/old_stools.txt", util.TableToKeyValues(fac_Stools))
		file.Write("factions/stools.txt", Factions.DefaultTools)
		
		fac_Stools = util.KeyValuesToTable( Factions.DefaultTools )
	end
else
	fac_Msg("Unable to find stools file. Creating one from defaults.")
	file.Write("factions/stools.txt", Factions.DefaultTools)
	
	fac_Stools = util.KeyValuesToTable( Factions.DefaultTools )
end

resource.AddFile("data/factions/stools.txt")

Msg( "\n" )

if not file.Exists( "factions/musicdata.txt", "DATA" ) then
	file.Write( "factions/musicdata.txt", Factions.DefaultMusic )
	
	fac_Msg( "data/factions/musicdata.txt not found, creating one from defaults." )
end

fac_addonsongs = util.KeyValuesToTable( file.Read( "factions/musicdata.txt", "DATA" ) )

if type(fac_addonsongs) ~= "table" then
	fac_Error("Factions music data file malformed! Replacing the malformed file with a default music data file. The malformed file has been saved to: data/factions/malformed_musicdata.txt", "data/factions/musicdata.txt")
	file.Write("factions/malformed_musicdata.txt", file.Read("factions/musicdata.txt", "DATA"))
	file.Write("factions/musicdata.txt", Factions.DefaultMusic)
			
	fac_addonsongs = util.KeyValuesToTable( Factions.DefaultMusic )
end

for path,length in pairs( fac_addonsongs ) do
	if Factions.Config.ForceClientMusicDownload then
		if file.Exists( "sound/" .. path, "GAME" ) then
				resource.AddFile( "sound/" .. path )
				fac_Msg("Mounted sound/" .. path)
		else
			fac_Error( "Unable to find sound/" .. path .. "!" )
		end
	else
		fac_Msg("Not mounting sound/" .. path)
	end
end

local str
local say
if Factions.Config.CopyShips and Factions.Addons.AdvDup then
	str = "\nAdvanced Duplicator detected\n"
	for k,v in pairs(Factions.Ships) do
		if not file.Exists("adv_duplicator/=Public Folder=/" .. k .. ".txt", "DATA") then
			str = str .. "[FAC] Adding Factions ship to advanced duplicator: " .. k .. "\n"
			file.Write("adv_duplicator/=Public Folder=/" .. k .. ".txt", v)
			say = true
		end
	end
	Msg(Factions.ShipsErrors .. "\n")
end
if say then Msg(str) end

Msg("\nResources Mounted\n")

Msg("\n--------------------\n")
Msg("Implementing Overwrites\n")
Msg("--------------------\n")

gamemode.Call( "Overwrite" )

Msg( "\n" )

Msg("------------------------\n")
Msg("Factions Server Loaded\n")
Msg("------------------------\n\n")
