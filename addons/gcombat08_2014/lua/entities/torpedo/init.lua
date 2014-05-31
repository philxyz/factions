
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


util.PrecacheSound( "weapons/rpg/rocket1.wav" )
util.PrecacheSound( "weapons/rpg/rocketfire1.wav" )


function ENT:Initialize()   

	math.randomseed(CurTime())
	
	self.firesound = "weapons/rpg/rocketfire1.wav"
	self.enginesound = "weapons/rpg/rocket1.wav"
	
	self.hasdamagecase = true
	
	self.model = "models/Roller.mdl"
	self.exploded = false
	self.armed = true
	self.ticking = true
	self.smoking = false
	self.fuseleft = CurTime()+10
	self.Entity:SetModel( "models/props_c17/canister01a.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
	self.Entity:SetColor(Color(100,100,255,255))
	
	if self:GetUp():DotProduct(Vector(0,0,1)) > 0 then
		self.initang = (Vector(self:GetUp().x, self:GetUp().y, 0)):Angle() + Angle(90, 0, 0)
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:Wake()  
			phys:ApplyForceCenter( self.Entity:GetUp() * 30000 )
			phys:SetBuoyancyRatio( 1.5 )
		end 
	else
		self.initang = self:GetAngles()
		local phys = self.Entity:GetPhysicsObject()  	
		if (phys:IsValid()) then  		
			phys:Wake()  
			phys:ApplyForceCenter( self.Entity:GetUp() * 30000 )
			phys:SetBuoyancyRatio( 1 )
		end 
	end
	--self.Entity:EmitSound( self.enginesound , 500 , 250 )
	self.Entity:EmitSound( self.firesound , 500 , 100 )
	
	self:StartMotionController()
end   

function ENT:gcbt_breakactions(damage, pierce)
--invulnerable
end

function ENT:OnTakeDamage( dmginfo )
	
	self.Entity:TakePhysicsDamage( dmginfo )
	
end

function ENT:SpawnFunction( ply, tr)

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	
	local ent = ents.Create( "torpedo" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent

end

function ENT:PhysicsCollide()
	if ( self.exploded == false && self.Entity:WaterLevel() > 0 && self.fuseleft - 9 < CurTime()) then
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 500, 50)
		cbt_hcgexplode( self.Entity:GetPos(), 400, 800, 7)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(self.Entity:GetPos())
		util.Effect( "Explosion", effectdata )
		
		self.exploded = true
		
	end
end

   function ENT:PhysicsSimulate( phys, deltatime )
      
      phys:Wake()
      if ( self.Entity:WaterLevel() > 0 ) then
      self.ShadowParams={}
	  self.ShadowParams.secondstoarrive = 0.1
      self.ShadowParams.pos = self:GetPos() + self:GetUp() * 300
      self.ShadowParams.angle = self.initang
      self.ShadowParams.maxangular = 5
     self.ShadowParams.maxangulardamp = 4
     self.ShadowParams.maxspeed = 5
     self.ShadowParams.maxspeeddamp = 2
     self.ShadowParams.dampfactor = 0.8
     self.ShadowParams.teleportdistance = 0
     self.ShadowParams.deltatime = deltatime
     
     phys:ComputeShadowControl(self.ShadowParams)
     end
    end 

 function ENT:Think()
if self.exploded == true then self:Remove() end
 end
 
 
