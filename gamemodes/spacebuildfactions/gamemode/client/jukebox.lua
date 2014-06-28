------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local Juke_Initialized = false

local music = { ["music/HL1_song3.mp3"] = 131, ["music/HL1_song5.mp3"] = 96, ["music/HL1_song6.mp3"] = 100, ["music/HL1_song9.mp3"] = 93, ["music/HL1_song10.mp3"] = 104, ["music/HL1_song14.mp3"] = 90, ["music/HL1_song15.mp3"] = 120, ["music/HL1_song17.mp3"] = 123, ["music/HL1_song20.mp3"] = 84, ["music/HL1_song21.mp3"] = 84, ["music/HL1_song25_REMIX3.mp3"] = 61, ["music/HL1_song26.mp3"] = 37, ["music/HL2_song1.mp3"] = 98, ["music/HL2_song2.mp3"] = 172, ["music/HL2_song3.mp3"] = 90, ["music/HL2_song4.mp3"] = 65, ["music/HL2_song7.mp3"] = 50, ["music/HL2_song8.mp3"] = 59, ["music/HL2_song12_long.mp3"] = 73, ["music/HL2_song13.mp3"] = 53, ["music/HL2_song14.mp3"] = 159, ["music/HL2_song15.mp3"] = 69, ["music/HL2_song16.mp3"] = 170, ["music/HL2_song17.mp3"] = 61, ["music/HL2_song20_submix0.mp3"] = 103, ["music/HL2_song20_submix4.mp3"] = 139, ["music/HL2_song23_SuitSong3.mp3"] = 43, ["music/HL2_song26_trainstation1.mp3"] = 90, ["music/HL2_song27_trainstation2.mp3"] = 72, ["music/HL2_song29.mp3"] = 135, ["music/HL2_song30.mp3"] = 104, ["music/HL2_song31.mp3"] = 98, ["music/HL2_song32.mp3"] = 42, ["music/HL2_song33.mp3"] = 84 }

if file.Exists( "factions/musicdata.txt", "DATA" ) then
	local addonsongs = util.KeyValuesToTable( file.Read( "factions/musicdata.txt", "DATA" ) )
	table.Merge( music, addonsongs )
end

local songnames = {}
local songlengths = {}
for k,v in pairs(music) do
	if file.Exists( "sound/" .. k, "GAME" ) then
		table.insert(songnames, k)
		table.insert(songlengths, v)
	else
		fac_Msg("Unable to find song sound/" .. k)
	end
end
local played = {}
local song = {}
song.starttime = 0
song.length = 0
local schoolme

------------------------------------------
--     Utility
------------------------------------------
function Factions.NextSong()
	song.name, song.length, song.starttime = Factions.GrabSong()
	surface.PlaySound( song.name )
		
	local name = string.gsub( song.name, "music/", "" )
	name = string.gsub( name, ".mp3", "" )
		
	Msg( "[FAC Jukebox] Now Playing: " ..name .. "\n" )
end

function Factions.PlaySong( song )
	local poss = {}
	local k
	for name,length in pairs( music ) do
		if string.find( string.lower( name ), string.lower( song ) ) then
			poss[ name ] = length
			k = name
		end
	end
	local amt = table.Count( poss )
	if amt > 1 then
		Msg( "[FAC Jukebox] More than one song found, please be more specific.\n" )
		return
	elseif amt < 1 then
		Msg( "[FAC Jukebox] Unable to find a song by the name of " .. args[1] .. ".\n" )
		return
	end
	
	RunConsoleCommand("stopsounds")
	
	song.name = k
	song.length = poss[ k ]
	song.starttime = CurTime() + 1
	
	timer.Simple( 1, function() surface.PlaySound(song.name) end )
end

function Factions.GrabSong() --grabs a random song out of the available playlist
	if table.getn(played) == table.getn(songnames) then
		played = {}
		return Factions.GrabSong()
	end
	local rannum = math.random(1, table.getn(songnames))
	
	for k,v in pairs(played) do
		if v == rannum then
			return Factions.GrabSong()
		end
	end
	
	table.insert(played, rannum)
	return songnames[rannum], songlengths[rannum], CurTime()
end

------------------------------------------
--      Hooks
------------------------------------------
usermessage.Hook("musicst", function()
	if Juke_Initialized then return end

	if file.Exists("factions/music.txt", "DATA") then
		local music1 = file.Read("factions/music.txt", "DATA")

		if music1 == "true" then Factions.music = true else Factions.music = false end
	end

	if Factions.music == true then
		song.name = "music/globalrp4.mp3"
		song.length = 95
		song.starttime = CurTime()
		surface.PlaySound( song.name )
			
		local name = string.gsub( song.name, "music/", "" )
		name = string.gsub( name, ".mp3", "" )
			
		Msg( "[FAC Jukebox] Now Playing: " .. name .. "\n" )
		
		RunConsoleCommand( "fac_music", "1" )
		schoolme = true
	end
	Juke_Initialized = true
end)

local function JukeThink()
	if song.starttime + song.length + 2 < CurTime() and Factions.music then
		Factions.NextSong()
	end
end
hook.Add("Think", "FAC Jukebox Think", JukeThink)

------------------------------------------
--   Usermessage
------------------------------------------
local function AddonSongs( tbl )
	table.Merge( music, tbl )
end
usermessage.HookLarge( "addonsongs", AddonSongs )

------------------------------------------
--   Concommands
------------------------------------------
local function fac_OneTwoAC() return {"0","1",""} end
--Autocomplete

local function Music( ply, cmd, args )
	if not args[1] then return end
	if args[1] == "1" then
		file.Write( 'factions/music.txt', 'true' )
		
		Factions.music = true
		fac_Msg("Music Enabled")
	elseif args[1] == "0" then
		file.Write( 'factions/music.txt', 'false' )
		
		Factions.music = false
		Msg("[FAC Jukebox] Music Disabled\n")
		
		RunConsoleCommand("stopsounds")
		song.length = 0
		song.starttime = 0
	end
end
concommand.Add( "fac_music", Music, fac_OneTwoAC )

local function NextTrack( ply, cmd, args ) --developers use Factions.NextSong instead
	RunConsoleCommand("stopsounds")
	
	song.length = 0
	
	song.starttime = CurTime()
	Factions.music = true
end
concommand.Add( "fac_nexttrack", NextTrack )

local function PlaySongCC( ply, cmd, args )
	if not args or args[1] == "" then return end
	
	Factions.PlaySong( args[1] )
end
local function PlaySongAC(_,arg) --autocomplete
	if arg then
		arg = string.lower(string.sub(arg,2)) --theres a space at the front of it
	else arg = "" end
	
	local output = {};
	for k,v in pairs(music) do
		if not arg or arg == "" or string.find(string.lower(k),arg) then
			table.insert(output,k)
		end
	end
	table.insert(output,"")
	return output
end
concommand.Add( "fac_playsong", PlaySongCC, PlaySongAC )
