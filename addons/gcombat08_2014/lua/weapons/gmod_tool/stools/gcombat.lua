
TOOL.Category		= "Construction"
TOOL.Name			= "#gcombat"
TOOL.Command		= nil
TOOL.ConfigName		= ""

TOOL.ClientConVar[ "gtype" ] = "0"
TOOL.ent = {}

if (SERVER) then
	CreateConVar('sbox_maxgcombat', 10)
end

cleanup.Register( "gcombat" )


// Add Default Language translation (saves adding it to the txt files)
if ( CLIENT ) then

	language.Add( "tool.gcombat.name", "Gcombat tool" )
	language.Add( "tool.gcombat.desc", "Adds weaponry to things." )
	language.Add( "tool.gcombat.0", "Left click to apply the selected object. Right click for a secondary placement. Reload for Info on the selection." )
	
	language.Add( "tool.turret.type", "Weapon type" )
	
	language.Add( "tool.gcombat.help0", "Fires high-powered anti-tank shots and has a secondary anti-infantry shell." )
	language.Add( "tool.gcombat.help1", "High reload rate light cannon, perfect for fast vehicles." )
	language.Add( "tool.gcombat.help2", "Fires a tunable high powered energy beam that fries essential components." )
	language.Add( "tool.gcombat.help3", "Long ranged artillery, poses a serious risk of self harm at close range." )
	language.Add( "tool.gcombat.help4", "Launches a very powerful aquatic shell. Best used at a range of 1500 - 2500 world units." )
	language.Add( "tool.gcombat.help5", "Melee range energy weapon that deals a huge amount of damage when moved swiftly." )
	language.Add( "tool.gcombat.help6", "Press use on it to get an infantry weapon. The choices are: sapper, rifle, and mortar gun. Sappers can be placed on enemy vehicles manually. The sapper will fall off when severely damaged. \n Note that the ammo counters on the other two weapons appear broken at a glance. The sooner you figure out what they're actually for, the better. \n Bludgeon with crowbar to select." )
	language.Add( "tool.gcombat.help7", "Fires an extremely high-powered beam that will vaporise the toughest prop in a single hit." )
	language.Add( "tool.gcombat.help8", "Launches a swarm of rockets that deal quite a lot of damage, but tend to be inaccurate." )
	language.Add( "tool.gcombat.help9", "Charges up, and fires a hail of energy beams in a cone." )
	language.Add( "tool.gcombat.help10", "Defends against incoming projectile weapons, but is fooled by the sapper and the grenade cannon." )
	language.Add( "tool.gcombat.help11", "Melee range energy weapon that deals a huge amount of damage when moved swiftly. The beam is shorter than the beamsword, but deals significantly more damage." )
	language.Add( "tool.gcombat.help12", "Fires remote detonated grenades. Perfect for setting ambushes and breaking through heavy point defense." )
	language.Add( "tool.gcombat.help13", "Fires a powerful stream of fire, that you can kill it with." )
	language.Add( "tool.gcombat.help14", "Launches a swarm of homing rockets. Warning, these rockets have serious ADD." )
	language.Add( "tool.gcombat.help15", "Fires rapid fire energy bolts in a tight cone." )
	language.Add( "tool.gcombat.help16", "A very powerful homing weapon. Is incapable of hitting targets less than 800 world units above the launch position." )
	language.Add( "tool.gcombat.help17", "Artillery that fires a simple high explosive shot for indirect fire." )
	language.Add( "tool.gcombat.help18", "Warns of incoming homing missile attacks" )
	language.Add( "tool.gcombat.help19", "Long range missile" )
	
	language.Add( "Undone_gcombat", "Undone weapon" )
	
	language.Add( "Cleanup_gcombat", "Weapon" )
	language.Add( "Cleaned_gcombat", "Cleaned up all Weapons" )
	language.Add( "SBoxLimit_gcombat", "You've reached the Weapon limit!" )

end

function TOOL:LeftClick( trace )
if (CLIENT) then return true end
if ( !trace.Hit ) then return end
local ply = self:GetOwner()
if (!ply:CheckLimit( "gcombat" )) then return end
	
	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	
	local gtype	= self:GetClientNumber( "gtype" ) 
	
	local SpawnPos = trace.HitPos + trace.HitNormal * 4
	if (gtype == 0) then
	self.ent = ents.Create( "tank_gun" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 1) then
	self.ent = ents.Create( "2pdr" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 2) then
	self.ent = ents.Create( "flak_88" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 3) then
	self.ent = ents.Create( "nebelwerfer" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 4) then
	self.ent = ents.Create( "torpedo_launcher" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 5) then
	self.ent = ents.Create( "beamsword" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 6) then
	self.ent = ents.Create( "sapper_crate" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 7) then
	self.ent = ents.Create( "deathray" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 8) then
	self.ent = ents.Create( "aarockets" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 9) then
	self.ent = ents.Create( "plasmacannon" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 10) then
	self.ent = ents.Create( "point_defense" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 11) then
	self.ent = ents.Create( "beamdagger" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 12) then
	self.ent = ents.Create( "heavy_grenade" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 13) then
	self.ent = ents.Create( "flamethrower" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 14) then
	self.ent = ents.Create( "swarmerrocket" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 15) then
	self.ent = ents.Create( "pewpew" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 16) then
	self.ent = ents.Create( "samlaunch" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 17) then
	self.ent = ents.Create( "mortar" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 18) then
	self.ent = ents.Create( "lock_warn" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 19) then
	self.ent = ents.Create( "longrangemissile" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	end
	
	
	local phys = self.ent:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		local weld = constraint.Weld(self.ent, trace.Entity, 0, trace.PhysicsBone, 0)
		local nocollide = constraint.NoCollide(self.ent, trace.Entity, 0, trace.PhysicsBone)
	end 
	
	
	ply:AddCount( "gcombat", self.ent ) 
	
	undo.Create("gcombat")
		undo.AddEntity( self.ent )
		undo.AddEntity( weld )
		undo.AddEntity( nocollide )
		undo.SetPlayer( ply )
	undo.Finish()
	return true

end

function TOOL:RightClick( trace )
if (CLIENT) then return true end
if ( !trace.Hit ) then return end
local ply = self:GetOwner()
if (!ply:CheckLimit( "gcombat" )) then return end

	if ( SERVER && !util.IsValidPhysicsObject( trace.Entity, trace.PhysicsBone ) ) then return false end
	
	
	local gtype	= self:GetClientNumber( "gtype" ) 
	
	local SpawnPos = trace.HitPos + trace.HitNormal * 4
	if (gtype == 0) then
	self.ent = ents.Create( "tank_gun" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 1) then
	self.ent = ents.Create( "2pdr" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 2) then
	self.ent = ents.Create( "flak_88" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 3) then
	self.ent = ents.Create( "nebelwerfer" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 4) then
	self.ent = ents.Create( "torpedo_launcher" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 5) then
	self.ent = ents.Create( "beamsword" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 6) then
	self.ent = ents.Create( "sapper_crate" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 7) then
	self.ent = ents.Create( "deathray" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 8) then
	self.ent = ents.Create( "aarockets" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 9) then
	self.ent = ents.Create( "plasmacannon" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 10) then
	self.ent = ents.Create( "point_defense" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 11) then
	self.ent = ents.Create( "beamdagger" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 12) then
	self.ent = ents.Create( "heavy_grenade" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 13) then
	self.ent = ents.Create( "flamethrower" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 14) then
	self.ent = ents.Create( "swarmerrocket" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 15) then
	self.ent = ents.Create( "pewpew" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 16) then
	self.ent = ents.Create( "samlaunch" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 17) then
	self.ent = ents.Create( "mortar" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 18) then
	self.ent = ents.Create( "lock_warn" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	elseif (gtype == 19) then
	self.ent = ents.Create( "longrangemissile" )
		self.ent:SetPos( SpawnPos )
		self.ent:SetAngles( trace.HitNormal:Angle() + Angle(90,0,0))
	self.ent:Spawn()
	self.ent:Activate()
	end
	
	ply:AddCount( "gcombat", self.ent ) 
	undo.Create("gcombat")
		undo.AddEntity( self.ent )
		undo.SetPlayer( ply )
	undo.Finish()
	return true

end

function TOOL:Reload()
	local ply = self:GetOwner()
	local gtype	= self:GetClientNumber( "gtype" ) 
	ply:PrintMessage( HUD_PRINTTALK, "#Tool_gcombat_help" .. gtype )
end


if CLIENT then
function TOOL.BuildCPanel( CPanel )
	CPanel:ClearControls()
	--CPanel:AddHeader()
	--CPanel:AddDefaultControls()
	// HEADER
	CPanel:AddControl( "Header", { Text = "#tool.gcombat.name", Description	= "#tool.gcombat.desc" }  )
	
	
	// the pertenent cannon
	local Ctype = {Label = "#Tool_turret_type", MenuButton = 0, Options={}}
		Ctype["Options"]["#Tank gun"]	= { gcombat_gtype = "0" }
		Ctype["Options"]["#2pdr gun"]	= { gcombat_gtype = "1" }
		Ctype["Options"]["#Ion ray"]	= { gcombat_gtype = "2" }
		Ctype["Options"]["#Nebelwerfer"]	= { gcombat_gtype = "3" }
		Ctype["Options"]["#Torpedo (dumb)"]	= { gcombat_gtype = "4" }
		Ctype["Options"]["#Beam sword"]	= { gcombat_gtype = "5" }
		Ctype["Options"]["#Supply Crate"]	= { gcombat_gtype = "6" }
		Ctype["Options"]["#Deathray"]	= { gcombat_gtype = "7" }
		Ctype["Options"]["#Dumb rocket battery"]	= { gcombat_gtype = "8" }
		Ctype["Options"]["#Plasma cannon"]	= { gcombat_gtype = "9" }
		Ctype["Options"]["#Point defense"]	= { gcombat_gtype = "10" }
		Ctype["Options"]["#Beam dagger"]	= { gcombat_gtype = "11" }
		Ctype["Options"]["#Grenade cannon"]	= { gcombat_gtype = "12" }
		Ctype["Options"]["#Flame cannon"]	= { gcombat_gtype = "13" }
		Ctype["Options"]["#Swarmer launcher"]	= { gcombat_gtype = "14" }
		Ctype["Options"]["#Vulcan laser"]	= { gcombat_gtype = "15" }
		Ctype["Options"]["#SAM launcher"]	= { gcombat_gtype = "16" }
		Ctype["Options"]["#Mortar"]	= { gcombat_gtype = "17" }
		Ctype["Options"]["#Warning system"]	= { gcombat_gtype = "18" }
		Ctype["Options"]["#LRM launcher"]	= { gcombat_gtype = "19" }
		
		
		
	CPanel:AddControl("ComboBox", Ctype )
	
	

end
end

