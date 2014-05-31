------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local PANEL = {}

function PANEL:Paint(x, y)
	return true
end

function PANEL:Init()
	self.label = vgui.Create( "DLabel", self )
	
	self.label:SetMouseInputEnabled( false )
end

function PANEL:SetText( text )
	self.text = text
	self:InvalidateLayout()
end

function PANEL:SetPage( page )
	self.page = page
end

function PANEL:Think()
end

function PANEL:GetText()
	return self.text
end

function PANEL:DoClick()
	self:GetParent():ButtonTextClick( self.text, self.page )
	self:GetParent():InvalidateLayout()
end

function PANEL:PerformLayout()
	self.label:SetPos( 0, 0 )
	self.label:SetText( self.text )
	self.label:SetFont( "Body" )
	self.label:SetFGColor( color_white )
	self.label:SetSize( self:GetWide(), self:GetTall() )
end

vgui.Register( "ButtonText", PANEL, "Button" )
