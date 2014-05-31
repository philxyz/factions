 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 
 local Laser = Material( "sprites/rollermine_shock" )
 local Ring = Material( "sprites/plasmaember" )
 
 function ENT:Draw()      

 self.Entity:DrawModel()
 if self:GetNetworkedBool( "hasport" ) then
 
 local inc = math.rad( 90 )
 
 local V1 = self:GetPos() + self:GetUp() * 18
 
 local V2_0 = self:GetPos() + self:GetForward() * 100 + self:GetUp() * 60
 
 local V2_1 = V2_0 + (self:GetRight() * math.cos( CurTime() ) * 60 ) + (self:GetUp() * math.sin( CurTime() ) * 60 )
 local V2_2 = V2_0 + (self:GetRight() * math.cos( CurTime() + inc ) * 60 ) + (self:GetUp() * math.sin( CurTime() + inc ) * 60 )
 local V2_3 = V2_0 + (self:GetRight() * math.cos( CurTime() + inc * 2 ) * 60 ) + (self:GetUp() * math.sin( CurTime() + inc * 2 ) * 60 )
 local V2_4 = V2_0 + (self:GetRight() * math.cos( CurTime() - inc ) * 60 ) + (self:GetUp() * math.sin( CurTime() - inc  ) * 60 )
 
	render.SetMaterial( Laser )
	render.DrawBeam( V1, V2_1, 5, 0, 0, Color( 255, 255, 255, 100 ) )
	render.DrawBeam( V1, V2_2, 5, 0, 0, Color( 255, 255, 255, 100 ) ) 
	render.DrawBeam( V1, V2_3, 5, 0, 0, Color( 255, 255, 255, 100 ) ) 
	render.DrawBeam( V1, V2_4, 5, 0, 0, Color( 255, 255, 255, 100 ) ) 
	
	render.SetMaterial( Ring )
	render.DrawQuadEasy( V2_0, self:GetForward(), 140, 140, Color( 255, 0, 0, 255 ))
	
	
	local emitter = ParticleEmitter( V2_0 )
	for i=0, (4) do
	local partdist = math.rad(math.Rand(0,360))
	local particle = emitter:Add( "sprites/plasmaember", V2_0 + (self:GetRight() * math.cos( partdist ) * 60 ) + (self:GetUp() * math.sin( partdist ) * 60 )  )
			if (particle) then
				particle:SetVelocity( Vector(0,0,0) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.2, 1 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 10 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				particle:SetColor( Color(255 , 100 , 100) )
			end
	end
end
 end 
 
 