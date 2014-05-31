
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local fuse = 10
local blrad = 100
local blpow = 100
local stickradius = 100

function ENT:Initialize()   

math.randomseed(CurTime())
self.model = "models/Roller.mdl"
self.exploded = false
self.armed = false
self.ticking = false
self.fuseleft = 0
self.target = nil
self.Entity:SetModel( "models/Roller.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetColor(Color(40,40,40,255))
local phys = self.Entity:GetPhysicsObject()  	
if (phys:IsValid()) then  		
phys:Wake()  	
end 
--the following code is property of studentloon!
self.light = ents.Create("npc_bullseye")
self.light:SetPos(self.Entity:GetPos())
self.light:Spawn()
self.light:SetKeyValue("health","10000")
self.light:SetSolid( SOLID_NONE)
self.light:SetParent(self.Entity)
--end studentloon's stuff.
end   

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "tank_buster" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:Use( activator, caller)

if ( activator:IsPlayer() && self.armed == false && self.ticking == false ) then
self.Entity:SetModel( "models/Roller_Spikes.mdl" ) 
self.armed = true
end

end

function gravpik( userid, target )

if (target.armed == false && target.ticking == false ) then
target.Entity:SetModel( "models/Roller_Spikes.mdl" ) 
target.armed = true
end

end
local hook = hook.Add("GravGunOnPickedUp", "gpulol", gravpik)

function ENT:Touch( activator)
if ( self.armed == true && self.ticking == false ) then

self.ticking = true
self.fuseleft = CurTime() + fuse
self.target = activator
local targets = ents.FindInSphere( self.Entity:GetPos(), 512)

for _,i in pairs(targets) do
if (i:IsNPC()) then
i:AddEntityRelationship(self.light, 1, 99 )
end
end


local pylon_to_be_buffed = constraint.Weld(self.Entity, activator, 0, 0, 0)

for var=0, 10, 1 do 

 local pos = self.Entity:GetPos()
 local trace = {}
 trace.start = self.Entity:GetPos()
 trace.endpos = Vector((pos.x + math.random(-400,400)),(pos.y + math.random(-400,400)),(pos.z + math.random(-400,400)))
 trace.filter = self.Entity 
 local tr = util.TraceLine( trace ) 
 
 if (tr.Hit && !tr.Entity:IsPlayer() && !tr.Entity:IsNPC()) then
 
 local threadvector = Vector(0,0,1)
 
 local stickythread = constraint.Elastic( tr.Entity, self.Entity, 0, 0, tr.HitPos - tr.Entity:GetPos(), threadvector, 600, 0, 0, "cable/physbeam", 20, 1)

 end
 end
 
end
 end
 
 function ENT:Think()
 
 if ( self.exploded == false && self.ticking == true && self.fuseleft < CurTime()) then


local attack = cbt_dealnrghit( self.target, 100, 6, self.Entity:GetPos(), self.Entity:GetPos())


local cooker = ents.Create("point_hurt")
cooker:SetPos(self.Entity:GetPos())
cooker:SetKeyValue("TargetName", "Tank Bomb")
cooker:SetKeyValue("DamageRadius", 500)
cooker:SetKeyValue("Damage", 20)
cooker:SetKeyValue("DamageDelay", 0.1)
cooker:SetKeyValue("DamageType", 262144)
cooker:Spawn()
cooker:Fire("turnon","",0)
cooker:Fire("kill","", 1.5)

cbt_emitheat( self.Entity:GetPos(), 500, 500, self.Entity)

local bang = ents.Create("prop_combine_ball")
bang:SetPos(self.Entity:GetPos())
bang:Spawn()
bang:Fire("explode","",0)
bang:Fire("kill","", 0)

local effectdata = EffectData()
effectdata:SetOrigin(self.Entity:GetPos())
effectdata:SetStart(self.Entity:GetPos())
effectdata:SetScale( 10 )
effectdata:SetRadius( 100 )
util.Effect( "cball_explode", effectdata )
self.exploded = true
self.Entity:Remove()
 end
 
 end
 
 
