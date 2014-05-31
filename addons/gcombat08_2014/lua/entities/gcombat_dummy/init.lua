
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

 
function ENT:PhysicsCollide( data , ent )
	local cent = data.HitEntity
	local temp = cbt.temperature
	if temp != 200 then
		gcombat.applyheat(cent, (temp - 200) / 20)
		if temp > 500 then
			gcombat.hcghit( cent, 100, 5, data.HitPos, data.HitPos)
			if temp > 800 then
				constraint.Ballsocket( self.Entity, cent, 0, 0, data.HitPos, 2000, 0, 0 )
			end
		end
	end
end
