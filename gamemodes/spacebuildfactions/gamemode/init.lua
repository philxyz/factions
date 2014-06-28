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

AddCSLuaFile( "client/gui/textnotices.lua" )
AddCSLuaFile( "client/gui/buttontext.lua" )
AddCSLuaFile( "client/gui/flagvgui.lua" )
AddCSLuaFile( "client/gui/modifyscreencolor.lua" )
AddCSLuaFile( "client/gui/spawnpointmenu/spawnpointmenu.lua" )
AddCSLuaFile( "client/gui/helpmenu/helpmenu.lua" )
AddCSLuaFile( "client/gui/teammenu/team.lua" )
AddCSLuaFile( "client/gui/scoreboard/cl_scoreboard.lua" )
AddCSLuaFile( "client/gui/scoreboard/player_frame.lua" )
AddCSLuaFile( "client/gui/scoreboard/player_row.lua" )
AddCSLuaFile( "client/gui/scoreboard/scoreboard.lua" )
AddCSLuaFile( "client/gui/statusbar/statusbar.lua" )
AddCSLuaFile( "client/gui/swepmenu/swepmenu.lua" )
AddCSLuaFile( "client/gui/swepmenu/button.lua" )
AddCSLuaFile( "client/gui/trademenu/trademenu.lua" )
AddCSLuaFile( "client/gui/spawnmenu/creationmenu/weapons.lua" )
AddCSLuaFile( "client/gui/spawnmenu/controls/fac_weaponbutton.lua" )

Msg("\n--------------------\n")
Msg("Mounting Resources\n")
Msg("--------------------\n")
------------------------------------------
-- Mount Resources
------------------------------------------

Msg( "Sending models to client\n" )

resource.AddFile("models/katharsmodels/flags/flag08.mdl")
resource.AddFile("models/katharsmodels/flags/flag27.mdl")
resource.AddFile("models/katharsmodels/flags/flag36.mdl")

resource.AddFile("models/bluevort.mdl")
resource.AddFile("models/greenvort.mdl")
resource.AddFile("models/redvort.mdl")

resource.AddFile("models/alien_red.mdl")
resource.AddFile("models/alien_green.mdl")
resource.AddFile("models/alien_blue.mdl")

Msg( "Sending materials to client\n" )

resource.AddFile( "materials/gui/helpmenu/help_bg.vmt" )

resource.AddFile( "materials/gui/menu/main_alien.vmt" )
resource.AddFile( "materials/gui/menu/main_human.vmt" )
resource.AddFile( "materials/gui/menu/main_off.vmt" )

resource.AddFile( "materials/gui/scoreboard/alienheader.vmt" )
resource.AddFile( "materials/gui/scoreboard/bg.vmt" )
resource.AddFile( "materials/gui/scoreboard/humanheader.vmt" )
resource.AddFile( "materials/gui/scoreboard/logo.vmt" )

resource.AddFile( "materials/gui/swepmenu/base.vmt" )
resource.AddFile( "materials/gui/swepmenu/button.vmt" )
resource.AddFile( "materials/gui/swepmenu/button2.vmt" )

resource.AddFile( "materials/katharsmodels/flags/flag08.vmt" )
resource.AddFile( "materials/katharsmodels/flags/flag27.vmt" )
resource.AddFile( "materials/katharsmodels/flags/flag36.vmt" )

resource.AddFile( "materials/models/vortigaunt/bluevort_sheet.vmt" )
resource.AddFile( "materials/models/vortigaunt/eyeball_blue.vmt" )
resource.AddFile( "materials/models/vortigaunt/eyeball_green.vmt" )
resource.AddFile( "materials/models/vortigaunt/greenvort_sheet.vmt" )
resource.AddFile( "materials/models/vortigaunt/pupil_blue.vmt" )
resource.AddFile( "materials/models/vortigaunt/pupil_green.vmt" )

resource.AddFile( "materials/rocks/rockwall015a.vmt" )

resource.AddFile( "materials/credits.vmt" )
resource.AddFile( "materials/marssand.vmt" )
resource.AddFile( "materials/marssandblend.vmt" )
resource.AddFile( "materials/martionsilt.vmt" )

Msg( "Sending resources to client\n" )

resource.AddFile("resource/fonts/middages.ttf")

Msg( "Sending music to client\n" )

resource.AddFile("sound/music/GlobalRP1.mp3")
resource.AddFile("sound/music/GlobalRP2.mp3")
resource.AddFile("sound/music/GlobalRP3.mp3")
resource.AddFile("sound/music/GlobalRP4.mp3")
resource.AddFile("sound/music/GlobalRP5.mp3")

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
