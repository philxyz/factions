 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 
 local matnorm			= Material( "sprites/light_glow02_add" )
 
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering. 
 self.Entity:DrawModel()       // Draw the model.  
Wire_Render(self.Entity)
local islok = self:GetNetworkedBool("locked", false )
if islok then
	render.SetMaterial( matnorm )
	render.DrawSprite( self:GetPos() + self:GetUp() * 10, 32, 32, Color( 255, 0, 0, 255 )) 
end
 end  
 
 function ENT:Think()
	if (CurTime() >= (self.NextRBUpdate or 0)) then
	    self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self.Entity)
	end
end