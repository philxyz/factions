
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "weapons/rpg/rocket1.wav" )

function ENT:Initialize()   

math.randomseed(CurTime())
self.exploded = false
self.flightvector = self.Entity:GetUp() * 100
self.timeleft = CurTime() + 4
self.Entity:SetModel( "models/Items/grenadeAmmo.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3 

	
 	self.Sound = CreateSound( self.Entity, Sound( "weapons/rpg/rocket1.wav" ) ) 
 	self.Sound:Play()


util.SpriteTrail( self.Entity,  //Entity 
 											0,  //iAttachmentID 
 											Color(255,255,255,255),  //Color 
 											false, // bAdditive 
 											10, //fStartWidth 
 											0, //fEndWidth 
 											1, //fLifetime 
 											1, //fTextureRes 
 											"trails/smoke.vmt" ) //strTexture          

 self:Think()
 
end   

function ENT:OnRemove()
	self.Sound:Stop()
end

 function ENT:Think()
	
	if self.timeleft < CurTime() then
		brokedshell = ents.Create("prop_physics")
					brokedshell:SetPos(self.Entity:GetPos())
					brokedshell:SetAngles(self.Entity:GetAngles())
					brokedshell:SetKeyValue( "model", "models/Items/grenadeAmmo.mdl" )
					brokedshell:PhysicsInit( SOLID_VPHYSICS )
					brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
					brokedshell:SetSolid( SOLID_VPHYSICS )
					brokedshell:Activate()
					brokedshell:Spawn()
					brokedshell:Fire("Kill", "", 20)
					local phys = brokedshell:GetPhysicsObject()  	
					if (phys:IsValid()) then  
						phys:SetVelocity(self.flightvector * 10000)
					end
					self.exploded = true
					self.Entity:Remove()
					
	end

	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector *2
		trace.filter = self.Entity 
	local tr = util.TraceLine( trace )
	
	if (tr.Hit) then
		if ( self.exploded == false ) then
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 100, 50)
				if (tr.Entity:IsWorld() || tr.Entity:IsPlayer() || tr.Entity:IsNPC()) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())
					effectdata:SetStart(self.Entity:GetPos())
					util.Effect( "Explosion", effectdata )
					self.exploded = true
					self.Entity:Remove()
					return true
					
				end
 
    
				local attack = cbt_dealhcghit( tr.Entity, 200, 7, tr.HitPos , tr.HitPos)
				if (attack == 0) then
					brokedshell = ents.Create("prop_physics")
					brokedshell:SetPos(self.Entity:GetPos())
					brokedshell:SetAngles(self.Entity:GetAngles())
					brokedshell:SetKeyValue( "model", "models/Items/grenadeAmmo.mdl" )
					brokedshell:PhysicsInit( SOLID_VPHYSICS )
					brokedshell:SetMoveType( MOVETYPE_VPHYSICS )
					brokedshell:SetSolid( SOLID_VPHYSICS )
					brokedshell:Activate()
					brokedshell:Spawn()
					brokedshell:Fire("Kill", "", 20)
					local phys = brokedshell:GetPhysicsObject()  	
					if (phys:IsValid()) then  
						phys:SetVelocity(self.flightvector * 10000)
					end
				end

 

				self.exploded = true
				self.Entity:Remove()
				
			end
		end

	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.flightvector = self.flightvector + Vector(math.Rand(-4,4), math.Rand(-4,4), math.Rand(-4,4))
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
