
include('shared.lua')


-----------------------------------------------------------
-- Name: Initialize
-----------------------------------------------------------
function ENT:Initialize()
end


-----------------------------------------------------------
-- Name: DrawPre
-----------------------------------------------------------
function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:DrawTranslucent()
	self.Entity:Draw()
end
