------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

------------------------------------
-- Progress Bar
------------------------------------

local PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled( false )
end

function PANEL:PerformLayout()
	self:SetPos( ScrW()*.5 - 50, ScrH()*.8 )
	self:SetSize( 100, 40 )
end

function PANEL:ApplySchemeSettings()
end

--local last = 0
function PANEL:Paint(x, y)
	draw.RoundedBox( 1, 0, 0, self:GetWide(), self:GetTall(), Color( 100, 100, 100, 255 ) )
	draw.RoundedBox( 1, 3, 3, (self:GetWide() - 6 ) * math.Clamp( self.progress, 0, 1 ), self:GetTall() - 6, self.color )
end

local function SetProgress( umsg )
	local progress = umsg:ReadShort()
	progress = progress * .01
	capturebar.progress = progress
	
	--fac_Debug( "progress = " .. progress )

	if progress >= 1 then
		capturebar.progress = nil
		capturebar.color = nil
		capturebar:SetVisible( false )
		return
	end
	
	if not capturebar.progress then
		capturebar:SetVisible( true )
	end
	
	if not capturebar.color then
		capturebar.color1 = Color( umsg:ReadShort(), umsg:ReadShort(), umsg:ReadShort(), 255 )
		capturebar.color2 = Color( umsg:ReadShort(), umsg:ReadShort(), umsg:ReadShort(), 255 )
		capturebar.color = capturebar.color1
	else
		capturebar.color.r = math.Approach( capturebar.color1.r, capturebar.color2.r, .8 )
		capturebar.color.g = math.Approach( capturebar.color1.g, capturebar.color2.g, .8 )
		capturebar.color.b = math.Approach( capturebar.color1.b, capturebar.color2.b, .8 )
	end
	
	capturebar:SetVisible( true )
end
usermessage.Hook( "SetProgress", SetProgress )

vgui.Register( "FAC Progress Bar", PANEL, "Panel" )
capturebar = vgui.Create( "FAC Progress Bar" )

capturebar:SetVisible( false )

--------------------------
-- Typebox
--------------------------
local flagid

PANEL = {}

function PANEL:Init()
	self:SetMouseInputEnabled( true )
	
	self:SetSize( 200, 80 )
	
	self.TypeBox = vgui.Create( "DTextEntry", self )
	self.TypeBox:SetKeyboardInputEnabled( true )
	self.TypeBox:SetEnabled( true )
	self.TypeBox:AllowInput(true)
	self.TypeBox:MakePopup()
	
	self.Button = vgui.Create( "ButtonText", self )
	self.Button:SetText( "Enter" )
	
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	self:SetSize( 250, 80 )
	self:SetPos( ( ScrW()*.5 ) - ( self:GetWide()/2 ), ( ScrH()*.50 ) - ( self:GetTall()/2 ) )
	
	self.TypeBox:SetPos( self.x + (self:GetWide() / 2 - 70), self.y + (self:GetTall() - 25) )
	self.TypeBox:SetSize( 100, 20 )
	
	self.Button:SetPos( ( self:GetWide() / 2 ) + 40, self:GetTall() - 25 ) --self:GetTall() - 50
	self.Button:SetSize( 50, 20 )
end

function PANEL:ButtonTextClick( text, page )
	RunConsoleCommand( 'fac_setspawnpointname', flagid .. ':' .. tostring( self.TypeBox:GetValue() ) )
	
	gui.EnableScreenClicker( false )
	flagtypebox:SetVisible( false )
end

function PANEL:Paint(x, y)
	local client = LocalPlayer()
	local w,h
	
	if not client:Alive() then
		flagtypebox:SetVisible( false )
	end
	
	surface.SetDrawColor( 50, 69, 111, 225 )
	surface.SetTextColor( 255, 255, 255, 255 )

	draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 69, 110, 225 ) )
	
	surface.SetFont( "Body" )
	w,h = surface.GetTextSize( "Choose The Spawnpoint Name:" )
	draw.SimpleText( "Choose The Spawnpoint Name:", "Body", 122, 8, color_white, 1, 1)
	--(self:GetWide() / 2) - w
end

local function ChooseSPName( umsg )
	flagid = umsg:ReadShort()
	
	flagtypebox:SetVisible( true )
	gui.EnableScreenClicker( true )
end
usermessage.Hook( "ChooseSPName", ChooseSPName )

vgui.Register( "FAC Typebox", PANEL, "Panel" )
flagtypebox = vgui.Create( "FAC Typebox" )

flagtypebox:SetVisible( false )
