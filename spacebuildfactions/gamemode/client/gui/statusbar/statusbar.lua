------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local TOPBAR = {}

function TOPBAR:Init()
	self:SetMouseInputEnabled(false)
end

function TOPBAR:PerformLayout()
	self:SetPos( 0, 0 )
	self:SetSize( ScrW(), 24 )
end

function TOPBAR:ApplySchemeSettings()
end

function TOPBAR:Paint(x, y)
	local client = LocalPlayer()
	local EXP = client:GetNetworkedInt( "currentexp" )
	local nextpromo = client:GetNetworkedInt( "nextpromo" )
	local status = client:GetNetworkedString( "status" )
	local class = client:GetNetworkedString( "class" )
	local money = client:GetNetworkedInt( "money" )
	local blackore = client:GetNWInt( "rock0" )
	local gold = client:GetNWInt( "rock1" )
	local t
	if client.Team then
		t = client:Team()
	end
	
	local length     = -35 --should make 5 w/ spacer
	local spacer     = 40
	
	surface.SetFont( "Default" )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	draw.RoundedBox(0, 0, 0, ScrW(), 24, Color(0, 0, 0, 150))
	draw.RoundedBox(0, 0, 24, ScrW(), 2, Color(255, 255, 255, 255))

	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Money: " ..money )
		local x, y = surface.GetTextSize( "Money: " ..tostring(money) )
		moneypos = ( length + spacer + (x / 2) )
		length = length + x + spacer
	
	if t and t == TEAM_ALIENS then
		surface.SetTextPos( length + spacer, 5 )
		
		surface.DrawText( "Gold: " ..gold )
		local x, y = surface.GetTextSize( "Gold: " ..tostring(gold) )
		
		goldpos = ( length + spacer + (x / 2) )
		length = length + x + spacer
	
	elseif t and t == TEAM_HUMANS then
		surface.SetTextPos( length + spacer, 5 )
		
		surface.DrawText( "Chalcocite: " ..blackore )
		local x, y = surface.GetTextSize( "Chalcocite: " ..tostring(blackore) )
		
		orepos = ( length + spacer + (x / 2) )
		length = length + x + spacer
	end
	
	local mode = Factions.GetNWVar( "Mode", "" )
		surface.SetTextPos( length + spacer, 5 )
		local planets = 0
		
		if t and mode == "War" then
			planets = Factions.GetNWVar( team.GetName( t ) .. "Planets", 0 )
			
		elseif mode == "Free" then
			planets = client:GetNWInt( "Planets" )
		end
		
		surface.DrawText( "Planets: " .. planets )
		x, y = surface.GetTextSize( "Planets: " .. planets )
		length = length + x + spacer
	
	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Gamemode: Factions" )
		local x, y = surface.GetTextSize( "Gamemode: Factions" )
		length = length + x + spacer

	surface.SetTextPos( length + spacer, 5 )
		surface.DrawText( "Author: Team Ring-Ding. GMod13 port: philxyz" )
		local x, y = surface.GetTextSize( "Creator: Team Ring-Ding, GM13 port: philxyz" )
		length = length + x + spacer
end

vgui.Register("FAC Top Bar", TOPBAR, "Panel")
topbar = vgui.Create( "FAC Top Bar" )

topbar:SetVisible( true )
