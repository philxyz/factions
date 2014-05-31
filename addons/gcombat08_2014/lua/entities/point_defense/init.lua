
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

function ENT:Initialize()   
	
	
	self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(Color(100,40,255,255))

	self.Delay = CurTime()
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	phys:SetMass( 3 ) 
	end 
	
	self.TDlist = {
		"tankshell",
		"hetankshell",
		"nwerfer_rocket",
		"torpedo",
		"2pdr_shell",
		"tank_buster",
		"wander_rocket",
		"samissile",
		"swarmer",
		"lrm_shot",
		"gcbt_mortar",
		"gcbt_hvmortar"
	}
	
end   

function ENT:Think()
	self.Entity:NextThink( CurTime())
	if self.Delay > CurTime() then return true end
	local target = self.Entity
	local targets = ents.FindInSphere(self.Entity:GetPos(), 1000)
	for _,t in pairs(targets) do
		if table.HasValue( self.TDlist, t:GetClass() ) then
			if self.Entity:GetUp():DotProduct(self.Entity:GetPos() - t:GetPos()) < -0.4 then
				if t.flightvector then 
					if self.Entity:GetUp():DotProduct(t.flightvector:GetNormalized()) < -0.3 then
						target = t
						break
					end
				else
					if self.Entity:GetUp():DotProduct( t:GetVelocity():GetNormalized()) < -0.3 then
						target = t
						break
					end
				end
			end
		end
	end
	
	if target == self.Entity then return true end
	
	self:EmitSound( "npc/turret_floor/shoot" .. math.random(1,3) .. ".wav", 100, 100)
	
	local dice = math.Rand(0,30)
	if dice > 29 then
		local effectdata = EffectData()
			effectdata:SetOrigin(target:GetPos())
			effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "pd_ray", effectdata )
		
		local effectdata1 = EffectData()
			effectdata1:SetOrigin(target:GetPos())
		util.Effect( "gcombat_explosion", effectdata1 )
		
		target:Remove()
	else
		local effectdata = EffectData()
			effectdata:SetOrigin(target:GetPos() + VectorRand() * math.Rand(100,200) )
			effectdata:SetStart(self.Entity:GetPos())
		util.Effect( "pd_ray", effectdata )
	end
	self.Delay = CurTime() + 0.01
	return true
end


 
 
