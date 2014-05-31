
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')



function ENT:Initialize()   
	
	util.PrecacheSound("npc/scanner/scanner_siren2.wav")
	
	self.targeted = Sound("npc/scanner/scanner_siren2.wav")
	
	self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor(Color(255,255,255,255))

	self.Delay = CurTime()
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
	phys:Wake() 
	phys:SetMass( 3 ) 
	end 
	
	self:SetNetworkedBool("locked", false )
	
	self.TDlist = {
		"samissile",
		"swarmer",
		"lrm_shot"
		}
	
end   

function ENT:Think()
	self.Entity:NextThink( CurTime())
	if self.Delay > CurTime() then return true end
	self:SetNetworkedBool("locked", false )
	local target = self.Entity
	local targets = ents.FindInSphere(self.Entity:GetPos(), 10000)
	for _,t in pairs(targets) do
		if table.HasValue( self.TDlist, t:GetClass() ) then
				local tnormal = (t:GetPos() - self:GetPos()):GetNormalized()
				if t.flightvector then 
					if tnormal:DotProduct(t.flightvector:GetNormalized()) < -0.99 then
						target = t
						break
					end
				else
					if tnormal:DotProduct( t:GetVelocity():GetNormalized()) < -0.99 then
						target = t
						break
					end
				end
		end
	end
	
	if target == self.Entity then return true end
	self:EmitSound(self.targeted, 100, 100)
	self:SetNetworkedBool("locked", true )
	
	self.Delay = CurTime() + 7
	return true
end


 
 
