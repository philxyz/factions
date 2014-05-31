 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]] 
 
 local lasmat = Material( "effects/spark" )
 local matLight = Material( "effects/yellowflare" )
 function ENT:Draw()      
	
	local pos = self.Entity:GetPos()
	render.SetMaterial( matLight )
	render.DrawQuadEasy(pos, VectorRand(), 32 , 32 , color_white )
	render.DrawQuadEasy( pos, VectorRand(), math.Rand(16, 64), math.Rand(16, 64), color_white )
	render.DrawSprite( pos, 64, 64, Color( 255, 150, 150, 255 ) )
	
	render.SetMaterial( lasmat )
	render.DrawBeam( self:GetPos(), 		
					 self:GetPos() - self:GetUp() * 128,
					 32,
					 1,
					 0,
					 Color( 255, 255, 255, 255 ) )
 end  