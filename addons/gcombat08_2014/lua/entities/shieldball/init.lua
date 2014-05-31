
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize() 
self.Entity:SetModel( "models/Roller.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
self.Entity:SetSolid( SOLID_VPHYSICS )
self.Entity:SetColor(Color(255,255,255,255))
local phys = self.Entity:GetPhysicsObject()  	
if (phys:IsValid()) then  		
phys:Wake()  	
end 

field.register( self.Entity, "Shield", 4, 1000)

end

function ENT:Field( field )
	return 1
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "shieldball" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end
