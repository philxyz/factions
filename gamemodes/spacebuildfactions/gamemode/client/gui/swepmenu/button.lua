------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local PANEL = {}
local button = surface.GetTextureID( "gui/swepmenu/button" )
local button2 = surface.GetTextureID( "gui/swepmenu/button2" )

function PANEL:Paint(x, y)
	surface.SetTexture( self.Image )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall() )
	return true
end

function PANEL:Init()
	self:SetMouseInputEnabled( true )
	self.Image = button
end

function PANEL:SetGun( gun )
	self.gun = gun
end

function PANEL:Think()
	
end

function PANEL:DoClick()
	RunConsoleCommand("fac_buy", self.gun)
	self:GetParent():InvalidateLayout()
	timer.Simple( .1, function() self:ResetImage() end )
	self.Image = button2
end

function PANEL:ResetImage()
	self.Image = button
end

function PANEL:PerformLayout()
end

vgui.Register( "PurchaseButton", PANEL, "Button" )
