------------------------------------------
-- Spacebuild Factions
-- Team Ring-Ding
------------------------------------------

include( "player_row.lua" )
include( "player_frame.lua" )

surface.CreateFont( "ScoreboardHeader", {
	font = "coolvetica",
	size = 34,
	weight = 300,
	antialias = true,
	shadow = false
})

surface.CreateFont( "ScoreboardSubtitle", {
	font = "coolvetica",
	size = 22,
	weight = 500,
	antialias = true,
	shadow = false
})

surface.CreateFont( "Body", {
	font = "middages",
	size = 18,
	weight = 700,
	antialias = true,
	shadow = false
})

surface.CreateFont( "ScoreboardLabel", {
	font = "middages",
	size = 13,
	weight = 700,
	antialias = true,
	shadow = false
})

local texGradient 	= surface.GetTextureID( "gui/center_gradient" )
local texBG 	    = surface.GetTextureID( "gui/scoreboard/bg" )
local texLogo 		= surface.GetTextureID( "gui/scoreboard/logo" )
local humanheader   = surface.GetTextureID( "gui/scoreboard/humanheader" )
local alienheader   = surface.GetTextureID( "gui/scoreboard/alienheader" )


local PANEL = {}

--[[-------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:Init()

	SCOREBOARD = self

	self.Hostname = vgui.Create( "DLabel", self )
	self.Hostname:SetText( GetGlobalString( "ServerName" ) )

	self.HumanHeader = vgui.Create( "DLabel", self )
	self.HumanHeader:SetText( "" )
	
	self.AlienHeader = vgui.Create( "DLabel", self )
	self.AlienHeader:SetText( "" )
	
	self.PlayerFrameHuman = vgui.Create( "PlayerFrame", self )
	self.PlayerFrameAlien = vgui.Create( "PlayerFrame", self )
	
	self.HumanLbl = {}
		self.HumanLbl.Planets = vgui.Create( "DLabel", self )
		self.HumanLbl.Planets:SetText( "Planets" )
		
		self.HumanLbl.Ping = vgui.Create( "DLabel", self )
		self.HumanLbl.Ping:SetText( "Latency" )
		
		self.HumanLbl.Kills = vgui.Create( "DLabel", self )
		self.HumanLbl.Kills:SetText( "Kills" )
		
		self.HumanLbl.Deaths = vgui.Create( "DLabel", self )
		self.HumanLbl.Deaths:SetText( "Deaths" )
	
	self.AlienLbl = {}
		self.AlienLbl.Planets = vgui.Create( "DLabel", self )
		self.AlienLbl.Planets:SetText( "Planets" )
		
		self.AlienLbl.Ping = vgui.Create( "DLabel", self )
		self.AlienLbl.Ping:SetText( "Latency" )
		
		self.AlienLbl.Kills = vgui.Create( "DLabel", self )
		self.AlienLbl.Kills:SetText( "Kills" )
		
		self.AlienLbl.Deaths = vgui.Create( "DLabel", self )
		self.AlienLbl.Deaths:SetText( "Deaths" )
		
	self.Mode = vgui.Create( "DLabel", self )
	self.Mode:SetText( "Free" ) --assume free mode

	self.PlayerRows = {}

	self:UpdateScoreboard()
	
	timer.Create( "ScoreboardUpdater", .1, 0, function() self:UpdateScoreboard() end )
	
end

--[[-------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:AddPlayerRow( ply )
	for k, v in pairs( self.PlayerRows ) do
		if k == ply then
			self.PlayerRows[ ply ] = nil
			v:Remove()
		end
	end
	local button
	if ply:Team() == TEAM_HUMANS then
		button = vgui.Create( "ScorePlayerRow", self.PlayerFrameHuman:GetCanvas() )
	elseif ply:Team() == TEAM_ALIENS then
		button = vgui.Create( "ScorePlayerRow", self.PlayerFrameAlien:GetCanvas() )
	else
		button = vgui.Create( "ScorePlayerRow", self.PlayerFrameHuman:GetCanvas() )
	end
	button:SetPlayer( ply )
	self.PlayerRows[ ply ] = button
end

--[[-------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:GetPlayerRow( ply )

	return self.PlayerRows[ ply ]

end

--[[-------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:Paint(x, y)

	surface.SetTexture( texBG )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, self:GetWide(), self:GetTall(), 250, 600 )

	-- Humans Team Header
		
	surface.SetTexture( humanheader )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 4, self.HumanHeader.y - 38, self:GetWide() - 8, 64 )
		
	-- Aliens Team Header
		
	surface.SetTexture( alienheader )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 4, self.AlienHeader.y - 38, self:GetWide() - 8, 64 )

	-- Logo
	surface.SetTexture( texLogo )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 512, 128 )
	
	-- Black Inner Box
	draw.RoundedBox( 4, 20, self.HumanHeader.y, self:GetWide() - 40, self.PlayerFrameAlien:GetCanvas():GetTall() + self.PlayerFrameHuman:GetCanvas():GetTall() + self.AlienHeader:GetTall() + self.HumanHeader:GetTall() , Color( 20, 20, 20, 150 ) )
	
end


--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:PerformLayout()

	self.Hostname:SizeToContents()
	self.Hostname:SetPos( 80, 84 )
	
	self.HumanHeader:SizeToContents()
	self.HumanHeader:SetPos( 170, 108 )
	
	self.Mode:SizeToContents()
	self.Mode:SetPos( 480, 84 )
	
	if not iTall then
		iTall = 300
		iTall = math.Clamp( iTall, 100, ScrH() * 0.9 )
	end
	if not iWide then
		iWide = 512
	end
	
	self:SetSize( iWide, iTall )
	self:SetPos( (ScrW() - self:GetWide()) / 2, (ScrH() - self:GetTall()) / 3 )
	
	self.PlayerFrameHuman:SetPos( 22, self.HumanHeader.y + self.HumanHeader:GetTall() + 3 )
	self.PlayerFrameHuman:SetSize( self:GetWide() - 44, self:GetTall() - self.PlayerFrameHuman.y - 10 )
	
	self.PlayerFrameAlien:SetPos( 22, self.AlienHeader.y + self.AlienHeader:GetTall() + 3 )
	self.PlayerFrameAlien:SetSize( self:GetWide() - 44 , self:GetTall() - self.PlayerFrameAlien.y - 10 )
	
	local yh = 0
	local ya = 0
	
	local PlayerSorted = {}
	
	for k, v in pairs( self.PlayerRows ) do
	
		table.insert( PlayerSorted, v )
		
	end
	
	table.sort( PlayerSorted, function ( a , b) return a:HigherOrLower( b ) end )
	
	for k, v in ipairs( PlayerSorted ) do
	
		if v.Player:Team() == TEAM_HUMANS then
			
			v:SetPos( 0, yh )
			v:SetSize( self.PlayerFrameHuman:GetWide(), v:GetTall() )
			
			self.PlayerFrameHuman:GetCanvas():SetSize( self.PlayerFrameHuman:GetCanvas():GetWide(), yh + v:GetTall() )
			
			yh = yh + v:GetTall() + 1
			
		elseif v.Player:Team() == TEAM_ALIENS then
		
			v:SetPos( 0, ya )
			v:SetSize( self.PlayerFrameHuman:GetWide(), v:GetTall() )
			
			self.PlayerFrameAlien:GetCanvas():SetSize( self.PlayerFrameHuman:GetCanvas():GetWide(), ya + v:GetTall() )
			
			ya = ya + v:GetTall() + 1
		
		else
			v:SetSize( 0, 0 )
		end
	end
	
	self.AlienHeader:SizeToContents()
	self.AlienHeader:SetPos( 174, self.PlayerFrameHuman.y + yh )
	
	iTall = math.Clamp( self.PlayerFrameAlien:GetCanvas():GetTall() + self.PlayerFrameHuman:GetCanvas():GetTall() + self.AlienHeader:GetTall() + self.HumanHeader:GetTall() + self.HumanHeader.y + 20, 170, ScrH() - 5 )
	
	self:SetSize( iWide, iTall )
	
	self.Hostname:SetText( GetGlobalString( "ServerName" ) )
	self.Mode:SetText( Factions.GetNWVar( "Mode", "" ) )
	
	if Factions.GetNWVar( "Mode" ) == "War" then
		self.HumanLbl.Planets:SetText( "Score: " .. team.GetScore( TEAM_HUMANS ) )
		self.AlienLbl.Planets:SetText( "Score: " .. team.GetScore( TEAM_ALIENS ) )
	else
		self.HumanLbl.Planets:SetText( "Planets" )
		self.AlienLbl.Planets:SetText( "Planets" )
	end
	
	self.HumanLbl.Planets:SizeToContents()
		self.HumanLbl.Kills:SizeToContents()
		self.HumanLbl.Deaths:SizeToContents()
		self.HumanLbl.Ping:SizeToContents()
		
		self.HumanLbl.Planets:SetPos( 260, self.HumanHeader.y + 4 )
		self.HumanLbl.Kills:SetPos( 341, self.HumanHeader.y + 4 )
		self.HumanLbl.Deaths:SetPos( 396, self.HumanHeader.y + 4 )
		self.HumanLbl.Ping:SetPos( 443, self.HumanHeader.y + 4 )
	
	self.AlienLbl.Planets:SizeToContents()
		self.AlienLbl.Kills:SizeToContents()
		self.AlienLbl.Deaths:SizeToContents()
		self.AlienLbl.Ping:SizeToContents()
		
		self.AlienLbl.Planets:SetPos( 260, self.AlienHeader.y + 4 )
		self.AlienLbl.Kills:SetPos( 341, self.AlienHeader.y + 4 )
		self.AlienLbl.Deaths:SetPos( 396, self.AlienHeader.y + 4 )
		self.AlienLbl.Ping:SetPos( 443, self.AlienHeader.y + 4 )
end

--[[-------------------------------------------------------
   Name: ApplySchemeSettings
---------------------------------------------------------]]
function PANEL:ApplySchemeSettings()
	local color_white = color_white

	self.Hostname:SetFont( "" )
	self.HumanHeader:SetFont( "ScoreboardSubtitle" )
	self.AlienHeader:SetFont( "ScoreboardSubtitle" )
	self.Mode:SetFont( "" )
	
	self.Hostname:SetFGColor( color_white )
	self.HumanHeader:SetFGColor( color_white )
	self.AlienHeader:SetFGColor( color_white )
	self.Mode:SetFGColor( color_white )

	self.HumanLbl.Planets:SetFont( "ScoreboardLabel" )
		self.HumanLbl.Kills:SetFont( "ScoreboardLabel" )
		self.HumanLbl.Deaths:SetFont( "ScoreboardLabel" )
		self.HumanLbl.Ping:SetFont( "ScoreboardLabel" )
		
		self.HumanLbl.Planets:SetFGColor( color_white )
		self.HumanLbl.Kills:SetFGColor( color_white )
		self.HumanLbl.Deaths:SetFGColor( color_white )
		self.HumanLbl.Ping:SetFGColor( color_white )
	
	self.AlienLbl.Planets:SetFont( "ScoreboardLabel" )
		self.AlienLbl.Kills:SetFont( "ScoreboardLabel" )
		self.AlienLbl.Deaths:SetFont( "ScoreboardLabel" )
		self.AlienLbl.Ping:SetFont( "ScoreboardLabel" )
		
		self.AlienLbl.Planets:SetFGColor( color_white )
		self.AlienLbl.Kills:SetFGColor( color_white )
		self.AlienLbl.Deaths:SetFGColor( color_white )
		self.AlienLbl.Ping:SetFGColor( color_white )
	
end


function PANEL:UpdateScoreboard( force )

	if ( not force and not self:IsVisible() ) then return end

	for k, v in pairs( self.PlayerRows ) do
	
		if ( not k:IsValid() ) then
		
			v:Remove()
			self.PlayerRows[ k ] = nil
			
		end
	
	end
	
	local PlayerList = player.GetAll()	
	for id, pl in pairs( PlayerList ) do
	
		self:AddPlayerRow( pl )
		
	end
	
	-- Always invalidate the layout so the order gets updated
	self:InvalidateLayout()

end

vgui.Register( "FactionsScoreBoard", PANEL, "Panel" )
