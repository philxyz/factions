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
	self.timestamp = CurTime() + 0.1
	pos = self:GetPos()
	self.emitter = ParticleEmitter( pos )
 end
 
  function ENT:Think()
	local isrocket = self:GetNetworkedBool( "rocket", true )
	
	if isrocket then
		pos = self:GetPos()
		for i=0, (8) do
			local particle = self.emitter:Add( "particles/flamelet"..math.random(1,5), pos + (self:GetUp() * -30 * i))
			if (particle) then
				particle:SetVelocity((self:GetUp() * -30) )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( 0.2 )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 60 - 6 * i )
				particle:SetEndSize( 0 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-10, 10) )
				particle:SetColor( Color(255 , 255 , 255) ) 
			end
		end
	else
		if self.timestamp > CurTime() then return end
		pos = self:GetPos()
			local particle = self.emitter:Add( "particles/smokey", pos + VectorRand() * math.Rand(1, 20 ))
			
			if (particle) then
				particle:SetVelocity( self:GetUp() * math.Rand(50, 100) * -1 )
				particle:SetLifeTime( 0 )
				particle:SetDieTime( math.Rand( 2, 8 ) )
				particle:SetStartAlpha( math.Rand( 200, 255 ) )
				particle:SetEndAlpha( 0 )
				particle:SetStartSize( 30 )
				particle:SetEndSize( 400 )
				particle:SetRoll( math.Rand(0, 360) )
				particle:SetRollDelta( math.Rand(-0.2, 0.2) )
				particle:SetColor( Color(255 , 255 , 255) ) 
			end
		self.timestamp = CurTime() + 0.1
	end
end
 