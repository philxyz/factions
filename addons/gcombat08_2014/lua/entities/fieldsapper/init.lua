
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

self.Entity:SetModel( "models/Items/grenadeAmmo.mdl" ) 	
self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox               
local phys = self.Entity:GetPhysicsObject()  	
if (phys:IsValid()) then  		
phys:Wake()  	
end 

self.Fusetime = CurTime() + 30

self.Hits = 6

end   

function ENT:Think()

	if self.Fusetime > CurTime() then
		local length = ((self.Fusetime - CurTime()) / 30) * 20
		self:SetNetworkedFloat("length", length)
	else
		local effectdata = EffectData()
			effectdata:SetOrigin( self.Entity:GetPos() )
		util.Effect( "sapper_explosion", effectdata )
		cbt_hcgexplode( self.Entity:GetPos() + self:GetUp() * 5, 75, 4000, 7)
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 400, 100)
		self.Entity:Remove()
	end
	
	self.Entity:NextThink(CurTime())
	return true
end

function ENT:OnTakeDamage()
	if self.Hits < 1 then
		constraint.RemoveConstraints( self.Entity, "Weld" )
	end
	self.Hits = self.Hits - 1
end
