
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
self.Entity:SetModel( "models/Roller.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
self.Entity:SetColor(Color(40,255,40,255))
local phys = self.Entity:GetPhysicsObject()  	
if (phys:IsValid()) then  		
phys:Wake()  	
end 
 
end   

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "tank_buster_noboom" )
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

function ENT:Touch( activator)

if (activator:IsPlayer()) then return end
if ( self.armed == true && self.ticking == false ) then

self.ticking = true
self.fuseleft = CurTime() + fuse
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
 
 
