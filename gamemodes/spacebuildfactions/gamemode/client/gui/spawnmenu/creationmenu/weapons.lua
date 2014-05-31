surface.CreateFont( "Header", {
	font = "middages",
	size = 30,
	weight = 700,
	antialias = true,
	shadow = false
})

local PANEL = {}

function PANEL:Init()
	
	self.PanelList = vgui.Create( "DPanelList", self )	
		self.PanelList:SetPadding( 4 )
		self.PanelList:SetSpacing( 2 )
		self.PanelList:EnableVerticalScrollbar( true )
		
	self:BuildList()
	
end

function PANEL:BuildList()
	
	self.PanelList:Clear()
	
	-- Get weapons
	local Weapons = weapons.GetList()
	local Categorised = {}
	
	-- Build into categories
	for k, weapon in pairs( Weapons ) do
	
		-- We need to get a real copy of the weapon table so that
		-- all of the inheritence shit will be taken into consideration
		weapon = weapons.Get( weapon.ClassName )
		Weapons[ k ] = weapon
		weapon.Category = weapon.Category or "Other"

		--sometimes we ignore whether the weapon wants to be spawnable or not
			if ( weapon.Spawnable or weapon.AdminSpawnable ) then
				if not Factions.Config.AllowSpawnmenuSWEPS then
					local exception
					for k,v in pairs(Factions.Config.AllowedSWEPS) do
						if v == weapon.Name or v == weapon.ClassName then
							exception = true
							break
						end
					end
					
					if not exception then
						weapon.AdminSpawnable = Factions.Config.AllowAdminSWEPSpawn
						weapon.Spawnable = false
					end
				end
			end
		---------

		-- Only show it if we or an admin can spawn it
		if ( not weapon.Spawnable and not weapon.AdminSpawnable ) then
		
			Weapons[ k ] = nil
		
		else
		
			Categorised[ weapon.Category ] = Categorised[ weapon.Category ] or {}
			Categorised[ weapon.Category ].order = "z"
			table.insert( Categorised[ weapon.Category ], weapon )
			Weapons[ k ] = nil
			
		end
	
	end
	
	Weapons = nil
	
	--Add our weapons
		local tick = 0
		for category,tbl in pairs( Factions.Config.Weapons ) do
			Categorised[category] = tbl
			Categorised[category].Spawnable = true
			
			tick = tick + 1
		end
	--------
	
	-- Loop through each category
	for CategoryName, v in SortedPairsByMemberValue( Categorised, "order" ) do
	
		local Category = vgui.Create( "DCollapsibleCategory", self )
		self.PanelList:AddItem( Category )
		Category:SetLabel( CategoryName )
		Category:SetCookieName( "WeaponSpawn."..CategoryName )
		
		local Content = vgui.Create( "DPanelList" )
		Category:SetContents( Content )
		Content:EnableHorizontal( true )
		Content:SetDrawBackground( false )
		Content:SetSpacing( 0 )
		Content:SetPadding( 0 )
		Content:SetAutoSize( true )
		
		for k, WeaponTable in pairs( v ) do
			if type(WeaponTable) == "table" then
				local Icon = vgui.Create( "fac_WeaponButton", self )
				
				Icon:Setup( WeaponTable.Name or WeaponTable.ClassName, WeaponTable.ClassName, WeaponTable.SpawnMenuIcon, WeaponTable.AdminSpawnable and not WeaponTable.Spawnable, WeaponTable.Cost, WeaponTable.AmmoCost, WeaponTable.Model )
						
				Content:AddItem( Icon )
			end
		end
	
	end
	
	self.PanelList:InvalidateLayout()
	
end

function PANEL:PerformLayout()

	self.PanelList:StretchToParent( 0, 0, 0, 0 )

end


local CreationSheet = vgui.RegisterTable( PANEL, "Panel" )

local function CreateContentPanel()

	local ctrl = vgui.CreateFromTable( CreationSheet )
	return ctrl

end

spawnmenu.AddCreationTab( "Weapons", CreateContentPanel, "gui/silkicons/bomb", 30 )
