 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering.        
 self.Entity:DrawModel()       // Draw the model.   
 
 end  
 
 function ENT:Initialize()
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
 function ENT:Think()
	pos = self:GetPos()
		
			local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos + VectorRand() * math.Rand(0, 100 ))
			if (particle) then
				particle:SetVelocity( VectorRand() * math.Rand(30, 300) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 0.2, 1 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 100 )
				particle:SetEndSize( 10 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-2, 2) )
				particle:SetColor(Color( 255 , 255 , 255 ))
				particle:SetAirResistance( 300 )
				particle:SetGravity( Vector( 0, 0, 200 ) ) 
			end
 end
 