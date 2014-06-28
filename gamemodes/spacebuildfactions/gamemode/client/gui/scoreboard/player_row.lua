------------------------------------------
-- Spacebuild Factions
-- Team Ring-Ding
------------------------------------------

surface.CreateFont("ScoreboardPlayerName", {
	font = "middages",
	size = 14,
	weight = 700,
	antialias = true,
	shadow = false
})

local PANEL = {}

--[[-------------------------------------------------------
   Name: Paint
---------------------------------------------------------]]
function PANEL:Paint(x, y)
	return true
end

--[[-------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------]]
function PANEL:SetPlayer( ply )

	self.Player = ply
	
	self:UpdatePlayerData()

end
--[[-------------------------------------------------------
   Name: UpdatePlayerData
---------------------------------------------------------]]
function PANEL:UpdatePlayerData()

	if ( not self.Player ) then return end
	if ( not self.Player:IsValid() ) then return end
	
	self.lblName:SetText( self.Player:Nick() )
	
	if Factions.GetNWVar( "Mode" ) == "War" then
		self.lblPlanets:SetText( self.Player:GetNWInt( "Score" ) )
	else
		self.lblPlanets:SetText( self.Player:GetNWInt( "Planets" ) )
	end
	self.lblFrags:SetText( self.Player:Frags() )
	self.lblDeaths:SetText( self.Player:Deaths() )
	self.lblPing:SetText( self.Player:Ping() )
end

--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:Init()

	self.Size = 24
	self:OpenInfo( false )
	
	self.lblName 	= vgui.Create( "DLabel", self )
	self.lblPlanets = vgui.Create( "DLabel", self )
	self.lblFrags 	= vgui.Create( "DLabel", self )
	self.lblDeaths 	= vgui.Create( "DLabel", self )
	self.lblPing 	= vgui.Create( "DLabel", self )

end

--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:ApplySchemeSettings()

	self.lblName:SetFont( "ScoreboardPlayerName" )
	self.lblPlanets:SetFont( "ScoreboardPlayerName" )
	self.lblFrags:SetFont( "ScoreboardPlayerName" )
	self.lblDeaths:SetFont( "ScoreboardPlayerName" )
	self.lblPing:SetFont( "ScoreboardPlayerName" )
	
	self.lblName:SetFGColor( color_white )
	self.lblPlanets:SetFGColor( color_white )
	self.lblFrags:SetFGColor( color_white )
	self.lblDeaths:SetFGColor( color_white )
	self.lblPing:SetFGColor( color_white )

end

--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]

function PANEL:OpenInfo( bool )

	if ( bool ) then
		self.TargetSize = 150
	else
		self.TargetSize = 24
	end
	
	self.Open = bool

end

--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:Think()

	if ( self.Size ~= self.TargetSize ) then
	
		self.Size = math.Approach( self.Size, self.TargetSize, (math.abs( self.Size - self.TargetSize ) + 1) * 10 * FrameTime() )
		self:PerformLayout()
		SCOREBOARD:InvalidateLayout()
	--	self:GetParent():InvalidateLayout()
	
	end
	
	if ( not self.PlayerUpdate or self.PlayerUpdate < CurTime() ) then
	
		self.PlayerUpdate = CurTime() + 0.5
		self:UpdatePlayerData()
		
	end

end

--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:PerformLayout()

	self:SetSize( self:GetWide(), self.Size )
	
	self.lblName:SizeToContents()
	self.lblName:SetPos( 10, 2 )
	
	local COLUMN_SIZE = 50
	
	self.lblPing:SetPos( self:GetWide() - COLUMN_SIZE * .45, 0 )
	self.lblDeaths:SetPos( self:GetWide() - COLUMN_SIZE * 1.65, 0 )
	self.lblFrags:SetPos( self:GetWide() - COLUMN_SIZE * 2.9, 0 )
	self.lblPlanets:SetPos( self:GetWide() - COLUMN_SIZE * 4.3, 0 )

end

--[[-------------------------------------------------------
   Name: PerformLayout
---------------------------------------------------------]]
function PANEL:HigherOrLower( row )

	if ( self.Player:Team() == TEAM_CONNECTING ) then return false end
	if ( row.Player:Team() == TEAM_CONNECTING ) then return true end
	
	if ( self.Player:Frags() == row.Player:Frags() ) then
	
		return self.Player:Deaths() < row.Player:Deaths()
	
	end

	return self.Player:Frags() > row.Player:Frags()

end


vgui.Register( "ScorePlayerRow", PANEL, "Button" )
