include('shared.lua')

ENT.DrawHalo = true

function ENT:Draw()
	self:DoNormalDraw()
	
	if (Wire_Render) then
		Wire_Render(self.Entity)
	end
end

function ENT:DoNormalDraw()

	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity and EyePos():Distance( self.Entity:GetPos() ) < 250 ) then
		if ( self.RenderGroup == RENDERGROUP_OPAQUE ) then
			self.OldRenderGroup = self.RenderGroup
			self.RenderGroup = RENDERGROUP_TRANSLUCENT
		end
		
		self.Entity:DrawModel()
		
		local overlayText = self:GetOverlayText()

		if overlayText == nil then print("overlay text is nil.") end

		if ( overlayText ~= "" ) then
			AddWorldTip( self.Entity:EntIndex(), self:GetOverlayText(), 0.5, self.Entity:GetPos(), self.Entity  )
		end
	else
		if ( self.OldRenderGroup ~= nil ) then
			self.RenderGroup = self.OldRenderGroup
			self.OldRenderGroup = nil
		end
		
		self.Entity:DrawModel()
	end
end

function ENT:Think()
	if (Wire_UpdateRenderBounds and CurTime() >= (self.NextRBUpdate or 0)) then
		self.NextRBUpdate = CurTime()+2
		Wire_UpdateRenderBounds(self.Entity)
	end
end
