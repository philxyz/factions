
// Variables that are used on both client and server

SWEP.Author			= ""
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Place a Gcombat sapper charge, then RUN"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= false

SWEP.ViewModel			= "models/weapons/v_Grenade.mdl"
SWEP.WorldModel			= "models/weapons/W_Grenade.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

local ShootSound = Sound( "Metal.SawbladeStick" )

/*---------------------------------------------------------
	Reload does nothing
---------------------------------------------------------*/
function SWEP:Reload()
end

/*---------------------------------------------------------
   Think does nothing
---------------------------------------------------------*/
function SWEP:Think()	
end


/*---------------------------------------------------------
	PrimaryAttack
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	local tr = self.Owner:GetEyeTrace()
	if ( tr.HitWorld or tr.Entity:IsNPC() or tr.Entity:IsPlayer() ) then return end
	
	if ( self.Owner:EyePos():Distance(tr.HitPos) > 64 ) then return end
	
	self:EmitSound( ShootSound )
	
	
	
	// The rest is only done on the server
	if (!SERVER) then return end
	
	
	
	// Make a manhack
	local ent = ents.Create( "fieldsapper" )
		ent:SetPos( tr.HitPos + self.Owner:GetAimVector() * -5 )
		ent:SetAngles( tr.HitNormal:Angle() + Vector(90, 0,0))
	ent:Spawn()
	ent:Activate()

	// Weld it to the object that we hit
	local weld = constraint.Weld( tr.Entity, ent, tr.PhysicsBone, 0, 0 )
	self.Owner:StripWeapon("gcbt_sapper")
	
	
	
end

/*---------------------------------------------------------
	SecondaryAttack
---------------------------------------------------------*/
function SWEP:SecondaryAttack()
end


/*---------------------------------------------------------
   Name: ShouldDropOnDie
   Desc: Should this weapon be dropped when its owner dies?
---------------------------------------------------------*/
function SWEP:ShouldDropOnDie()
	return true
end
