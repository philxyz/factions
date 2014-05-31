
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

util.PrecacheSound( "weapons/rpg/rocket1.wav" )

function ENT:Initialize()   

math.randomseed(CurTime())
self.exploded = false
self.flightvector = self.Entity:GetUp() * 100
self.timeleft = CurTime() + 10

self.nexttarGet = CurTime()

self.Entity:SetModel( "models/props_interiors/Furniture_Lamp01a.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_NONE )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- CHEESECAKE!    >:3 

self.InitH = (self:GetPos()).z
	
 	self.Sound = CreateSound( self.Entity, Sound( "weapons/rpg/rocket1.wav" ) ) 
 	self.Sound:Play()
	
	self.target = self.Entity    

 self:Think()
 
end   

function ENT:OnRemove()
	self.Sound:Stop()
end

 function ENT:Think()
	
	if self.timeleft < CurTime() then
					self.exploded = true
					self.Entity:Remove()
					
	end

	local trace = {}
		trace.start = self.Entity:GetPos()
		trace.endpos = self.Entity:GetPos() + self.flightvector 
		trace.filter = self.Entity 
	local tr = util.TraceLine( trace )
	
	if (tr.Hit) then
		if ( self.exploded == false ) then
				util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 10, 30)
				if (tr.Entity:IsWorld() || tr.Entity:IsPlayer() || tr.Entity:IsNPC()) then
					local effectdata = EffectData()
					effectdata:SetOrigin(self.Entity:GetPos())
					effectdata:SetStart(self.Entity:GetPos())
					util.Effect( "Explosion", effectdata )
					self.exploded = true
					self.Entity:Remove()
					return true
					
				end
 
    
				local attack = cbt_dealhcghit( tr.Entity, 1000, 7, tr.HitPos , tr.HitPos)
				self.exploded = true
				self.Entity:Remove()
				
			end
		end
	
	local EIS = ents.FindInSphere(self:GetPos(), 10000)
	local distance = 10000
	
	if (!self.target:IsValid() || self.target == self.Entity || (self.target:GetPos()).z < self.InitH + 800 || self.nexttarGet < CurTime()) then 
	
	self.target = self.Entity
	local EIS = ents.FindInSphere(self:GetPos(), 10000)
	local distance = 10000
	
	if self.nexttarGet < CurTime() then 
		for _,t in pairs(EIS) do
			if (t:GetClass() == "prop_physics" || t:IsPlayer() || t:IsNPC()) then
				if (t:GetPos():Distance(self:GetPos()) < distance && self:GetUp():DotProduct((t:GetPos() - self:GetPos()):GetNormalized()) > 0.5) then
					if (t:GetPos()).z > self.InitH + 800 then
						self.target = t
						distance = t:GetPos():Distance(self:GetPos())
					end
				end
			end
		end
		
		self.nexttarGet = CurTime() + 1
	end
	 end
	if self.target != self.Entity then
		self.flightvector = self.flightvector + (self.target:GetPos() - self:GetPos()):GetNormalized() * 20
		self.flightvector = (self.flightvector + Vector(math.Rand(-10,10), math.Rand(-10,10), math.Rand(-10,10)) * 0.4 ) * 0.7
		self.flightvector = self.flightvector:GetNormalized() * 50
	end
	
	self.Entity:SetPos(self.Entity:GetPos() + self.flightvector)
	self.Entity:SetAngles(self.flightvector:Angle() + Angle(90,0,0))
	self.Entity:NextThink( CurTime() )
	return true
end
 
 
