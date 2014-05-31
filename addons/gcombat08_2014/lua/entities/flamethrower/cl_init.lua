 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 
 local matFire			= Material( "effects/fire_cloud1" ) 
 local matHeatWave		= Material( "sprites/heatwave" )
 
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering. 
 
 self.Entity:DrawModel()       // Draw the model.  
Wire_Render(self.Entity) 
if !self:GetNetworkedBool("fire") then return end
	self:EffectDraw_fire()
 end 
 
 function ENT:DrawTranslucent()
	
 end
 
 function ENT:EffectDraw_fire() --adapted from the garry thruster. Helps blend the fire effect near the barrel.
	
	
	
 	local vOffset = self:GetPos() + self:GetUp()* 50 
 	local vNormal = self:GetUp()
   
 	local scroll =  (CurTime() * -10) 
 	 
 	local Scale = 2
 		 
 	render.SetMaterial( matFire ) 
 	 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255, 255, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 	scroll = scroll * 0.5 
 	 
 	render.UpdateRefractTexture() 
 	render.SetMaterial( matHeatWave ) 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, Color( 255, 255, 255, 255) ) 
 		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0) ) 
 	render.EndBeam() 
 	 
 	 
 	scroll = scroll * 1.3 
 	render.SetMaterial( matFire ) 
 	render.StartBeam( 3 ) 
 		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) ) 
 		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) ) 
 	render.EndBeam() 
 	 
 end 
 
  function ENT:Initialize()
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
 function ENT:Think()
	if (CurTime() >= (self.NextRBUpdate or 0)) then
	    self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self.Entity)
	end
	
	if !self:GetNetworkedBool("fire") then return end
	
	local trace = {}
		trace.start = self.Entity:GetPos() + self.Entity:GetUp() * 50
		trace.endpos = self.Entity:GetPos() + self.Entity:GetUp() * 2000
		trace.filter = self.Entity 
		local tr = util.TraceLine( trace ) 
	
	pos = self:GetPos()
		
			local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos + self:GetUp() * 50)
			if (particle) then
				particle:SetVelocity((self:GetUp() * 10) * 250 * tr.Fraction )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 3 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 10 )
				particle:SetEndSize( 300 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				particle:SetColor(Color( 255 , 255 , 255 ))
				particle:SetAirResistance( 50 )
				
				particle:SetCollide( true ) 
 				particle:SetBounce( 0.3 ) 
			end
	
end
