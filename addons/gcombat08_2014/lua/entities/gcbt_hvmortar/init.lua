
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



util.PrecacheSound( "weapons/rpg/rocketfire1.wav" )


function ENT:Initialize()   

	math.randomseed(CurTime())

	self.exploded = false
	self.Entity:SetModel( "models/props_combine/breenglobe.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
	self.Entity:SetColor(Color(100,100,100,255))
	self.Entity:Ignite( 120, 40 )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableDrag(false)
	end 
	
end   

function ENT:OnTakeDamage( dmginfo )
	
	self.Entity:TakePhysicsDamage( dmginfo )
	
end

function ENT:PhysicsCollide()
	if ( self.exploded == false) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 300, 300)
		cbt_hcgexplode( self.Entity:GetPos(), 300, 800, 6)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect( "artillery_exp", effectdata )
		
		self.exploded = true
	end
end

function ENT:Think()
if self.exploded == true then self:Remove() end
self:NextThink( CurTime() )
return true
end
 
