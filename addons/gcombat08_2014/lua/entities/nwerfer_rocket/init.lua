
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


util.PrecacheSound( "weapons/rpg/rocket1.wav" )
util.PrecacheSound( "weapons/rpg/rocketfire1.wav" )
util.PrecacheSound( "ambient/explosions/explode_1.wav" )
util.PrecacheSound( "ambient/explosions/explode_2.wav" )
util.PrecacheSound( "ambient/explosions/explode_3.wav" )
util.PrecacheSound( "ambient/explosions/explode_4.wav" )

function ENT:Initialize()   

	math.randomseed(CurTime())
	
	self.expl = {}
	self.expl[0] = "ambient/explosions/explode_1.wav"
	self.expl[1] = "ambient/explosions/explode_2.wav"
	self.expl[2] = "ambient/explosions/explode_3.wav"
	self.expl[3] = "ambient/explosions/explode_4.wav"
	self.firesound = "weapons/rpg/rocketfire1.wav"
	self.enginesound = "weapons/rpg/rocket1.wav"

	self.exploded = false
	self.armed = true
	self.smoking = false
	self.fuseleft = CurTime()+1
	self.Entity:SetModel( "models/props_c17/canister01a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
	self.Entity:SetColor(Color(100,100,100,255))
	--self.Entity:EmitSound( self.enginesound , 500 , 250 )
	self.Entity:EmitSound( self.firesound , 500 , 100 )
	
	self:SetNetworkedBool( "rocket", true )
	
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake()  
		phys:ApplyForceCenter( self.Entity:GetUp() * 30000 )
	end 
	
end   

function ENT:OnTakeDamage( dmginfo )
	
	self.Entity:TakePhysicsDamage( dmginfo )
	
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "nwerfer_rocket" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:PhysicsCollide()
	if ( self.exploded == false && self.fuseleft < CurTime()) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 500, 50)
		cbt_hcgexplode( self.Entity:GetPos(), 500, 100, 2)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect( "big_splosion", effectdata )
		
		self.Entity:EmitSound( self.expl[ math.random(0,3) ], 500, 100 )
		
		self.exploded = true
	end
end

 function ENT:Think()

 
	if (self.fuseleft > CurTime()) then
		
		local physx = self.Entity:GetPhysicsObject()  	
		if (physx:IsValid()) then  		
			physx:ApplyForceCenter( self.Entity:GetUp() * 30000)  	
		end 
		self.Entity:NextThink( CurTime() )
		return true
	else
		self:SetNetworkedBool( "rocket", false )
		if self.exploded == true then self:Remove() end
	end
 
 end
 
 
