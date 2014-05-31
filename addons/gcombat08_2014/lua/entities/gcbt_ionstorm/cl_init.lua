 include('shared.lua')     
 //[[---------------------------------------------------------     
 //Name: Draw     Purpose: Draw the model in-game.     
 //Remember, the things you render first will be underneath!  
 //-------------------------------------------------------]]  
 
 local Laser = Material( "sprites/rollermine_shock" )
 
 function ENT:Draw()      
 // self.BaseClass.Draw(self)  
 -- We want to override rendering, so don't call baseclass.                                   
 // Use this when you need to add to the rendering.  
 
 local pos = self:GetPos()
 
 local enthit = self:GetNetworkedEntity( "lasorent" )
 if !enthit:IsValid() then self:SetNetworkedEntity( "lasorent", self.Entity ); enthit = self.Entity end

render.SetMaterial( Laser ) 
	
	local dirmins = enthit:GetPos() - self:GetPos()
	
	render.StartBeam( 7 )
	render.AddBeam( pos , 64, 0, Color( 255, 255, 255, 255 ) )
	for i=2, (6) do
		local curpos = pos + (i/7) * dirmins + VectorRand() * 40
		render.AddBeam( curpos , 64, CurTime() + i/5, Color( 255, 255, 255, 255 ) )
	end
	
	render.AddBeam( enthit:GetPos() , 64, 1, Color( 255, 255, 255, 255 ) )
	render.EndBeam()
	
end 