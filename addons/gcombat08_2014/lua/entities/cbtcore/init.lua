
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize() 
self.Entity:SetModel( "models/props_wasteland/light_spotlight01_lamp.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetColor(Color(255,255,255,255))
local phys = self.Entity:GetPhysicsObject()  	
if (phys:IsValid()) then  		
phys:Wake()  	
end 

self.Forward = {}
self.Aft = {}
self.Flank = {}
self.rcfctr = 0
self.healthmax = 0
self.health = 0

end

function ENT:GetArmor( entity )
	if entity.face == 0 then
	return self.armor_base_forward
	elseif entity.face == 1 then
	return self.armor_base_flank
	elseif entity.face == 2 then
	return self.armor_base_aft
	else return -1 end
end

function ENT:SetEnts( enttable )
	self.Forward = {}
	self.Aft = {}
	self.Flank = {}
	self.rcfctr = #enttable
	self.healthmax = 0
	self.health = 0
	
	for o,p in pairs(enttable) do
		p.cbt = {}
		p.cbt.core = self.Entity
		p.cbt.index = o
		p.cbt.health = math.Clamp( p:GetPhysicsObject():GetMass(), 1, 4000 )
		p.cbt.healthmax = p.cbt.health
		self.healthmax = self.healthmax + p.cbt.health
		
		
		
		local relpos = (p:GetPos() - self:GetPos()):GetNormalized()
		local reldot = relpos:DotProduct(self:GetForward())
		
		if (reldot > 0.5) then
			self.Forward[#self.Forward + 1] = p
			p.cbt.face = 0
		elseif (reldot < -0.5) then
			self.Aft[#self.Aft + 1] = p
			p.cbt.face = 2
		else
			self.Flank[#self.Flank + 1] = p
			p.cbt.face = 1
		end
		
	end
	self.health = self.healthmax
end

function ENT:Think()
	
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "cbtcore" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end
