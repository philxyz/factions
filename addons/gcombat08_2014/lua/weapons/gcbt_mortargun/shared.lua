
// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Blast things, goddammit."

SWEP.Base				= "weapon_base"
SWEP.HoldType			= "rpg"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.bombs = 4
SWEP.elevation = 0


/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

function SWEP:Think()
 self.elevation = self.Owner:GetAimVector():Angle().p
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/

/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	if CLIENT then return end
	local ply = self.Owner
	
	local trace = ply:GetEyeTrace()
	
	local bomb = ents.Create( "gcbt_mortar" )
	bomb:SetPos( ply:EyePos())
	bomb:SetOwner( ply )
	bomb:SetAngles( ply:GetAimVector():Angle() + Angle(90, 0, 0))
	bomb:Spawn()
	
	if trace.HitPos:Distance(ply:EyePos()) < 200 then
	ply:SetVelocity( ply:GetAimVector() * -1000 )
	end
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * 100, math.Rand(-0.1,0.1) *100, 0 ) )
	
	self:detract()
	
	self:SetNextPrimaryFire( CurTime() + 2 )
	return true
end

function SWEP:detract()
self.bombs = self.bombs - 1

if self.bombs == 0 then self.Owner:StripWeapon("gcbt_mortargun") end
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end

function SWEP:CustomAmmoDisplay()
self.AmmoDisplay = self.AmmoDisplay or {}


self.AmmoDisplay.Draw = true

	self.AmmoDisplay.PrimaryClip = self.bombs //Ammo, but it don't work
	self.AmmoDisplay.PrimaryAmmo = self.elevation //Elevation.

return self.AmmoDisplay 
end 


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end
