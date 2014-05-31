
 local matLight	 = Material( "white_outline" )
   
   local matLight2			= Material( "effects/yellowflare" )
   
   util.PrecacheSound( "weapons/explode3.wav" )
   util.PrecacheSound( "weapons/explode4.wav" )
   util.PrecacheSound( "weapons/explode5.wav" )
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	// This is how long the spawn effect  
 	// takes from start to finish. 
 	self.Time = 1
 	self.LifeTime = CurTime() + self.Time 
	
 	self.expl = {}
	self.expl[1] = "weapons/explode3.wav"
	self.expl[2] = "weapons/explode4.wav"
	self.expl[3] = "weapons/explode5.wav"
 	self.vOffset = data:GetOrigin()
	
 	self.Entity:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" ) 
 	self.Entity:SetPos( self.vOffset ) 
	sound.Play( self.expl[ math.random(1,3) ], self.vOffset, 160, 130 ) 	 
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
 	
	self.Entity:SetColor( Color(255, 255, 255, 100 * Fraction) )
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
	self.Entity:SetModelScale( Vector() * 100 * (1 - Fraction) )
	
 		// Draw our model with the Light material 
 		render.MaterialOverride( matLight ) 
 			self.Entity:DrawModel() 
 		render.MaterialOverride( 0 ) 
 
   render.SetMaterial( matLight2 )
	render.DrawQuadEasy(self.vOffset, VectorRand(), 2000 * (Fraction) , 2000 * (Fraction) , color_white )
	render.DrawQuadEasy( self.vOffset, VectorRand(), math.Rand(32, 500), math.Rand(32, 500), color_white )
	render.DrawSprite( self.vOffset, 2000 * (Fraction), 2000 * (Fraction), Color( 255, 150, 150, 255 ) )
   
 end  