------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

include( "scoreboard.lua" )

local pScoreBoard = nil

function GM:CreateScoreboard()

	if ( ScoreBoard ) then
	
		ScoreBoard:Remove()
		ScoreBoard = nil
	
	end

	pScoreBoard = vgui.Create( "FactionsScoreBoard" )

end

function GM:ScoreboardShow()

	GAMEMODE.ShowScoreboard = true
	
	gui.EnableScreenClicker( false )
	
	if ( not pScoreBoard ) then
		self:CreateScoreboard()
	end
	
	pScoreBoard:SetVisible( true )
	pScoreBoard:UpdateScoreboard( true )
	
	if pmenu then
		pmenu:SetVisible( false )
	end
end

function GM:ScoreboardHide()

	GAMEMODE.ShowScoreboard = false
	
	pScoreBoard:SetVisible( false )
	
	gui.EnableScreenClicker( false )

	if pmenu and LocalPlayer():GetNetworkedBool( "f2" ) then
		pmenu:SetVisible( true )
		gui.EnableScreenClicker( true )
	end
	if LocalPlayer():GetNWBool( "showhelp" ) or LocalPlayer():GetNWBool( "showswep" ) or LocalPlayer():GetNWBool( "showtrader" ) then
		gui.EnableScreenClicker( true )
	end
end

function GM:HUDDrawScoreBoard()
end
