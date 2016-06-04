------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local function fac_OneTwoAC() return {"0","1",""} end
--autocomplete

local function ShowGui( ply, cmd, args )
	if not ply or not ply:IsValid() then return end
	if not args[1] then return end
	
	local arg = tonumber(args[1])
	if not arg then return end
	
	if arg == 1 then
		topbar:SetVisible( true )
		noticesEnabled = true
		fac_Msg("Showing GUI")
	elseif arg == 0 then
		trademenu:SetVisible( false )
		swepmenu:SetVisible( false )
		topbar:SetVisible( false )
		pmenu:SetVisible( false )
		hmenu:SetVisible( false )
		noticesEnabled = false
		
		gui.EnableScreenClicker( false )
		
		fac_Msg("Hiding GUI")
	end
end
concommand.Add( "fac_showgui", ShowGui, fac_OneTwoAC )
