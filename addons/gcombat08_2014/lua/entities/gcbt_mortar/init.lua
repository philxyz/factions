
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')



util.PrecacheSound( "weapons/rpg/rocketfire1.wav" )


function ENT:Initialize()   

	math.randomseed(CurTime())

	self.firesound = "weapons/rpg/rocketfire1.wav"

	self.exploded = false
	self.Entity:SetModel( "models/Gibs/HGIBS.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
	self.Entity:SetColor(Color(100,100,100,255))
	self.Entity:Ignite( 120, 40 )
	
	self.dietime = CurTime() + 10
	
	self.Entity:EmitSound( self.firesound , 500 , 100 )
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()  
		phys:ApplyForceCenter( self.Entity:GetUp() * 30000 )
	end 
	
end   

function ENT:OnTakeDamage( dmginfo )
	
	self.Entity:TakePhysicsDamage( dmginfo )
	
end

function ENT:PhysicsCollide()
	if ( self.exploded == false) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 200)
		cbt_hcgexplode( self.Entity:GetPos(), 75, 300, 6)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect( "gcombat_explosion", effectdata )
		
		self.exploded = true
	end
end

function ENT:Think()

if ( self.dietime < CurTime() ) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 200)
		cbt_hcgexplode( self.Entity:GetPos(), 75, 300, 6)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect( "gcombat_explosion", effectdata )
		
		self.exploded = true
	end

if self.exploded == true then self:Remove() end
self:NextThink( CurTime() )
return true
end
 
