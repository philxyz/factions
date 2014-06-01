------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

swepmenu = nil
local PANEL = {}
local bg = surface.GetTextureID( "gui/swepmenu/base" )
local gunstable = {}
surface.CreateFont( "Header", {
	font = "middages",
	size = 30,
	weight = 700,
	antialias = true,
	shadow = true
})
local page

function PANEL:Init()
	gui.EnableScreenClicker( true )

	self.Tools = {}
		self.Tools.Physgun = vgui.Create( "PurchaseButton", self )
		self.Tools.Physgun:SetGun( "weapon_physgun" )
		table.insert( gunstable, self.Tools.Physgun )
		
		self.Tools.Knife = vgui.Create( "PurchaseButton", self )
		self.Tools.Knife:SetGun( "weapon_knife" )
		table.insert( gunstable, self.Tools.Knife )
		
		self.Tools.Armor = vgui.Create( "PurchaseButton", self )
		self.Tools.Armor:SetGun( "ammo.armor" )
		table.insert( gunstable, self.Tools.Armor )
		
		self.Tools.MedPack = vgui.Create( "PurchaseButton", self )
		self.Tools.MedPack:SetGun( "ammo.medpack" )
		table.insert( gunstable, self.Tools.MedPack )
		
		self.Tools.Grenade = vgui.Create( "PurchaseButton", self )
		self.Tools.Grenade:SetGun( "ammo.grenade" )
		table.insert( gunstable, self.Tools.Grenade )
	
	self.Ammo = {}
		self.Ammo.Pistol = vgui.Create( "PurchaseButton", self )
		self.Ammo.Pistol:SetGun( "ammo.Pistol" )
		table.insert( gunstable, self.Ammo.Pistol)
		
		self.Ammo.Shotgun = vgui.Create( "PurchaseButton", self )
		self.Ammo.Shotgun:SetGun( "ammo.buckshot" )
		table.insert( gunstable, self.Ammo.Shotgun)
		
		self.Ammo.Primary = vgui.Create( "PurchaseButton", self )
		self.Ammo.Primary:SetGun( "ammo.smg1")
		table.insert( gunstable, self.Ammo.Primary)
		
		self.Ammo.Grenade = vgui.Create( "PurchaseButton", self )
		self.Ammo.Grenade:SetGun( "ammo.grenade")
		table.insert( gunstable, self.Ammo.Grenade)
	
	
	self.Pistols = {}
		self.Pistols.Deagle = vgui.Create( "PurchaseButton", self )
		self.Pistols.Deagle:SetGun("weapon_real_cs_desert_eagle")
		table.insert( gunstable, self.Pistols.Deagle)

		self.Pistols.FiveSeven = vgui.Create( "PurchaseButton", self )
		self.Pistols.FiveSeven:SetGun("weapon_real_cs_five-seven")
		table.insert( gunstable, self.Pistols.FiveSeven)

		self.Pistols.Glock = vgui.Create( "PurchaseButton", self )
		self.Pistols.Glock:SetGun("weapon_real_cs_glock18")
		table.insert( gunstable, self.Pistols.Glock)
	
	
	self.SMGS = {}
		self.SMGS.Mac10 = vgui.Create( "PurchaseButton", self )
		self.SMGS.Mac10:SetGun("weapon_real_cs_mac10")
		table.insert( gunstable, self.SMGS.Mac10)

		self.SMGS.MP5 = vgui.Create( "PurchaseButton", self )
		self.SMGS.MP5:SetGun("weapon_real_cs_mp5a5")
		table.insert( gunstable, self.SMGS.MP5)
		
		self.SMGS.TMP = vgui.Create( "PurchaseButton", self )
		self.SMGS.TMP:SetGun("weapon_real_cs_tmp")
		table.insert( gunstable, self.SMGS.TMP )
	
	
	self.Shotguns = {}
		self.Shotguns.Pump = vgui.Create( "PurchaseButton", self )
		self.Shotguns.Pump:SetGun("weapon_real_cs_pumpshotgun")
		table.insert( gunstable, self.Shotguns.Pump )
	
	
	self.Rifles = {}
		self.Rifles.AK47 = vgui.Create( "PurchaseButton", self )
		self.Rifles.AK47:SetGun("weapon_real_cs_ak47")
		table.insert( gunstable, self.Rifles.AK47 )

		self.Rifles.M4 = vgui.Create( "PurchaseButton", self )
		self.Rifles.M4:SetGun("weapon_real_cs_m4a1")
		table.insert( gunstable, self.Rifles.M4 )
	
	self.MachineGuns = {}
		self.MachineGuns.MachineGun = vgui.Create( "PurchaseButton", self )
		self.MachineGuns.MachineGun:SetGun("weapon_real_cs_m249")
		table.insert( gunstable, self.MachineGuns.MachineGun )
	
	
	--Page 1 Buttons
		self.Tools.Button = vgui.Create( "ButtonText", self )
		self.Tools.Button:SetText( "Equipment" )
		table.insert( gunstable, self.Tools.Button )
		
		self.Ammo.Button = vgui.Create( "ButtonText", self )
		self.Ammo.Button:SetText( "Ammunition" )
		table.insert( gunstable, self.Ammo.Button )
		
		self.Pistols.Button = vgui.Create( "ButtonText", self )
		self.Pistols.Button:SetText( "Pistols" )
		table.insert( gunstable, self.Pistols.Button )
		
		self.SMGS.Button = vgui.Create( "ButtonText", self )
		self.SMGS.Button:SetText("Sub Machine Guns")
		table.insert( gunstable, self.SMGS.Button )
		
		self.Shotguns.Button = vgui.Create( "ButtonText", self )
		self.Shotguns.Button:SetText("Shotguns")
		table.insert( gunstable, self.Shotguns.Button )
		
		self.Rifles.Button = vgui.Create( "ButtonText", self )
		self.Rifles.Button:SetText("Rifles")
		table.insert( gunstable, self.Rifles.Button )
		
		self.MachineGuns.Button = vgui.Create( "ButtonText", self )
		self.MachineGuns.Button:SetText("Machine Guns")
		table.insert( gunstable, self.MachineGuns.Button )
	
	self.ReturnButton = vgui.Create( "ButtonText", self )
	self.ReturnButton:SetText("Return")
	
	self.page = "Return"
	self.Ammo.HeaderText = {}
	self.Ammo.Pic = {}
	
	self:InvalidateLayout()
end

function PANEL:ButtonTextClick( page )
	self.page = page
	self:InvalidateLayout()
end

function PANEL:PerformLayout()
	if page then
		self.page = "Return"
		page = false
	end

	self:SetPos( ScrW() / 2 - 256, ScrH() / 2 - 256 )
	self:SetSize( 512, 512 )
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetFont( "Body" )
	
	w,h = surface.GetTextSize( "Return" )
	self.ReturnButton:SetSize( w + 6, h )
	self.ReturnButton:SetPos( 430 , 430 )
	
	local w,w2,h,h2
	
	for k, v in pairs(gunstable) do
		v:SetVisible( false )
	end
	
	if self.page == "Return" then
		local spacer = 13
		local y = 190
		
		self.Pistols.Button:SetVisible( true )
			self.Shotguns.Button:SetVisible( true )
			self.SMGS.Button:SetVisible( true )
			self.Rifles.Button:SetVisible( true )
			self.MachineGuns.Button:SetVisible( true )
			self.Tools.Button:SetVisible( true )
	
		w,h = surface.GetTextSize( self.Tools.Button:GetText() )
			self.Tools.Button:SetSize( w + 6, h )
			self.Tools.Button:SetPos( 256 - ( w / 2 ), y )
			y = h + spacer + y
	
		w,h = surface.GetTextSize( self.Pistols.Button:GetText() )
			self.Pistols.Button:SetSize( w + 6, h )
			self.Pistols.Button:SetPos( 256 - ( w / 2 ), y )
			y = h + spacer + y
		
		w,h = surface.GetTextSize( self.Shotguns.Button:GetText() )
			self.Shotguns.Button:SetSize( w + 6, h )
			self.Shotguns.Button:SetPos( 256 - ( w / 2 ), y )
			y = h + spacer + y
		
		w,h = surface.GetTextSize( self.SMGS.Button:GetText() )
			self.SMGS.Button:SetSize( w + 6, h )
			self.SMGS.Button:SetPos( 256 - ( w / 2 ), y )
			y = h + spacer + y
		
		w,h = surface.GetTextSize( self.Rifles.Button:GetText() )
			self.Rifles.Button:SetSize( w + 6, h )
			self.Rifles.Button:SetPos( 256 - ( w / 2 ), y )
			y = h + spacer + y
		
		w,h = surface.GetTextSize( self.MachineGuns.Button:GetText() )
			self.MachineGuns.Button:SetSize( w + 6, h )
			self.MachineGuns.Button:SetPos( 256 - ( w / 2 ), y )
			y = h + spacer + y
		
	elseif self.page == "Equipment" then
		self.Tools.Physgun:SetVisible( true )
				self.Tools.Knife:SetVisible( true )
				self.Tools.Armor:SetVisible( true )
				self.Tools.MedPack:SetVisible( true )
				self.Tools.Grenade:SetVisible( true )
	
		self.Tools.Physgun:SetSize( 128, 32 )
		self.Tools.Physgun:SetPos( 280, 190 )
	
		self.Tools.Knife:SetSize( 128, 32 )
		self.Tools.Knife:SetPos( 280, 225 )
		
		self.Tools.Armor:SetSize( 128, 32 )
		self.Tools.Armor:SetPos( 280, 260 )
		
		self.Tools.MedPack:SetSize( 128, 32 )
		self.Tools.MedPack:SetPos( 280, 295 )
		
		self.Tools.Grenade:SetSize( 128, 32 )
		self.Tools.Grenade:SetPos( 280, 330 )
		
	elseif self.page == "Ammunition" then
		self.Ammo.Pistol:SetVisible( true )
			self.Ammo.Shotgun:SetVisible( true )
			self.Ammo.Primary:SetVisible( true )
			self.Ammo.Grenade:SetVisible( true )
	
		self.Ammo.Pistol:SetSize( 128, 32 )
		self.Ammo.Pistol:SetPos( 280, 200 )
	
		self.Ammo.Shotgun:SetSize( 128, 32 )
		self.Ammo.Shotgun:SetPos( 280, 240 )
		
		self.Ammo.Primary:SetSize( 128, 32 )
		self.Ammo.Primary:SetPos( 280, 280 )
		
		self.Ammo.Grenade:SetSize( 128, 32 )
		self.Ammo.Grenade:SetPos( 280, 320 )
		
	elseif self.page == "Pistols" then
		self.Pistols.Glock:SetVisible( true )
			self.Pistols.FiveSeven:SetVisible( true )
			self.Pistols.Deagle:SetVisible( true )
	
		self.Pistols.Glock:SetSize( 128, 32 )
		self.Pistols.Glock:SetPos( 280, 200 )
		
		self.Pistols.FiveSeven:SetSize( 128, 32 )
		self.Pistols.FiveSeven:SetPos( 280, 240 )
		
		self.Pistols.Deagle:SetSize( 128, 32 )
		self.Pistols.Deagle:SetPos( 280, 280 )
	
	elseif self.page == "Shotguns" then
		self.Shotguns.Pump:SetVisible( true )
		
		self.Shotguns.Pump:SetSize( 128, 32 )
		self.Shotguns.Pump:SetPos( 280, 200 )
		
	elseif self.page == "Sub Machine Guns" then
		self.SMGS.Mac10:SetVisible( true )
			self.SMGS.TMP:SetVisible( true )
			self.SMGS.MP5:SetVisible( true )
		
		self.SMGS.Mac10:SetSize( 128, 32 )
		self.SMGS.Mac10:SetPos( 280, 200 )
		
		self.SMGS.TMP:SetSize( 128, 32 )
		self.SMGS.TMP:SetPos( 280, 240 )
		
		self.SMGS.MP5:SetSize( 128, 32 )
		self.SMGS.MP5:SetPos( 280, 280 )
		
	elseif self.page == "Rifles" then
		self.Rifles.AK47:SetVisible( true )
			self.Rifles.M4:SetVisible( true )
	
		self.Rifles.AK47:SetSize( 128, 32 )
		self.Rifles.AK47:SetPos( 280, 200 )
		
		self.Rifles.M4:SetSize( 128, 32 )
		self.Rifles.M4:SetPos( 280, 240 )
		
	elseif self.page == "Machine Guns" then
		self.MachineGuns.MachineGun:SetVisible( true )
	
		self.MachineGuns.MachineGun:SetSize( 128, 32 )
		self.MachineGuns.MachineGun:SetPos( 280, 200 )
		
	else
		fac_Debug("self.page not recognized")
		self.page = "Return"
		self:InvalidateLayout()
	end
end

function PANEL:Paint(x, y)
	local client = LocalPlayer()
	local gray = Color(255,255,255,255)
	local w,h
	
	surface.SetTextColor( 255, 255, 255, 255 )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.SetFont( "Body" )
	
	surface.SetTexture( bg )
	surface.SetDrawColor( 255, 255, 255, 255 )
	surface.DrawTexturedRect( 0, 0, 512, 512 )
	
	draw.SimpleText( "Current Money: $" ..LocalPlayer():GetNWInt("money"), "Body", 260, 400, gray,1,1)
	
	if self.page == "Return" then
		draw.SimpleText( "Purchase Your Weapons", "Header", 260, 165, gray,1,1)
		
	elseif self.page == "Equipment" then
		draw.SimpleText( self.page, "Header", 220, 155, gray,1,1)
		draw.SimpleText( "p", "SM_WeaponTitle", 335, 180, gray,1,1)
	
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Equipment.Physgun.Cost) .. " " .. Factions.Config.Weapons.Equipment.Physgun.Name, "Body", self.Tools.Physgun.x - 100, self.Tools.Physgun.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Equipment.Knife.Cost) .. " " .. Factions.Config.Weapons.Equipment.Knife.Name, "Body", self.Tools.Knife.x - 100, self.Tools.Knife.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Equipment.Armor.Cost) .. " " .. Factions.Config.Weapons.Equipment.Armor.Name, "Body", self.Tools.Armor.x - 100, self.Tools.Armor.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Equipment.Health.Cost) .. " " .. Factions.Config.Weapons.Equipment.Health.Name, "Body", self.Tools.MedPack.x - 100, self.Tools.MedPack.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Equipment.Grenade.Cost) .. " " .. Factions.Config.Weapons.Equipment.Grenade.Name, "Body", self.Tools.Grenade.x - 100, self.Tools.Grenade.y + 18, gray,1,1)
	
	elseif self.page == "Ammunition" then
		draw.SimpleText( self.page, "Header", 220, 155, gray,1,1)
		draw.SimpleText( "W", "SM_WeaponTitle", 330, 180, gray,1,1)
	
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Pistols.Ammo.Cost) .. " " .. Factions.Config.Weapons.Pistols.Ammo.Name, "Body", self.Ammo.Pistol.x - 100, self.Ammo.Pistol.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Shotguns.Ammo.Cost) .. " " .. Factions.Config.Weapons.Shotguns.Ammo.Name, "Body", self.Ammo.Shotgun.x - 100, self.Ammo.Shotgun.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.SMGs.Ammo.Cost) .. " " .. Factions.Config.Weapons.SMGs.Ammo.Name, "Body", self.Ammo.Primary.x - 100, self.Ammo.Primary.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Rifles.Ammo.Cost) .. " " .. Factions.Config.Weapons.Rifles.Ammo.Name, "Body", self.Ammo.Primary.x - 100, self.Ammo.Primary.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.MachineGuns.Ammo.Cost) .. " " .. Factions.Config.Weapons.MachineGuns.Ammo.Name, "Body", self.Ammo.Primary.x - 100, self.Ammo.Primary.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Equipment.Grenade.Cost) .. " " .. Factions.Config.Weapons.Equipment.Grenade.Name, "Body", self.Ammo.Grenade.x - 100, self.Ammo.Grenade.y + 18, gray,1,1)
		
	elseif self.page == "Pistols" then
		draw.SimpleText( self.page, "Header", 210, 155, gray,1,1)
		draw.SimpleText( "f", "SM_WeaponTitle", 320, 180, gray,1,1)
	
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Pistols.Glock.Cost) .. " " .. Factions.Config.Weapons.Pistols.Glock.Name, "Body", self.Pistols.Glock.x - 100, self.Pistols.Glock.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Pistols.FiveSeven.Cost) .. " " .. Factions.Config.Weapons.Pistols.FiveSeven.Name, "Body", self.Pistols.FiveSeven.x - 100, self.Pistols.FiveSeven.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Pistols.Deagle.Cost) .. " " .. Factions.Config.Weapons.Pistols.Deagle.Name, "Body", self.Pistols.Deagle.x - 100, self.Pistols.Deagle.y + 18, gray,1,1)
	elseif self.page == "Shotguns" then
		draw.SimpleText( self.page, "Header", 190, 155, gray,1,1)
		draw.SimpleText( "k", "SM_WeaponTitle", 330, 195, gray,1,1)
	
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Shotguns.Pump.Cost) .. " " .. Factions.Config.Weapons.Shotguns.Pump.Name, "Body", self.Shotguns.Pump.x - 100, self.Shotguns.Pump.y + 18, gray,1,1)
	elseif self.page == "Sub Machine Guns" then
		draw.SimpleText( self.page, "Header", 207, 155, gray,1,1)
		draw.SimpleText( "x", "SM_WeaponTitle", 385, 180, gray,1,1)
	
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.SMGs.Mac10.Cost) .. " " .. Factions.Config.Weapons.SMGs.Mac10.Name, "Body", self.SMGS.Mac10.x - 100, self.SMGS.Mac10.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.SMGs.TMP.Cost) .. " " .. Factions.Config.Weapons.SMGs.TMP.Name, "Body", self.SMGS.TMP.x - 100, self.SMGS.TMP.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.SMGs.MP5.Cost) .. " " .. Factions.Config.Weapons.SMGs.MP5.Name, "Body", self.SMGS.MP5.x - 100, self.SMGS.MP5.y + 18, gray,1,1)
		
	elseif self.page == "Rifles" then
		draw.SimpleText( self.page, "Header", 205, 155, gray,1,1)
		draw.SimpleText( "w", "SM_WeaponTitle", 325, 190, gray,1,1)
	
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Rifles.AK47.Cost) .. " " .. Factions.Config.Weapons.Rifles.AK47.Name, "Body", self.Rifles.AK47.x - 100, self.Rifles.AK47.y + 18, gray,1,1)
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.Rifles.M4A1.Cost) .. " " .. Factions.Config.Weapons.Rifles.M4A1.Name, "Body", self.Rifles.M4.x - 100, self.Rifles.M4.y + 18, gray,1,1)
		
	elseif self.page == "Machine Guns" then
		draw.SimpleText( self.page, "Header", 190, 155, gray,1,1)
		draw.SimpleText( "z", "SM_WeaponTitle", 365, 180, gray,1,1)
		
		draw.SimpleText( "$" .. tostring(Factions.Config.Weapons.MachineGuns.M249Para.Cost) .. " " .. Factions.Config.Weapons.MachineGuns.M249Para.Name, "Body", self.MachineGuns.MachineGun.x - 100, self.MachineGuns.MachineGun.y + 18, gray,1,1)
	end
end

function ShowSWEPMenu()
	if not swepmenu then
		swepmenu = vgui.Create( "FAC SWEP Menu" )
	end
	swepmenu:SetVisible( true )
	gui.EnableScreenClicker( true )
	swepmenu:InvalidateLayout()
end
usermessage.Hook("showswepmenu", ShowSWEPMenu)

function HideSWEPMenu( ply )
	swepmenu:SetVisible( false )
	gui.EnableScreenClicker( false )
	if LocalPlayer():GetNWBool( "f2" ) or LocalPlayer():GetNWBool( "showhelp" ) or LocalPlayer():GetNWBool( "showtrader" ) then
		gui.EnableScreenClicker( true )
	end
	page = true
end
usermessage.Hook("hideswepmenu", HideSWEPMenu)

vgui.Register("FAC SWEP Menu", PANEL, "Panel")

swepmenu = vgui.Create( "FAC SWEP Menu" )
swepmenu:SetVisible( false )
