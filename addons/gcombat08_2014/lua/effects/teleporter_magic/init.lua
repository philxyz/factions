
 local matLight	 = Material( "white_outline" )

 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	// This is how long the spawn effect  
 	// takes from start to finish. 
 	self.Time = 0.1
 	self.LifeTime = CurTime() + self.Time 
	
 	
 	self.vOffset = data:GetOrigin()
	 self.emitter = ParticleEmitter( self.vOffset )
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
   local NumParticles = 10	 
 	
 	 
 		for i=0, NumParticles do 
 		 
 			local particle = self.emitter:Add( "effects/spark", self.vOffset ) 
 			if (particle) then 
 				 
 				particle:SetVelocity( VectorRand() * math.Rand(0, 1400) ) 
 				 
 				particle:SetLifeTime( 0 ) 
 				particle:SetDieTime( math.Rand(0, 0.6) ) 
 				 
 				particle:SetStartAlpha( 255 ) 
 				particle:SetEndAlpha( 0 ) 
 				 
 				particle:SetStartSize( 30 ) 
 				particle:SetEndSize( 0 ) 
 				 
 				particle:SetRoll( math.Rand(0, 360) ) 
 				particle:SetRollDelta( math.Rand(-5, 5) ) 
 				 
 				particle:SetAirResistance( 400 ) 
 				 
 				particle:SetGravity( Vector( 0, 0, 100 ) ) 
 			 
 			end 
 			 
 		end 
 		 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
 function EFFECT:Render() 
 	 
 	// What fraction towards finishing are we at 
 	local Fraction = (self.LifeTime - CurTime()) / self.Time 
 	Fraction = math.Clamp( Fraction, 0, 1 ) 
 	
	self.Entity:SetColor( Color(255, 255, 255, 255 * Fraction) )
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
	
 
   
 end  