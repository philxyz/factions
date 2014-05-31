
 local matLight	 = Material( "white_outline" )
   
 /*--------------------------------------------------------- 
    Initializes the effect. The data is a table of data  
    which was passed from the server. 
 ---------------------------------------------------------*/ 
 function EFFECT:Init( data ) 
 	 
 	// This is how long the spawn effect  
 	// takes from start to finish. 
 	self.Time = 0.5
 	self.LifeTime = CurTime() + self.Time 
 	 
 	local ent = data:GetEntity() 
 	if ( ent == NULL ) then return end 
 	 
 	self.ParentEntity = ent 
 	self.Entity:SetModel( ent:GetModel() ) 
 	self.Entity:SetPos( ent:GetPos() ) 
 	self.Entity:SetAngles( ent:GetAngles() ) 
 	self.Entity:SetParent( ent ) 
 	 
 end 
   
   
 /*--------------------------------------------------------- 
    THINK 
    Returning false makes the entity die 
 ---------------------------------------------------------*/ 
 function EFFECT:Think( ) 
   
 	if (!self.ParentEntity || !self.ParentEntity:IsValid()) then return false end 
   
 	return ( self.LifeTime > CurTime() )  
 	 
 end 
   
   
   
 /*--------------------------------------------------------- 
    Draw the effect 
 ---------------------------------------------------------*/ 
 function EFFECT:Render() 
 	 
 	// What fraction towards finishing are we at 
 	local Fraction = (self.LifeTime - CurTime()) / self.Time 
 	Fraction = math.Clamp( Fraction, 0, 1 ) 
 	 
 	// Change our model's alpha so the texture will fade out 
 	self.Entity:SetColor( Color(255, 255, 255, Fraction * 255) )
 	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
 	 
 	// Place the camera a tiny bit closer to the entity. 
 	// It will draw a big bigger and we will skip any z buffer problems 
 	local EyeNormal = self.Entity:GetPos() - EyePos() 
 	local Distance = EyeNormal:Length() 
 	EyeNormal:Normalize() 
 	 
 	local Pos = EyePos() + EyeNormal * Distance * 0.01 
 	 
 	// Start the new 3d camera position 
 	cam.Start3D( Pos, EyeAngles() ) 
 		 
 		// Draw our model with the Light material 
 		render.MaterialOverride( matLight ) 
 			self.Entity:DrawModel() 
 		render.MaterialOverride( 0 ) 
 	 
 	// Set the camera back to how it was 
 	cam.End3D() 
   
 end  