include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()
	self.Entity:DrawModel()
end

function ENT:DrawTranslucent()
	self.Entity:Draw()
end