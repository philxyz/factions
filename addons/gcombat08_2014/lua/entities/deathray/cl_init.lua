 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 
 local Laser = Material( "sprites/rollermine_shock" )
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering. 
 
 
 
 self.Entity:DrawModel()       // Draw the model.  
Wire_Render(self.Entity) 
render.SetMaterial( Laser )
if self:GetNetworkedBool("canfire", false) then
	
	local pos = self:GetPos()
	
	 
	
	local dirmins = (self:GetPos() + self:GetUp() * 60) - self:GetPos()
	
	render.StartBeam( 4 )
	render.AddBeam( pos , 0, 0, Color( 255, 255, 255, 255 ) )
	for i=2, (3) do
		local curpos = pos + (i/5) * dirmins + VectorRand() * 20
		render.AddBeam( curpos , 20, CurTime() + i/5, Color( 255, 255, 255, 255 ) )
	end
	
	render.AddBeam( (self:GetPos() + self:GetUp() * 60) , 20, 1, Color( 255, 255, 255, 255 ) )
	render.EndBeam()
else
		
		local emitter = ParticleEmitter( self:GetPos() )
		for i=0, (4) do
		local distro = VectorRand():GetNormalized() * 30
		local particle = emitter:Add( "sprites/plasmaember", self:GetPos() + self:GetUp() * math.Rand( 0, 60 ) + distro )
				if (particle) then
					particle:SetVelocity( distro * -10 )
					particle:SetLifeTime( 0 )
					particle:SetDieTime( 0.1 )
					particle:SetStartAlpha( math.Rand( 100, 200 ) )
					particle:SetEndAlpha( 0 )
					particle:SetStartSize( 2 )
					particle:SetEndSize( 0 )
					particle:SetRoll( math.Rand(0, 360) )
					particle:SetRollDelta( math.Rand(-2, 2) )
					particle:SetColor(Color( 255 , 100 , 100 ))
				end
	end
	
end
 end  
 
 function ENT:Think()
	if (CurTime() >= (self.NextRBUpdate or 0)) then
	    self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self.Entity)
	end
end

