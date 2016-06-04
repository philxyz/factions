------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local function SchoolMe( umsg )
	if schoolme then
		RunConsoleCommand( "fac_schoolme" )
		schoolme = false
	end
end
usermessage.Hook( "schooltime", SchoolMe )

local function _Caption(msg)
	GAMEMODE:AddNotify(msg:ReadString(), msg:ReadShort(), msg:ReadShort())
end
usermessage.Hook("_Caption", _Caption)

local function _PlaySound(msg)
	surface.PlaySound(msg:ReadString())
end
usermessage.Hook("_PlaySound", _PlaySound)

local function _Call(msg)
	gamemode.Call(msg:ReadString(), msg:ReadString(), msg:ReadString())
end
usermessage.Hook("_gmCall", _Call)

local function GetFACStoolsTable( tbl ) --called if for some reason it bugged and the client was unable to load their stools file (or their stools file was malformed)
	Factions.Stools = tbl
	file.Write( "factions/stools.txt", util.TableToKeyValues( tbl ) )
end
usermessage.HookLarge("fac_stools", GetFACStoolsTable)

local function NWVarUmsg(umsg)
	local t = umsg:ReadString()
	local index
	
	if ( t == "string" ) then
		index = umsg:ReadString()
	elseif ( t == "entity" ) then
		index = umsg:ReadEntity()
	elseif ( t == "number" ) then
		index = umsg:ReadLong()
	elseif ( t == "Vector" ) then
		index = umsg:ReadVector()
	elseif ( t == "Angle" ) then
		index = umsg:ReadAngle()
	elseif ( t == "boolean" ) then
		index = umsg:ReadBool()
	end
	
	t = umsg:ReadString()
	local var
	
	if ( t == "string" ) then
		var = umsg:ReadString()
	elseif ( t == "entity" ) then
		var = umsg:ReadEntity()
	elseif ( t == "number" ) then
		var = umsg:ReadLong()
	elseif ( t == "Vector" ) then
		var = umsg:ReadVector()
	elseif ( t == "Angle" ) then
		var = umsg:ReadAngle()
	elseif ( t == "boolean" ) then
		var = umsg:ReadBool()
	end
	
	Factions.NWVars[index] = var

	--fac_Debug("Received Networked Variable: " .. tostring(index) .. " = " .. tostring(var))
end
usermessage.Hook("fac_NWVar",NWVarUmsg)
