------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

hmenu = nil
local HELPMENU = {}
local bg = surface.GetTextureID( "gui/helpmenu/help_bg" )

local Commands = {}
Commands["<NL>"] = "\n "
Commands["<DASH>"] = "-"
Commands["<SP>"] = " "
Commands["<PER>"] = "."
Commands["<QUOTE>"] = '"'
Commands["<1QUOTE>"] = "'"
Commands["END"] = ""
--Commands["<CONSOLE>"] = "~"
--Commands["<U>"] = "_"

function HELPMENU:Init()
	self.hmenu = {
				  page1 = {
						   header = "Overview",
						   body   = "<NL>In Factions, you make money by mining<PER> To do this, simply take your crowbar, and pick at a nearby rock<PER> Eventually, the rock will split and give you bits and pieces<PER> You can take these bits to a nearby transformer<PER> To use the transformer, place the rock in the overhead bin, and press e on the control panel<PER> The transformer will then process the rock and spit out money and a more refined version of the rock<PER><NL><NL>So now you have a bunch of useless rocks<PER> What next? Well, there are aliens (or humans if you are an alien) out there that would kill to have those rocks of yours<PER> Quite literally<PER> So protect them well, and trade your worthless rocks for their precious rocks<PER> Aliens have no use for gold, and humans have no use for chalcocite<PER> END",
						   body2  = "Now you may be thinking, <QUOTE>Wait<PER> Why trade, when you can kill the aliens, steal their gold, and keep your chalcocite?<QUOTE> Well<PER><PER><PER> thats up to you<PER><NL><NL>Tip: You can spawn transformers from the scripted entity menu in your Garrysmod spawn menu, they cost $600, but you will need them if you venture to other planets<PER> END"
						  },
				  page2 = {
						   header = "Trading",
						   body   = "<NL>To trade with another player, you must be near eachother<PER> Once you are near eachother press F3, and a menu will appear<PER> If more than one players are near, select the player you want to trade with, and it will then bring up a trading menu<PER><NL><NL>Now, type in the amount you would like to give to him<PER> For gold, use g at the end of the number, for chalcocite, use c at the end of the number, and for money, use the money sign at the beginning of the number<PER> So, for example, if you wanted to trade 100 chalcocite, you would type in <QUOTE>100c<QUOTE><PER><NL><NL> Once you have your amount typed in, click the offer button, and it will show your offer to the other player<PER> Once both of you are satisfied with eachother<1QUOTE>s offers, click the transact button<PER>",
						   body2  = "The transaction will not be complete until both of you press the transact button, and if any changes to any of the offers is made, both of you will have to press the trasact button again to seal the deal<PER>"
						  },
				  page3 = {
						   header = "Modes",
						   body   = "<NL>The Factions gamemode can be played in two modes, determined by the server admins<PER> <NL><NL>Free Mode <DASH> In free mode, players are free to do whatever they want<PER> This mode is similar versions prior to version 2<PER>0, but with one small change: players can now own planets<PER> <NL><NL>War Mode <DASH> In war mode, players work as a team to defeat the opposing team<PER> This is done by capturing all of the opposing team<1QUOTE>s planets, and then finally their home planet<PER>"
						  },
				  page4 = {
						   header = "Quick Reference",
						   body   = "<NL>F1 <DASH> Shows this help menu<NL>F2 <DASH> Allows you to change your team<PER> Simply click on the image of the team you wish to join<PER><NL>F3 <DASH> Searches for people to trade with, see <QUOTE>Trading<QUOTE><PER><NL>F4 <DASH> Allows you to purchase weapons<PER> If you wish to purchase ammo, click the purchase button for the gun that you wish to purchase ammo for<PER> It will buy the gun if you do not have it, then each additional click will buy another clip of ammo<PER> Ammo prices are listed at the bottom<PER><NL><NL>fac_help <DASH> Type this in your console(~) to get a complete list of console commands<PER> END",
						   body2  = "<NL>Chat Commands<NL><NL>/ <DASH> OOC Chat<NL>// <DASH> Radio Chat<NL>!forcehuman (player) <DASH> Forces player to humans team.<NL>!forcealien (player) <DASH> Forces player to aliens team.<NL>!drop (amt)(type) <DASH> Drops a resource. Example: !drop 100c<NL><NL>Ammunition Prices<NL><NL>Pistol <DASH> $40 for 50 bullets END<NL>END Shotgun <DASH> $25 for 5 shots END<NL>END SMG <DASH> $50 for 50 bullets END<NL>END Rifle <DASH> $100 for 50 bullets END<NL>END Machine Gun <DASH> $150 for 50 bullets END<NL><NL>END Grenade <DASH> $100 each END<NL>END Kevlar <DASH> $100 a vest"
						  },
				  page5 = {
						   header = "Credits",
						   body   = "<NL>Ring<DASH>Ding <DASH> Lua Programmer, Modeler<NL><NL>philxyz <DASH> Lua Programmer<NL><NL>Utstephens <DASH> Graphics Design, Web Design<NL><NL>Slavik <DASH> Mapping<NL><NL>Visit Our Website!<NL>www<PER>sbfactions<PER>blogspot<per>com<NL><NL><DASH>Team Ring-Ding"
						  }
			     }

	self.List = vgui.Create( "PanelList", self )
		self.List:EnableHorizontal( false )
		self.List:EnableVerticalScrollbar()
		self.List:SetSpacing( 1 )
		self.List:SetPadding( 3 )
		self.text = vgui.Create( "DLabel", self )
		self.text2 = vgui.Create( "DLabel", self )
		self.header = vgui.Create( "DLabel", self )
		--self.filler = vgui.Create( "Label", self )
		self.List:AddItem( self.header )
		self.List:AddItem( self.text )
		self.List:AddItem( self.text2 )
		--self.List:AddItem( self.filler )
	
	self.Buttons = {}
	for k = 1, table.Count( self.hmenu ) do
		self.Buttons[ "page" .. k ] = vgui.Create( "ButtonText", self )
		self.Buttons[ "page" .. k ]:SetText( self.hmenu[ "page" .. k ].header )
		self.Buttons[ "page" .. k ]:SetPage( k )
	end
	
	self.page     = 1
	
	if not Factions.Addons.Content then --player doesnt have content pack
		self.Header = vgui.Create( "DLabel", self )
		self.Header:SetText( "Humans Vs Aliens" )
		
		self.Header2 = vgui.Create( "DLabel", self )
		self.Header2:SetText( "-Spacebuild Roleplay-" )
	end
end

function HELPMENU:PerformLayout()
	self:SetPos( ScrW() / 2 - 256, ScrH() / 2 - 128 )
		self:SetSize( 512, 256 )
		gui.EnableScreenClicker( true )
		
	if not Factions.Addons.Content then
		self.Header:SetFont( "ScoreboardHeader" )
		self.Header:SizeToContents()
		self.Header:SetPos( self:GetWide() / 2 - self.Header:GetWide() / 2, 2 )
		
		self.Header2:SetFont( "ScoreboardSubtitle" )
		self.Header2:SizeToContents()
		self.Header2:SetPos( self:GetWide() / 2 - self.Header2:GetWide() / 2, self.Header.y + self.Header:GetTall() + 4 )
	end
	
	self.List:SetPos( 230, 71 )
		self.List:SetSize( 254, 155 )
		self.List:GetCanvas():SetBGColor( 100, 139, 221, 125 )
	
	self.header:SetText( self.hmenu["page" ..tostring(self.page)].header )
		self.header:SetSize( 254, 30 )
		self.header:SetFont( "Header" )

	surface.SetFont( "Header" )
	
	local w,h = surface.GetTextSize( "Mg" )
		self.text:SetSize( 254, h + 10 )
		self.text:SetFont( "Body" )
		self.text2:SetSize( 254, h + 10 )
		self.text2:SetFont( "Body" )
	
	surface.SetFont("Body")
	
	local string  = self:FormatText( self.hmenu["page" .. tostring(self.page)].body )
		local w,h = surface.GetTextSize( string )
		self.text:SetText( string )
		self.text:SetSize( 254, h )
		
	local string2 = self:FormatText( self.hmenu["page" .. tostring(self.page)].body2 or "")
		local w,h = surface.GetTextSize( string2 )
		self.text2:SetText( string2 )
		self.text2:SetSize( 254, h )
	
	local y = 60
	for k = 1, table.Count( self.Buttons ) do
		local w,h = surface.GetTextSize( self.hmenu["page" ..tostring(k)].header )
			self.Buttons["page" ..tostring(k)]:SetSize( w + 6, h )
			self.Buttons["page" ..tostring(k)]:SetPos( 106 - (w / 2), y )
			y = y + 30
	end
	
	self.List:InvalidateLayout()
end

function HELPMENU:FormatText( text )
	local string = ""
	local stringout = nil
	for w in string.gmatch( text, "[abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890<>(),$!?/~_:]+" ) do
		for k,v in pairs(Commands) do
			string = string.gsub( string, k, v )
		end
		local x,y = surface.GetTextSize( string )
		if x > 150 then
			stringout = ( stringout or "" ) .. " " .. string .. "\n  "
			string = ""
		end
		string = string .. " " .. w
	end
	for k,v in pairs(Commands) do
		string = string.gsub( string, k, v )
	end
	if stringout then
		stringout = stringout .. " " .. string
	else
		stringout = string
	end
	
	return stringout
end

function HELPMENU:ButtonTextClick( text, page )
	self.page = page
	self:InvalidateLayout()
end

function HELPMENU:Paint(x, y)
	if Factions.Addons.Content then
		surface.SetTexture( bg )
		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.DrawTexturedRect( 0, 0, 512, 255 )
	else
		draw.RoundedBox( 10, 0, 0, self:GetWide(), self:GetTall(), Color( 100, 139, 221, 125 ) )
	end
end

function ShowHelpMenu()
	if not hmenu then
		hmenu = vgui.Create( "FAC Help Menu" )
	end
	hmenu:SetVisible( true )
	gui.EnableScreenClicker( true )
	hmenu:InvalidateLayout()
end
usermessage.Hook("fac_showhelpmenu", ShowHelpMenu)

function HideHelpMenu( ply )
	hmenu:SetVisible( false )
	gui.EnableScreenClicker( false )
	if LocalPlayer():GetNWBool( "f2" ) or LocalPlayer():GetNWBool( "showswep" ) then
		gui.EnableScreenClicker( true )
	end
end
usermessage.Hook("fac_hidehelpmenu", HideHelpMenu)

vgui.Register("FAC Help Menu", HELPMENU, "Panel")

hmenu = vgui.Create( "FAC Help Menu" )
hmenu:SetVisible( false )
