
 local matLight	 = Material( "white_outline" )
   
   local matLight2			= Material( "effects/yellowflare" )
   
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	// This is how long the spawn effect  
 	// takes from start to finish. 
 	self.Time = 0.2
 	self.LifeTime = CurTime() + self.Time 
	
 	self.vOffset = data:GetOrigin()
	
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
 function EFFECT:Render() 
 	 
 	// What fraction towards finishing are we at 
 	local Fraction = (self.LifeTime - CurTime()) / self.Time 
 	Fraction = math.Clamp( Fraction, 0, 1 ) 
 	
	
 		// Draw our model with the Light material 

 
   render.SetMaterial( matLight2 )
	render.DrawSprite( self.vOffset, 100, 100 , Color( 255, 150, 150, 255 * Fraction ) )
   
 end  