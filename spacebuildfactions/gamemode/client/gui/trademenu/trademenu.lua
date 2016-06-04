------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

trademenu = nil
local PANEL = {}
local bg = surface.GetTextureID( "gui/scoreboard/bg" )
local logo = surface.GetTextureID( "gui/scoreboard/logo" )
local color_white = color_white
local traders = {}
local partner = nil
local MyOffer = 0
local HisOffer = 0
local timerResetWaiting = true

function PANEL:Init()

	gui.EnableScreenClicker( true )
	
	self:SetMouseInputEnabled( true )
	
	traders.page = 1
	
	self.playerbuttons = {}
	
	self.TypeBox = vgui.Create( "DTextEntry", self )
	self.TypeBox:SetKeyboardInputEnabled( true )
	self.TypeBox:SetEnabled( true )
	self.TypeBox:AllowInput(true)
	self.TypeBox:MakePopup()
	
	self.Offer = vgui.Create( "ButtonText", self )
	self.Offer:SetText( "Offer" )
	
	self.Transact = vgui.Create( "ButtonText", self )
	self.Transact:SetText( "Transact" )
	
	self.Exit = vgui.Create( "ButtonText", self )
	self.Exit:SetText( "Exit" )
	
	self:InvalidateLayout()
end

local time = nil
function PANEL:ButtonTextClick( text, page )
	if text == "Exit" then
		traders.page = 1
		traders.waiting = nil
		partner = nil
		HideTradeMenu()
		RunConsoleCommand( "fac_TradeExit" )
		RunConsoleCommand( "fac_cleartransact" )
		return
		
	elseif text == "Offer" then
		RunConsoleCommand( "fac_offer", tostring(self.TypeBox:GetValue()) )
		return
		
	elseif text == "Transact" then
		RunConsoleCommand( "fac_transact" )
		return
	end

	local ply
	for a,p in pairs( player.GetAll() ) do
		if p:Nick() == text then
			ply = p
		end
	end
	if not ply then fac_Msg("No such player '" ..tostring(text).. "'") return end
	
	if not time then time = CurTime() - 1 end
	
	if time > CurTime() then return end
	
	RunConsoleCommand( 'fac_trade', ply:Nick() )
	time = CurTime() + 12
	
	traders.waiting = ply
	
	timer.Simple( 10, ResetWaiting )
end

function PANEL:PerformLayout()
	self:SetSize( 400, 400 )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetFont( "Body" )
	
	self.Transact:SetVisible( false )
	self.Offer:SetVisible( false )
	self.Exit:SetVisible( false )
	self.TypeBox:SetEnabled( false )
	self.TypeBox:SetVisible( false )
	
	if traders.page == 1 then
		local y = 50
		surface.SetFont( "Body" )
		for k,v in pairs(traders) do
			if type(v) == "table" then
				if not k:IsValid() then
					traders[k] = nil
				else
					if not v.button then
						v.button = vgui.Create( "ButtonText", self )
					else
						v.button:SetVisible( true )
					end
					local nick = k:Nick()
					w,h = surface.GetTextSize( nick )
					v.button:SetText( nick )
					v.button:SetPos( ( (ScrW() / 2) - (w / 2) ) - self.x, y )
					v.button:SetSize( w + 2, h + 2 )
						
					self.first = v.button
						
					y = y + 20
				end
			end
		end
		
		self:SetSize( 300, y + 40 )
		
		if traders.waiting then
			for k,v in pairs(traders) do
				if type(v) == "table" then
					if not k:IsValid() then
						traders[k] = nil
					else
						v.button:SetVisible( false )
					end
				end
			end
		end
	elseif traders.page == 2 then
		self.Transact:SetVisible( true )
		self.Offer:SetVisible( true )
		self.Exit:SetVisible( true )
		self.TypeBox:SetEnabled( true )
		self.TypeBox:SetVisible( true )
		
		self:SetSize( 512, 125 )
		
		self.TypeBox:SetPos( self.x + (self:GetWide() - 250), self.y + (self:GetTall() - 69)  )
		self.TypeBox:SetSize( 100, 20 )
		
		self.Transact:SetPos( 385, 45 )
		self.Transact:SetSize( 70, 20 )
		
		self.Offer:SetPos( 385, 65 )
		self.Offer:SetSize( 40, 20 )
		
		self.Exit:SetPos( (self:GetWide() / 2) - 15, self:GetTall() - 30 )
		self.Exit:SetSize( 30, 20 )
	end
	
	self:SetPos( (ScrW() / 2) - (self:GetWide() / 2), (ScrH() / 2) - (self:GetTall() / 2) )
end

function PANEL:Paint(x, y)
	local client = LocalPlayer()
	local w,h
	
	surface.SetTexture( bg )
	surface.SetDrawColor( 50, 69, 111, 225 )
	
	surface.SetTextColor( 255, 255, 255, 255 )

	if traders.page == 1 then
		draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 69, 110, 225 ) )
	
		surface.SetFont( "Body" )
		w,h = surface.GetTextSize( "People Available to Trade With:" )
		draw.SimpleText( "People Available to Trade With:", "Body", 150, 15, color_white,1,1)
		
		if traders.waiting then
			w,h = surface.GetTextSize( "Requesting a Trade With "  .. traders.waiting:Nick().. "," )
			draw.RoundedBox( 10, (self:GetWide() / 2) - ((w + 8) / 2), (self:GetTall() / 2), w + 8, 35, color_white )
			draw.SimpleText( "Requesting a Trade With "  .. traders.waiting:Nick().. "," , "Body", 150, (self:GetTall() / 2) + 8, Color(0,0,0,255),1,1 )
			w,h = surface.GetTextSize( "Please Wait." )
			draw.SimpleText( "Please Wait.", "Body", 150, (self:GetTall() / 2) + 10 + h, Color(0,0,0,255),1,1 )
		end
	elseif traders.page == 2 then
		draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 69, 110, 225 ) )
	
		surface.SetTextColor( 255, 255, 255, 255 )
		
		draw.SimpleText( "Trading With " .. partner:Nick(), "Header", 250, 15, Color(255,255,255,255),1,1 )
		
		surface.SetFont( "Body" )
		w,h = surface.GetTextSize( partner:Nick() .. "'s Last Offer: " )
		surface.SetTextPos( 192 - w, 45 )
		surface.DrawText( partner:Nick() .. "'s Last Offer: " .. LocalPlayer():GetNWString( "HisOffer" ) )
		
		w,h = surface.GetTextSize( "Your Last Offer: " )
		surface.SetTextPos( 192 - w, 65 )
		surface.DrawText( "Your Last Offer: " .. LocalPlayer():GetNWString( "MyOffer" ) )
	end
	surface.SetFont( "Body" )
	return true
end

function ResetWaiting( um )
	if timerResetWaiting then
		traders.waiting = nil
		
		if um then
			timerResetWaiting = false
		end
	else
		timerResetWaiting = true
	end
end
usermessage.Hook("ResetWaiting", ResetWaiting)

function PartnerReady( umsg )
	traders.page = 2
	if not partner and traders.waiting then
		partner = traders.waiting
	end
end
usermessage.Hook("TradePartnerReady", PartnerReady)

function ShowTradeMenu( umsg )
	if not trademenu then
		trademenu = vgui.Create( "FAC Trade Menu" )
	end
	local trader = util.KeyValuesToTable(umsg:ReadString())
	
	for k,v in pairs( traders ) do
		if type(v) == "table" then
			if v.button then
				v.button:SetVisible( false )
			end
		end
	end
	
	for k,v in pairs( trader ) do
		for a,p in pairs( player.GetAll() ) do
			if p:UserID() == v then
				if not traders[p] then
					traders[p] = {}
				end
				traders.page = trader.page
				if traders.page == 2 then
					partner = p
				end
			end
		end
	end
	trader = nil
	
	trademenu:SetVisible( true )
	gui.EnableScreenClicker( true )
	trademenu:InvalidateLayout()
end
usermessage.Hook("fac_showtrademenu", ShowTradeMenu)

function HideTradeMenu( umsg )
	trademenu:SetVisible( false )
	gui.EnableScreenClicker( false )
	if LocalPlayer():GetNWBool( "f2" ) or LocalPlayer():GetNWBool( "showhelp" ) or LocalPlayer():GetNWBool( "showswep" ) then
		gui.EnableScreenClicker( true )
	end
	partner = nil
	RunConsoleCommand( "fac_cleartransact" )
end
usermessage.Hook("fac_hidetrademenu", HideTradeMenu)

vgui.Register("FAC Trade Menu", PANEL, "Panel")

trademenu = vgui.Create( "FAC Trade Menu" )
trademenu:SetVisible( false )

