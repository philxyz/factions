
// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Blast things, goddammit."

SWEP.Base				= "weapon_base"
SWEP.HoldType			= "ar2"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true
SWEP.ViewModelFlip	= true

SWEP.ViewModel			= "models/weapons/v_snip_r82.mdl"
SWEP.WorldModel			= "models/weapons/w_snip_r82.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Uber = 0
SWEP.damage = 0
SWEP.lastthink = CurTime()
SWEP.scopein = 0

local ShootSound = Sound( "Weapon_AWP.Single" )

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()
if !self.Owner then return end


  local tr = self.Owner:GetEyeTrace()
	local dist = tr.HitPos:Distance(self.Owner:EyePos())
self.damage = math.Clamp(100 - (dist / 100), 0, 100)

if (self.Owner:KeyPressed(IN_ATTACK) && SERVER && self.Uber > 0 && SERVER) then
	cbt_dealhcghit( tr.Entity, self.damage, self.Uber, tr.HitPos , tr.HitPos)
end

 if  self.scopein == 1 && !self.Owner:KeyPressed(IN_ATTACK) then
	if self.Uber < 12 && self.lastthink < CurTime() then self.Uber = self.Uber + 2; self.lastthink = CurTime() + 1 end
 else
	self.Uber = 0
	self.lastthink = CurTime() + 1
 end

 
 if self.Owner:KeyPressed(IN_ATTACK2) then
	self.Owner:SetFOV( 20, 0.15 )
	self.scopein = 1
	if CLIENT then return end
	self.Owner:DrawViewModel( false )
 end
 if self.Owner:KeyReleased(IN_ATTACK2) then
	self.Owner:SetFOV( 80, 0.15 )
	self.scopein = 0
	if CLIENT then return end
	self.Owner:DrawViewModel( true )
 end
 
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()
	
	local ply = self.Owner
	
	local bullet = {}
		bullet.Num 			= 1
		bullet.Src 			= ply:GetShootPos()
		bullet.Dir 			= ply:GetAimVector()
		bullet.Spread 		= Vector( 0, 0, 0 )
		bullet.Tracer		= 1
		bullet.TracerName 	= ""
		bullet.Force		= 1000
		bullet.Damage		= (self.damage / 7) * (self.Uber + 1)
		bullet.Attacker 	= ply
	self.Owner:FireBullets( bullet )

	self:EmitSound( ShootSound )
	
	self.Owner:ViewPunch( Angle( math.Rand(-0.2,-0.1) * 300, math.Rand(-0.1,0.1) * 300, 0 ) )
	
	// The rest is only done on the server
	if CLIENT then return end
	self:SetNextPrimaryFire( CurTime() + 1 )
	return true
end



/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end

function SWEP:CustomAmmoDisplay()
self.AmmoDisplay = self.AmmoDisplay or {}


self.AmmoDisplay.Draw = true

	self.AmmoDisplay.PrimaryClip = self.Uber //Piercing
	self.AmmoDisplay.PrimaryAmmo = self.damage //Damage

return self.AmmoDisplay 
end 


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return false
end
