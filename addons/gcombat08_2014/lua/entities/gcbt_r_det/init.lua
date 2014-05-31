
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "ambient/explosions/explode_1.wav" )
util.PrecacheSound( "ambient/explosions/explode_2.wav" )
util.PrecacheSound( "ambient/explosions/explode_3.wav" )
util.PrecacheSound( "ambient/explosions/explode_4.wav" )

function ENT:Initialize()   

	math.randomseed(CurTime())
	
	self.hasdamagecase = true
	
	self.expl = {}
	self.expl[0] = "ambient/explosions/explode_1.wav"
	self.expl[1] = "ambient/explosions/explode_2.wav"
	self.expl[2] = "ambient/explosions/explode_3.wav"
	self.expl[3] = "ambient/explosions/explode_4.wav"

	
	self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
	self.Entity:SetColor(Color(100,100,100,255))
	--self.Entity:EmitSound( self.enginesound , 500 , 250 )
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()  
		phys:ApplyForceCenter( self.Entity:GetUp() * 30000 )
	end 
	
end   

function ENT:OnTakeDamage( dmginfo )
	
	self.Entity:TakePhysicsDamage( dmginfo )
	
end

function ENT:gcbt_breakactions(damage, pierce)
--invulnerable
end

function ENT:BTFU()
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 500, 50)
		cbt_hcgexplode( self.Entity:GetPos(), 500, 100, 6)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect( "big_splosion", effectdata )
		
		self.Entity:EmitSound( self.expl[ math.random(0,3) ], 500, 100 )
		
		self.Entity:Remove()
end
 
 
