------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local MENU = {}

function MENU:Init()
end

function MENU:PerformLayout()
	self:SetPos( ScrW() / 2 - 256, ScrH() / 2 - 256 )
	self:SetSize( 512, 512 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( true )
end

function MENU:ApplySchemeSettings()
end

function MENU:Paint(x, y)
	local main_off = surface.GetTextureID( "gui/menu/main_off" )
    local main_human = surface.GetTextureID( "gui/menu/main_human" )
    local main_alien = surface.GetTextureID( "gui/menu/main_alien" )
	local client = LocalPlayer()
	local x = gui.MouseX()
	local y = gui.MouseY()
	
	surface.SetTexture( main_off )
			
	if x > ((ScrW() / 2 - 256) + 108) and x < ((ScrW() / 2 - 256) + 225) --if x inside human animation box
	and y > ((ScrH() / 2 - 256) + 175) and y < ((ScrH() / 2 - 256) + 409) then --if y inside human animation box
		surface.SetTexture( main_human )
	elseif x > ((ScrW() / 2 - 256) + 302) and x < ((ScrW() / 2 - 256) + 430) --if x inside alien animation box
	and y > ((ScrH() / 2 - 256) + 189) and y < ((ScrH() / 2 - 256) + 409) then --if y inside alien animation box
		surface.SetTexture( main_alien )
	end
			
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 512, 512 )
	return true
end

function MENU:OnMouseReleased()
	client = LocalPlayer()
	
	local x = gui.MouseX()
	local y = gui.MouseY()
	
	if x > ((ScrW() / 2 - 256) + 108) and x < ((ScrW() / 2 - 256) + 225)
	and y > ((ScrH() / 2 - 256) + 175) and y < ((ScrH() / 2 - 256) + 409) then
		RunConsoleCommand("fac_Human")
	elseif x > ((ScrW() / 2 - 256) + 302) and x < ((ScrW() / 2 - 256) + 430)
	and y > ((ScrH() / 2 - 256) + 189) and y < ((ScrH() / 2 - 256) + 409) then
		RunConsoleCommand("fac_Alien")
	end
end

local function ShowMenu()
	if not Factions.TeamMenu then
		Factions.TeamMenu = vgui.Create( "FAC Menu" )
	end
	Factions.TeamMenu:SetVisible( true )
	Factions.TeamMenu:InvalidateLayout()
end
usermessage.Hook("fac_showteammenu", ShowMenu)

local function HideMenu()
	if not Factions.TeamMenu then
		Factions.TeamMenu = vgui.Create( "FAC Menu" )
	end
	
	Factions.TeamMenu:SetVisible( false )
	gui.EnableScreenClicker( false )
	if LocalPlayer():GetNWBool( "showhelp" ) or LocalPlayer():GetNWBool( "showswep" ) or LocalPlayer():GetNWBool( "showtrader" ) then
		gui.EnableScreenClicker( true )
	end
end
usermessage.Hook("fac_hideteammenu", HideMenu)

vgui.Register("FAC Menu", MENU, "Panel")
Factions.TeamMenu = vgui.Create( "FAC Menu" )

Factions.TeamMenu:SetVisible( true )
