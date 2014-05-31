
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

function ENT:Initialize()   

	self.hasdamagecase = true
	self.Entity:SetModel( "models/weapons/w_bugbait.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetColor(Color(100,100,100,255))
	
	
	self.die = 1
	self:SetNetworkedEntity( "lasorent", self.Entity )
	
end

function ENT:Think()
	if self.die < 1 then self:Remove(); return end
	if propent.canmakemore( self.sID ) then
		
		local trace = util.QuickTrace( self:GetPos() + self:GetUp() * 300, self:GetUp() * -900 + VectorRand() * 600, self.Entity)
		if trace.Hit then
			local ent = ents.Create( "gcbt_ionstorm" )
			ent:SetPos( trace.HitPos )
			ent:SetAngles( trace.HitNormal:Angle() + Vector(90, 0, 0):Angle())
			ent:Spawn()
			ent:Activate()
			ent:GetTable().sID = self.sID
			self:SetNetworkedEntity( "lasorent", ent )
			propent.addme( self.sID )
			
			cbt_nrgexplode( trace.HitPos, 300, 100, 5)
			
			self.die = self.die - 1
		end
	end
	if !propent.think( self.sID ) then self:Remove() end
	self:NextThink( CurTime() + 2)
	return true
end

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "gcbt_ionstorm" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	ent.sID = propent.new( 100, 10 )
	
	
	
	return ent

end

function ENT:gcbt_breakactions(damage, pierce)
--invulnerable
end
 
 
 
