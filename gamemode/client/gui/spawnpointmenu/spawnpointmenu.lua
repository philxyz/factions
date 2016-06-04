------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

spawnpointmenu = nil
local PANEL = {}
local color_white = color_white
local spawns

function PANEL:Init()
	gui.EnableScreenClicker( true )
	self:SetMouseInputEnabled( true )
	
	self.buttons = {}
	
	self.Exit = vgui.Create( "ButtonText", self )
	self.Exit:SetText( "Exit" )
	
	self:InvalidateLayout()
end

function PANEL:ButtonTextClick( text, page )
	if text == "Exit" then
		HideSpawnMenu()
		return
		
	else
		RunConsoleCommand( 'fac_setspawnpoint', text )
		HideSpawnMenu()
		return
	end
end

function PANEL:PerformLayout()
	self:SetSize( 500, 400 )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetFont( "Body" )
	
	self.Exit:SetPos( self:GetWide() - 32, self:GetTall() - 22 )
	self.Exit:SetSize( 30, 20 )
	
	for spawnname, button in pairs( self.buttons ) do
		button:SetVisible( false )
	end

	local y = 50
	for _,spawnname in pairs( spawns ) do
		if not self.buttons[ spawnname ] then
			self.buttons[ spawnname ] = vgui.Create( "ButtonText", self )
		else
			self.buttons[ spawnname ]:SetVisible( true )
		end
		local but = self.buttons[ spawnname ]
		
		w,h = surface.GetTextSize( spawnname )
		but:SetText( spawnname )
		but:SetPos( ( (ScrW() / 2) - (w / 2) ) - self.x, y )
		but:SetSize( w + 2, h + 2 )
		
		y = y + 20
	end
	
	self:SetSize( 300, y + 40 )
	self:SetPos( (ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2) )
end

function PANEL:Paint(x, y)
	local client = LocalPlayer()
	local w,h
	
	surface.SetDrawColor( 50, 69, 111, 225 )
	surface.SetTextColor( 255, 255, 255, 255 )

	draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 69, 110, 225 ) )
	
	surface.SetFont( "Body" )
	w,h = surface.GetTextSize( "Available Spawnpoints:" )
	draw.SimpleText( "Available Spawnpoints:", "Body", 140, 15, color_white, 1, 1)
	
	return true
end

function ShowSpawnMenu( umsg )
	spawns = util.KeyValuesToTable( umsg:ReadString() )
	
	spawnpointmenu:SetVisible( true )
	gui.EnableScreenClicker( true )
	spawnpointmenu:InvalidateLayout()
	
	HideRespawnTimer = true
end
usermessage.Hook( "fac_showspawnmenu", ShowSpawnMenu )

function HideSpawnMenu( umsg )
	spawnpointmenu:SetVisible( false )
	gui.EnableScreenClicker( false )
	
	HideRespawnTimer = false
end
usermessage.Hook( "fac_hidespawnmenu", HideSpawnMenu )

vgui.Register("FAC Spawnpoint Menu", PANEL, "Panel")

spawnpointmenu = vgui.Create( "FAC Spawnpoint Menu" )
spawnpointmenu:SetVisible( false )
