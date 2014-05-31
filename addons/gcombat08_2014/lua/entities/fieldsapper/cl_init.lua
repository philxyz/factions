 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]] 
 
 local ropemat = Material("cable/rope")
 
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering.        
 self.Entity:DrawModel()       // Draw the model.  

 local length = self:GetNetworkedFloat("length", 20)
 local pos = self:GetPos() + self:GetUp() * 5
 render.SetMaterial( ropemat )
	
	render.DrawBeam( pos, 		
					 pos + self:GetUp() * length,
					 1,					
					 0,					
					 length / 10,				
					 Color( 255, 255, 255, 255 ) )
 
 end  
 
  function ENT:Initialize()
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
 function ENT:Think()
 
 local length = self:GetNetworkedFloat("length", 20)
	local pos = self:GetPos() + self:GetUp() * 5
	
	local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos + (self:GetUp() * length))
			if (particle) then
				particle:SetVelocity((self:GetUp() * 100 + VectorRand() * 30) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.2 )
				particle:SetStartAlpha( 255 )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 4 )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-10, 10) )
				particle:SetColor( 255 , 255 , 255 ) 
			end
 end
 
 