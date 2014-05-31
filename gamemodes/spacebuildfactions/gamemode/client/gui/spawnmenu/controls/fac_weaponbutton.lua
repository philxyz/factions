surface.CreateFont( "SM_WeaponTitle", {
	font = "middages",
	size = 20,
	weight = 700,
	antialias = true,
	shadow = false
})

surface.CreateFont( "SM_WeaponBody", {
	font = "middages",
	size = 12,
	weight = 700,
	antialias = true,
	shadow = false
})

local PANEL = {}

function PANEL:Init()

	self.Title = vgui.Create ( "DLabel", self )
	self.Cost = vgui.Create ( "DLabel", self )
	self.AmmoCost = vgui.Create ( "DLabel", self )
	
	self.Cost:SetText("")
	self.AmmoCost:SetText("")
	
	self:SetText("")
	
end

function PANEL:PerformLayout()
	
	self:SetSize( 200, 83 )
	
	self.Title:SetPos(83,2)
	self.Cost:SetPos(83,32)
	self.AmmoCost:SetPos(83,50)
	
	self.Title:SetFont( "SM_WeaponTitle" )
	self.Cost:SetFont( "SM_WeaponBody" )
	self.AmmoCost:SetFont( "SM_WeaponBody" )
	
	self.Title:SetTextColor( color_white )
	self.Cost:SetTextColor( color_white )
	self.AmmoCost:SetTextColor( color_white )
	
	self.Title:SetContentAlignment( 5 )
	self.Cost:SetContentAlignment( 5 )
	self.AmmoCost:SetContentAlignment( 5 )
	
	self.Title:SizeToContents()
	self.Cost:SizeToContents()
	self.AmmoCost:SizeToContents()
	
	self.Title:SetWide( self:GetWide() - self.Title.x )
	self.Cost:SetWide( self:GetWide() - self.Cost.x )
	self.AmmoCost:SetWide( self:GetWide() - self.AmmoCost.x )
	
	self.Image:SetPos( 2, 2 )
	self.Image:SetSize( 79, 79 )
	
	if ( self.imgAdmin ) then
		self.imgAdmin:SizeToContents()
		self.imgAdmin:AlignTop( 4 )
		self.imgAdmin:AlignLeft( 4 )
	end
	
end

function PANEL:CreateAdminIcon()
	self.imgAdmin = vgui.Create( "DImage", self )
	self.imgAdmin:SetImage( "gui/silkicons/shield" )
	self.imgAdmin:SetTooltip( "#Admin Only" )
end

function PANEL:OnMousePressed( mousecode )
	if ( self.m_bDisabled ) then return end

	self:MouseCapture( true )
	self.Depressed = true

	self.Image:SetPos( 4, 4 )
	self.Image:SetSize( 77, 77 )
end

function PANEL:OnMouseReleased( mousecode )
	self:MouseCapture( false )
	
	if ( not self.Depressed ) then return end
	
	self.Depressed = nil
	
	if ( not self.Hovered ) then return end
	

--	if ( mousecode == MOUSE_RIGHT ) then
--		PCallError( self.DoRightClick, self )
--	end
	
--	if ( mousecode == MOUSE_LEFT ) then
--		PCallError( self.DoClick, self )
--	end

	self.Image:SizeToContents()
	self.Image:SetPos( 2, 2 )
	self.Image:SetSize( 79, 79 )
end

function PANEL:Setup( NiceName, SpawnName, IconMaterial, AdminOnly, Cost, AmmoCost, Model )
	self.Title:SetText( NiceName )
	if Cost then self.Cost:SetText( "Cost: " .. Cost ) end
	if AmmoCost then self.AmmoCost:SetText( "Ammo Cost: " .. AmmoCost ) end
	
	if Cost then
		self.DoClick = function() RunConsoleCommand( "fac_buy", SpawnName ) end
		self.DoRightClick = function() RunConsoleCommand( "fac_buy", SpawnName ) end
	else
		self.DoClick = function() RunConsoleCommand( "gm_giveswep", SpawnName ) end
		self.DoRightClick = function() RunConsoleCommand( "gm_spawnswep", SpawnName ) end
	end
	
	if ( not IconMaterial ) then
		IconMaterial = "VGUI/entities/"..SpawnName
	end
	
	if not Model and not file.Exists( "materials/" .. IconMaterial .. ".vmt", "GAME" ) then
		local tbl = weapons.Get( SpawnName )
		
		if type(tbl) == "table" then
			Model = tbl.WorldModel
		end
	end
	
	if Model then
		self.Image = vgui.Create( "ModelImage", self )
		self.Image:SetMouseInputEnabled( false )
		self.Image:SetKeyboardInputEnabled( false )
		self.Image:SetModel( Model )
		self.ModelImage = true
	else
		self.Image = vgui.Create( "DImage", self )
		self.Image:SetImage( IconMaterial )
		self.Image:SizeToContents()
	end
	
	if ( AdminOnly ) then
		self:CreateAdminIcon()
	end
	
	self:InvalidateLayout()
end

vgui.Register( "fac_WeaponButton", PANEL, "DButton" )
