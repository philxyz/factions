------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

if ( CLIENT ) then

	SWEP.ViewModelFOV		= 72
	SWEP.ViewModelFlip		= false
	SWEP.CSMuzzleFlashes	= false
	
	killicon.AddFont( "weapon_knife", "CSKillIcons", "C", Color( 255, 80, 0, 255 ) )
	
	surface.CreateFont( "SWEPText", {
		font = "middages",
		size = 30,
		weight = 700,
		antialias = true,
		shadow = false
	}) -- Text for displaying of SWEPs

	SWEP.PrintName			= "Knife"			
	SWEP.Slot				= 1
	SWEP.SlotPos			= 2
	--SWEP.IconLetter			= "p"
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
else
	AddCSLuaFile ("shared.lua")
	
	SWEP.Weight = 5
	SWEP.AutoSwitchTo = true
	SWEP.AutoSwitchFrom = false 
end

SWEP.Spawnable			= true
SWEP.AdminSpawnable		= true

SWEP.Primary.Recoil			= 1.25
SWEP.Primary.Damage			= 15
SWEP.Primary.NumShots		= 1
SWEP.Primary.Cone			= 0.02
SWEP.Primary.Delay			= .5

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= true
SWEP.Primary.Ammo			= "none"

SWEP.Secondary.Recoil       = 1.5
SWEP.Secondary.Damage       = 55
SWEP.Secondary.NumShots     = 1
SWEP.Secondary.Cone         = 0.01
SWEP.Secondary.Delay		= 1.2

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= true
SWEP.Secondary.Ammo			= "none"

SWEP.ViewModel = "models/weapons/v_knife_t.mdl"
SWEP.WorldModel = "models/weapons/w_knife_t.mdl"

util.PrecacheSound("weapons/knife/knife_hitwall1.wav")
util.PrecacheSound("weapons/knife/knife_slash1.wav")
util.PrecacheSound("weapons/knife/knife_stab.wav")
util.PrecacheSound("weapons/knife/knife_deploy1.wav")
util.PrecacheSound("ambient/machines/slicer1.wav")
util.PrecacheSound("ambient/machines/slicer4.wav")
util.PrecacheSound("ambient/machines/slicer2.wav")

local rantime = nil

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	draw.SimpleText( "Ring-Ding", "SWEPText", x + wide/2, y + tall*0.1, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
	draw.SimpleText( "C", "SM_WeaponTitle", x + wide*.45, y + tall*.45, Color( 255, 210, 0, 255 ), TEXT_ALIGN_CENTER )
end

function SWEP:Deploy()
	self.Weapon:EmitSound("weapons/knife/knife_deploy1.wav")
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
end

function SWEP:Initialize()
    if (CLIENT) then return end
    self:SetWeaponHoldType("slam")
end 
 
function SWEP:Reload()
end
 
function SWEP:Think()
	if SERVER then return end
	if not rantime then
		rantime = CurTime() + math.random(10, 20)
	end
	if CurTime() >= rantime then
		if not self.Attacking and not self.Idling then
			self.Idling = true
			rantime = nil
			timer.Simple( 3, function() Reset("idle", self) end)
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		end
	end
end

function Reset( typ, me )
	if typ == "attacking" then
		me.Attacking = false
	elseif typ == "idle" then
		me.Idling = false
	end
end

AttkSnd = {
	"ambient/machines/slicer1.wav",
	"ambient/machines/slicer2.wav",
	"ambient/machines/slicer4.wav"}

function SWEP:PrimaryAttack()
	rantime = CurTime() + math.random(10, 20)
	self.Idling = false
	self.Attacking = true
	timer.Simple( self.Primary.Delay, function() Reset("attacking", self) end)
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Primary.Delay )
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Primary.Delay )

 	local trace = util.GetPlayerTrace(self.Owner)
 	local tr = util.TraceLine(trace)
	
	self.Owner:SetAnimation( PLAYER_ATTACK1 )

	if (trace.start - tr.HitPos):Length() > 70 then
		-- too far away
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		return
	end

	if tr.HitWorld then
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"))
		self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		self.Owner:ViewPunch(Angle( math.Rand(-3,3) * self.Primary.Recoil, math.Rand(-3,3) * self.Primary.Recoil, 0 ) )
	elseif tr.HitNonWorld and tr.MatType == MAT_GLASS then
		self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"))
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		return
		
	elseif tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
		self.Weapon:SendWeaponAnim( ACT_VM_HITCENTER )
		self.Owner:ViewPunch(Angle( math.Rand(-3,3) * self.Primary.Recoil, math.Rand(-3,3) * self.Primary.Recoil, 0 ) )
		util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		if tr.Entity:IsPlayer() then
			if SERVER then
				tr.Entity:TakeDamage(self.Primary.Damage + math.random(1,15),self.Owner)
			end
		else
			tr.Entity:SetHealth( tr.Entity:Health() - self.Primary.Damage - math.random(1,15) )
		end
		if tr.Entity:Health() <= 0 and tr.Entity:IsNPC() then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 10
			bullet.Damage = 25
			self.Owner:FireBullets( bullet )
		end
		self.Weapon:EmitSound(Sound(RandomSound(AttkSnd)))
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
		util.Effect("bodyshot", effectdata)
		self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
	else
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self.Weapon:SendWeaponAnim(ACT_VM_HITCENTER)
		if tr.Entity:GetClass() == "prop_ragdoll" then
			util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			self.Weapon:EmitSound(Sound(RandomSound(AttkSnd)))
			self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		else
			self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"))
			self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		end
		self.Owner:ViewPunch(Angle( math.Rand(-3,3) * self.Primary.Recoil, math.Rand(-3,3) * self.Primary.Recoil, 0 ) )
		local phys = tr.Entity:GetPhysicsObject() or ""
		if phys:IsValid() then
			phys:ApplyForceOffset( -1 * (tr.StartPos - tr.HitPos) * 100, tr.HitPos )
		end
	end
end

 function SWEP:SecondaryAttack()
	rantime = CurTime() + math.random(10, 20)
	self.Idling = false
	self.Attacking = true
	timer.Simple( self.Secondary.Delay, function() Reset("attacking", self) end)
	self.Weapon:SetNextSecondaryFire( CurTime() + self.Secondary.Delay )
	self.Weapon:SetNextPrimaryFire( CurTime() + self.Secondary.Delay )
 
	self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
	self.Owner:SetAnimation( PLAYER_ATTACK1 )
	
	local trace = util.GetPlayerTrace(self.Owner)
 	local tr = util.TraceLine(trace)

	if (trace.start - tr.HitPos):Length() > 70 then
		-- too far away
		self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		return
	end

	if tr.HitWorld then
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"))
		self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		self.Owner:ViewPunch(Angle( math.Rand(-3,3) * self.Primary.Recoil, math.Rand(-3,3) * self.Primary.Recoil, 0 ) )
	elseif tr.HitNonWorld and tr.MatType == MAT_GLASS then
		self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"))
		return
		
	elseif tr.Entity:IsPlayer() or tr.Entity:IsNPC() then
		self.Owner:ViewPunch(Angle( math.Rand(-3,3) * self.Primary.Recoil, math.Rand(-3,3) * self.Primary.Recoil, 0 ) )
		util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		if tr.Entity:IsPlayer() then
			if SERVER then
				tr.Entity:TakeDamage(self.Secondary.Damage + math.random(1,15),self.Owner)
			end
		else
			tr.Entity:SetHealth( tr.Entity:Health() - self.Secondary.Damage - math.random(1,15) )
		end
		if tr.Entity:Health() <= 0 and tr.Entity:IsNPC() then
			bullet = {}
			bullet.Num    = 1
			bullet.Src    = self.Owner:GetShootPos()
			bullet.Dir    = self.Owner:GetAimVector()
			bullet.Spread = Vector(0, 0, 0)
			bullet.Tracer = 0
			bullet.Force  = 10
			bullet.Damage = 25
			self.Owner:FireBullets( bullet )
		end
		self.Weapon:EmitSound(Sound(RandomSound(AttkSnd)))
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetNormal(tr.HitNormal)
		util.Effect("bodyshot", effectdata)
		self.Weapon:EmitSound(Sound("weapons/knife/knife_stab.wav"))
	else
		util.Decal("ManhackCut", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
		if tr.Entity:GetClass() == "prop_ragdoll" then
			util.Decal("Blood", tr.HitPos + tr.HitNormal, tr.HitPos - tr.HitNormal)
			self.Weapon:EmitSound(Sound("weapons/knife/knife_stab.wav"))
			self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		else
			self.Weapon:EmitSound(Sound("weapons/knife/knife_hitwall1.wav"))
			self.Weapon:EmitSound(Sound("weapons/knife/knife_slash1.wav"))
		end
		self.Owner:ViewPunch(Angle( math.Rand(-3,3) * self.Primary.Recoil, math.Rand(-3,3) * self.Primary.Recoil, 0 ) )
		local phys = tr.Entity:GetPhysicsObject() or ""
		if phys:IsValid() then
			phys:ApplyForceOffset( -1 * (tr.StartPos - tr.HitPos) * 100, tr.HitPos )
		end
	end
 end
 
 function RandomSound(tablename)
	local tnum = table.getn(tablename)
	local rand = math.random(1,tnum)
	util.PrecacheSound(tablename[rand])

	return tablename[rand]
end 
