------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

------------------------------------------
--  Configuration
------------------------------------------
--Set up the configuration of the mod here. Feel free to edit the values, but not the variables themselves. If you're unsure, just follow the comments.

Factions.FF					= false --enable friendly fire?

Factions.Config = { --ignore this

CopyShips				= true, --Copy the FAC default ADV Dup ships to the data folder? (if adv dup is installed)

DMGVar					= DMG_ALL, --How should players take damage? Other possibilites: DMG_GODMODE, DMG_PLYOFF, DMG_FFOFF, DMG_FFON

FragileProps				= false, --are props destructible?

AutoTBDefault				= true, --enable auto team balance by default?

MoneyReset				= true, --automatically reset a player's money if they don't return within:
MoneyTimeout				= 2880, --minutes

PlayerRespawnTime			= 15, --in seconds

DefaultMode				= "Free", --the default mode. Possible values: "Free", "War"

PlanetIncome				= 100, --amount of money recieved for owning planets (per planet)

ForceIronsights				= false, --force players to look through the ironsights of their gun?
AllowFACSWEPS				= true, --allow the purchasing of factions sweps for everyone?

AllowSpawnmenuSWEPS			= false, --allow the purchasing of regular sweps (for free)?
AllowAdminSWEPSpawn			= true, --allow only admins to spawn sweps via the spawnmenu (for free)? (if AllowSpawnmenuSWEPS is false)
AllowedSWEPS				= { "exampleSWEP" }, --list of spawnable sweps via the spawnmenu (for free) (if AllowSpawnmenuSWEPS is false) Use either the weapon printname or the classname. SWEPs added to this table will use their default usability settings.

LocalChatArea				= 300, --radius of how far local chat reaches

MaxDropGold				= 20, --maximum amounts dropped on player death
MaxDropChalc				= 20,
MaxDropMoney				= 500,

RockRegenMinimumRockValue	= 150, --When the amount of rocks drops below this number for humans or aliens, another rock will be spawned (rock regeneration)
--You can set this number to a negative number to disable rock regeneration. One stone_large is worth 80.
RockRegenRespawnWait		= 150, --How long to wait inbetween spawning rocks, in seconds.

RockMoneyTeam				= 25, --Amount of money recieved for mining your own team's rocks. For example, an alien mines a yellow rock, or a human mines a black rock
RockMoneyTrade				= 50, --Amount of money recieved for obtaining the other team's rock. For example, an alien obtains a black rock, or a human recieves a yellow rock
RockMoneyRed				= 100, --Amount of money recieved for mining a red rock.

RockRemovalTimer			= 300, --how long to wait to remove small rocks
MaxTeamSmallRocks     		= 30, --per team (only counts if it's on the planet)
MaxSmallRocks				= 100, --including space and all planets
LimitTheBigRocks			= false, -- enable/disable in-game using fac_limit_rocks 1/0
BigRockSpawnLimit			= 3, -- Max number of times the rocks will spawn (if fac_limit_rocks is set to 1)

EntityCosts = {
props			= 50,
vehicles		= 200,
ragdolls		= 50,
effects			= 50,
sents			= 100,
npcs			= 100,
sweps			= 200
},

TransformerSpawnCost		= 600,
HoverDriveCost				= 700,

ForceClientMusicDownload	= true, --should the server require clients to download server music (data/factions/musicdata.txt) ?

AutoSpawnNPCS				= false, --respawn hostile npcs on planets after every mode change?

--these are the different npc groups that can spawn on any given planet. feel free to add your own, assuming you can figure out how to
--you can find the names of the different weapons in: gamemodes/sandbox/gamemode/init.lua:  GM.PlayerLoadout

--editing this requires somewhat of a basic knowledge of lua
planetNPCS = {

[1] = {
	npcs = { npc_antlion = 8, npc_antlionguard = 1 } --the number represents how many of this unit to spawn
},

[2] = {
	npcs = { CombineElite = 1, CombinePrison = 2, npc_combine_s = 5, npc_manhack = 5 },
	weapons = { CombineElite = "weapon_rpg", CombinePrison = "weapon_ar2", npc_combine_s = "weapon_smg1" }
},

[3] = {
	npcs = { npc_fastzombie = 2, npc_poisonzombie = 4, npc_headcrab_fast = 5, npc_zombie = 2 }
}

},
--npcs you can use:
--[[
Rebel
npc_headcrab
npc_antlionguard
npc_zombie
npc_gman
npc_barney
npc_seagull
npc_antlion_grub
npc_crow
npc_zombine
npc_alyx
npc_kleiner
npc_vortigaunt
npc_antlion_worker
npc_metropolice
npc_fastzombie_torso
npc_combine_s
npc_zombie_torso
npc_pigeon
npc_dog
Medic
npc_rollermine
npc_turret_floor
npc_mossman
npc_citizen
npc_breen
npc_barnacle
npc_poisonzombie
npc_manhack
Refugee
npc_antlion
npc_cscanner
npc_eli
npc_headcrab_black
npc_fastzombie:
CombinePrison
npc_monk
npc_magnusson
npc_hunter
npc_headcrab_fast
CombineElite
--]]

	Weapons = {
		Equipment = {},
		Pistols = {},
		SMGs = {},
		Shotguns = {},
		Rifles = {},
		MachineGuns = {},
	}
}


Factions.Config.Weapons.Equipment.Physgun = {
	Name = "Physgun",
	ClassName = "weapon_physgun",
	Cost = 150,
	Model = "models/weapons/w_physics.mdl"
}

Factions.Config.Weapons.Equipment.Knife = {
	Name = "Knife",
	ClassName = "weapon_knife",
	Cost = 50,
	Model = "models/weapons/w_knife_t.mdl"
}

Factions.Config.Weapons.Equipment.Armor = {
	Name = "Kevlar Body Armor",
	ClassName = "ammo.armor",
	Cost = 100,
	Model = "models/items/battery.mdl"
}

Factions.Config.Weapons.Equipment.Health = {
	Name = "Health Pack",
	ClassName = "ammo.medpack",
	Cost = 100,
	Model = "models/healthvial.mdl"
}

Factions.Config.Weapons.Equipment.Grenade = {
	Name = "1 Grenade",
	ClassName = "ammo.grenade",
	Cost = 75,
	Model = "models/items/grenadeammo.mdl"
}

Factions.Config.Weapons.Pistols.Deagle = {
	Name = "Deagle",
	ClassName = "weapon_deagle",
	Cost = 250,
	AmmoCost = 40
}

Factions.Config.Weapons.Pistols.FiveSeven = {
	Name = "Five Seven",
	ClassName = "weapon_fiveseven",
	Cost = 200,
	AmmoCost = 40
}

Factions.Config.Weapons.Pistols.Glock = {
	Name = "Glock 18",
	ClassName = "weapon_glock",
	Cost = 150,
	AmmoCost = 40
}

Factions.Config.Weapons.Pistols.Ammo = {
	Name = "Pistol Ammo",
	ClassName = "ammo.pistol",
	Cost = 40
}

Factions.Config.Weapons.SMGs.Mac10 = {
	Name = "Mac 10",
	ClassName = "weapon_mac10",
	Cost = 300,
	AmmoCost = 50
}

Factions.Config.Weapons.SMGs.TMP = {
	Name = "TMP",
	ClassName = "weapon_tmp",
	Cost = 300,
	AmmoCost = 50
}

Factions.Config.Weapons.SMGs.MP5 = {
	Name = "MP5",
	ClassName = "weapon_mp5",
	Cost = 400
}

Factions.Config.Weapons.SMGs.Ammo = {
	Name = "SMG Ammo",
	ClassName = "ammo.smg",
	Cost = 50
}

Factions.Config.Weapons.Shotguns.Pump = {
	Name = "Pump-Action Shotgun",
	ClassName = "weapon_pumpshotgun",
	Cost = 300,
	AmmoCost = 25
}

Factions.Config.Weapons.Shotguns.Ammo = {
	Name = "Shotgun Ammo",
	ClassName = "ammo.buckshot",
	Cost = 25
}


Factions.Config.Weapons.Rifles.AK47 = {
	Name = "AK47",
	ClassName = "weapon_ak47",
	Cost = 450,
	AmmoCost = 100,
	AmmoType = "AR2"
}

Factions.Config.Weapons.Rifles.M4A1 = {
	Name = "M4A1",
	ClassName = "weapon_m4",
	Cost = 450,
	AmmoCost = 100,
	AmmoType = "AR2"
}

Factions.Config.Weapons.Rifles.Ammo = {
	Name = "Rifle Ammo",
	ClassName = "ammo.rifle",
	Cost = 100
}

Factions.Config.Weapons.MachineGuns.M249Para = {
	Name = "M249 Para",
	ClassName = "weapon_para",
	Cost = 600,
	AmmoCost = 150,
	AmmoType = "AlyxGun"
}

Factions.Config.Weapons.MachineGuns.Ammo = {
	Name = "Machine Gun Ammo",
	ClassName = "ammo.machinegun",
	Cost = 150
}
