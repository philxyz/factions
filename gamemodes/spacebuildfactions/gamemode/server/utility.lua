------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

function Factions.Notify( ply, msg, typ, time, nick, sound, silent )
	if not time then time = 5 end
	if not silent then
		if tostring(typ) == "NOTIFY_GENERIC" then
			sound = "ambient/water/drip"..math.random(1, 4)..".wav"
		elseif tostring(typ) == "NOTIFY_ERROR" then
			sound = "buttons/button10.wav"
		else
			sound = "buttons/button15.wav"
		end
		ply:PlaySound(sound)
	end
	umsg.Start( "_Caption", ply )
		umsg.String(msg)
		umsg.Short(typ)
		umsg.Short(time)
	umsg.End()
	if not nick then
		fac_Msg( ply:Nick().. ": " ..tostring(msg) )
	else
		fac_Msg( tostring(msg) )
	end
end

function Factions.GetEntOwner( ent )
	local tbl = ent:GetTable()

	local ply = tbl.ply or tbl.Founder
	
	--if we don't have a player try to extract one from its undo code
	if not ply then
		if type(tbl.OnDieFunctions) == "table" then
			if type(tbl.OnDieFunctions.GetCountUpdate) == "table" and not ply then
				if type(tbl.OnDieFunctions.GetCountUpdate.Args) == "table" then
					for _,p in pairs(tbl.OnDieFunctions.GetCountUpdate.Args) do
						if (type(p) == "Player") and (not ply) then
							ply = p
							break
						end
					end
				end
			end
			if not ply then
				for k,v in pairs(tbl.OnDieFunctions) do
					if ply then break end
					if string.find(k,"undo") and type(v) == "table" then
						if type(v.Args) == "table" then
							for _,p in pairs(v.Args) do
								if (type(p) == "Player") and (not ply) then
									ply = p
									break
								end
							end
						end
					end
				end
			end
		end
	end
	
	if ply then ent.ply = ply end
	
	return ply
end

function Factions.ConvertID( arg )
	if type(arg) == "Player" and arg:IsValid() then
		local id = arg:UniqueID()
		id = string.gsub( id, ":", ";" ) or id
		return id
	elseif type(arg) == "string" then
		local id = string.gsub( arg, ";", ":" ) or id
		for k,v in pairs(player.GetAll) do
			if v:UniqueID() == id then
				return v
			end
		end
	end
	fac_Error( "Error Converting ID for " ..tostring(arg) )
	return "ERROR"
end

function Factions.GetPlayerFromString( arg )
	for k,v in pairs( player.GetAll() ) do
		if string.find( string.lower( v:Nick() ), string.lower( arg ) ) then
			return v
		end
	end
end

function Factions.SortTable( table ) --not sure why a working version of table.sort wasn't included in garrysmod..
	for k,v in pairs(table) do
		if type(k) == "number" then
			if (k - 1) ~= 0 then -- truly sort it, as opposed to table.sort shit
				if table[ k - 1 ] == nil then
					table[ k - 1 ] = v
					table[k] = nil
					return Factions.SortTable(table)
				end
			end
		end
	end
	
	return table
end

function Factions.ModifyWeapon( wep, ply )
	if not wep or not wep:IsValid() then return end

	local SWEP = wep:GetTable()
	local ammotype
	local IsStool
	if SWEP.ClassName == "weapon_ak47" or SWEP.ClassName == "weapon_m4" then
		ammotype = "AR2"
	elseif SWEP.ClassName == "weapon_para" then
		ammotype = "AlyxGun"
	end
	
	SWEP.Owner = ply
	
	if not SWEP.Primary then return end
		SWEP.Primary.DefaultClip = SWEP.Primary.ClipSize
		SWEP.Primary.Ammo        = ammotype or SWEP.Primary.Ammo

	if Factions.Config.ForceIronsights then
		SWEP.SetIronsights	= function () end
		SWEP.DeployMain		= SWEP.Deploy
		SWEP.Deploy			= function () SWEP.Weapon:SetNWBool( "Ironsights", true ); SWEP:DeployMain(); end
	end
	
	if not ply then return end
	local plyammo = ply:GetAllAmmo()
	ply:StripAmmo()
	for k,v in pairs(plyammo) do
		if k == SWEP.Primary.Ammo then
			ply:GiveAmmo( v - SWEP.Primary.DefaultClip, k, true )
		else
			ply:GiveAmmo( v, k, true )
		end
	end
end

function Factions.GetEntBorders( ent ) --used in stone_base
	local borders = {}
	borders.x = {}
	borders.y = {}
	borders.z = {}
	local maxX = ent:NearestPoint( ent:GetPos() + Vector(1000,0,0) )
	borders.x[1] = maxX.x
	local maxNX = ent:NearestPoint( ent:GetPos() + Vector(-1000,0,0) )
	borders.x[2] = maxNX.x
		
	local maxY = ent:NearestPoint( ent:GetPos() + Vector(0,1000,0) )
	borders.y[1] = maxY.y
	local maxNY = ent:NearestPoint( ent:GetPos() + Vector(0,-1000,0) )
	borders.y[2] = maxNY.y
		
	local maxZ = ent:NearestPoint( ent:GetPos() + Vector(0,0,1000) )
	borders.z[1] = maxZ.z
	local maxNZ = ent:NearestPoint( ent:GetPos() + Vector(0,0,-1000) )
	borders.z[2] = maxNZ.z + 100 --attempt to stop rocks from spawning underground
	return borders
end

function Factions.CCCheckPlayer( ply ) --arg1 = can they use it?,  arg2 = are they console?
	if ply and ply:IsValid() then
		if not ply:IsAdmin() then
			ply:PrintConsole( '[FAC Config] Sorry, you do not have access to that command, ' ..ply:Nick() )
			ply:ChatPrint( '[FAC Config] Sorry, you do not have access to that command, ' ..ply:Nick() )
			return false, false
		end
	else
		return true, true
	end
	
	return true, false
end

function Factions.CCPrintHelp( descrip, options, cur, ply )
	if ply and ply:IsValid() then
		ply:PrintConsole('\n*******FAC HELP*******')
		ply:PrintConsole(descrip .. '\n' )
		ply:PrintConsole('Possible options are:\n' )
		
		local str = ""
		for k,v in pairs(options) do
			str = str .. '"' .. tostring(v) .. '", '
		end
		ply:PrintConsole(string.sub(str,1,-3) .. '.\n')
		
		if cur then ply:PrintConsole('Currently Set To: ' ..tostring(cur).. '\n' ) end
		
		ply:PrintConsole('*******FAC HELP*******\n')
	else
		Msg('\n*******FAC HELP*******')
		Msg(descrip .. '\n')
		Msg('Possible options are:\n')
		
		local str = ""
		for k,v in pairs(options) do
			str = str .. '"' .. tostring(v) .. '", '
		end
		Msg(string.sub(str,1,-3) .. '.\n')
		
		if cur then Msg(cur .. '\n' ) end
		
		Msg('*******FAC HELP*******\n')
	end
end

----------------------------------------------
-- Player: Additions
----------------------------------------------

local meta = FindMetaTable( "Player" )

function SendUserMessage( name, ply, ... ) --garry screwed up so I had to fix it

	umsg.Start( name, ply )
	
	for k, v in pairs( {...} ) do
	
		local t = type( v )
		
		if ( t == "string" ) then
			umsg.String( v )
		elseif ( t == "entity" ) then
			umsg.Entity( v )
		elseif ( t == "number" ) then
			umsg.Long( v )
		elseif ( t == "Vector" ) then
			umsg.Vector( v )
		elseif ( t == "Angle" ) then
			umsg.Angle( v )
		elseif ( t == "boolean" ) then --garry put t == "bool", should be t == "boolean"
			umsg.Bool( v )
		else
			ErrorNoHalt( "SendUserMessage: Couldn't send type "..t.."\n" )
		end
	end
	
	umsg.End()

end

function meta:Umsg( str, ... )
	SendUserMessage( str, self, ... )
end

local strLen = 200 --length of each string part. this shouldn't need to be ever changed
function meta:UmsgLarge(str,str2) --accepts a table, returns a table. uses util.TableToKeyValues and util.KeyValuesToTable, so some data may be lost
	if type(str2) == "table" then str2 = util.TableToKeyValues(str2) end
	local len = string.len(str2)
	
	fac_Msg("Sending large usermessage " ..str.. " (len " ..len.. ") to " ..self:Nick())

	for x=0, math.Round( string.len(str2)/strLen ) do
		local start = x*strLen + x + 1
		local End = start + strLen
		
		if start <= len then
			local last
			if End >= len then End = len; last = true end
			
			--fac_Msg( "[" .. tym .. "] Sending Umsg from " ..start.. " to " ..End)
			--timer.Simple(tym, self.Umsg, self, "GlobalRP LargeUmsg", str, string.sub(str2,start,End), last )
			self:Umsg( "Factions LargeUmsg", str, string.sub(str2,start,End), last )
		end
	end
end

function meta:Money()
	if self:GetNWInt("money") then return self:GetNWInt("money") else return 0 end
end

function meta:AddMoney(amt)
	local m = self:GetNWInt("money")
	if m then
		self:SetNWInt("money", m + amt)
	else
		self:SetNWInt("money", amt)
	end
	umsg.Start("DrawNotice", self)
		umsg.String("$")
		umsg.Short(amt)
	umsg.End()
end

function meta:PlaySound(file)
	umsg.Start("_PlaySound", self)
		umsg.String(file)
	umsg.End()
end

function meta:_Call(f, a, b)
	umsg.Start("_gmCall")
		umsg.String(f)
		umsg.String(a)
		umsg.String(b)
	umsg.End()
end

function meta:GetAllAmmo() --returns table[class] = amount
	local table = {}
	for k,v in pairs(AMMOTYPES) do
		if self:GetAmmoCount( v ) > 0 then
			table[v] = self:GetAmmoCount( v )
		end
	end
	return table
end
	
function meta:GiveWeapon( wepclass )
	self:Give( wepclass )
	Factions.ModifyWeapon( self:GetWeapon( wepclass ), self )
end
	
function meta:PrintConsole( msg )
	self:PrintMessage( HUD_PRINTCONSOLE, msg.. '\n' )
end
	
function meta:PrintChat( msg )
	self:ChatPrint( msg )
end
	
function meta:Notify( msg, type, time, nick, sound, silent )
	Factions.Notify( self, msg, type, time, nick, sound, silent )
end

local flagmodels = {}
flagmodels[ TEAM_ALIENS ] = "models/katharsmodels/flags/flag36.mdl"
flagmodels[ TEAM_HUMANS ] = "models/katharsmodels/flags/flag27.mdl"
flagmodels.neutral        = "models/katharsmodels/flags/flag08.mdl"
function meta:ChangeTeam( newteam, overrideATB )
	if not gamemode.Call("CanPlayerJoinTeam", self, newteam ) and not overrideATB then
		Factions.Notify( self, "Joining That Team Would Unbalance The Teams.", "NOTIFY_ERROR" )
		MsgAll( '[FAC] Admins can type "fac_autoteambalance 0" in console to disable autoteambalance.' )
		return false
	end
	if self:InVehicle() then self:ExitVehicle() end
	if not self:Alive() then return end
	
	local oldteamname = team.GetName( self:Team() )
	local newteamname = team.GetName( newteam )
	
	if self.mode == "War" then --update team flag counts
		for _, pl in pairs( player.GetAll() ) do
			plyvar[ pl ].flags = 0
		end
		for _,flag in pairs( self.flags ) do
			if flag.fac_owner then
				plyvar[ flag.fac_owner ].flags = plyvar[ flag.fac_owner ].flags + 1
			end
		end
	
		Factions.SetNWVar( oldteamname .. "Planets", Factions.GetNWVar( oldteamname .. "Planets", 0 ) - plyvar[ self ].flags )
		Factions.SetNWVar( newteamname .. "Planets", Factions.GetNWVar( newteamname .. "Planets", 0 ) + plyvar[ self ].flags )
	end
		
	local mode = Factions.GetNWVar( "Mode", "" ) --update flag models
	local flags = gmod.GetGamemode().flags
	if mode == "Free" then
		for _,flag in pairs( flags ) do
			if flag.fac_owner == self then
				flag:SetModel( flagmodels[ self:Team() ] )
			end
		end
	end
	
	plyvar[ self ].paychecktimer = 0
		
	for k, v in pairs( player.GetAll() ) do
		if v ~= ply then
			v:ChatPrint( self:Nick().. " Has Joined The " .. newteamname .. " Team." )
		end
	end
		
	self:SetTeam( newteam )
	
	local weapons = self:GetWeapons()
	local ammo    = self:GetAllAmmo()
		
	self:Spawn()
		
	for k,v in pairs( weapons ) do
		self:GiveWeapon( v:GetClass(), true )
	end
	for k,v in pairs( ammo ) do
		self:GiveAmmo( v, k, true )
	end
		
	return true
end
	
function meta:ModifyScreenColor( color, lasting )
	umsg.Start( "ModifyColor", self )
		umsg.Short( color.r )
		umsg.Short( color.g )
		umsg.Short( color.b )
		umsg.Bool( lasting )
	umsg.End()
end

--------------------------------------------------
-- Networked Variables
--------------------------------------------------
--since garry's networked variable functions are all buggy and unreliable I had to make some of my own

Factions.NWVars = {}
function Factions.SetNWVar( index, var )
	for _,pl in pairs( player.GetAll() ) do
		local work, msg = pcall(pl.Umsg, pl, "fac_NWVar", type(index), index, type(var), var)
		
		if not work and msg then
			error(msg,2)
		end
	end
	
	Factions.NWVars[index] = var
	
	--fac_Debug("Networked Variable Set: " .. tostring(index) .. " = " .. tostring(var))
end

function Factions.GetNWVar( index, default )
	return Factions.NWVars[index] or default
end

local function HookUpNWVars( pl )
	for k,v in pairs( Factions.NWVars ) do
		pl:Umsg( "fac_NWVar", type(k), k, type(v), v )
		--fac_Debug("Sending variable to client: " .. tostring(k) .. " = " .. tostring(v))
	end
end
hook.Add("PlayerInitialSpawn","fac_HookUpNWVars",HookUpNWVars)

----------------------------------------------
-- Entity: Additions
----------------------------------------------

local meta = FindMetaTable( "Entity" )

function meta:Armor()
	if self.fac_armor then return self.fac_armor end
	
	Factions.SetEntityArmor(self,0)
	return 0
end
