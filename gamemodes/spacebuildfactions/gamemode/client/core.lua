------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local time1 = 0
local function Client_Think()
	-- SB2
	if not GAMEMODE.GetPlanets then
                if GetGlobalInt("InSpace") == 0 then return end
        end
	-- End SB2 Code

	-- SB2 and SB3
	if time1 > CurTime() then return end
        GAMEMODE:Space_Affect_Cl()
        time1 = CurTime() + 0.5
	-- End of SB code
end
hook.Add("Think", "Factions Client Think", Client_Think)

function Factions.AdminMenu( PANEL )
	PANEL:ClearControls()
	PANEL:AddControl( "Header", {Label = "Admin Menu"})

	if not LocalPlayer():IsAdmin() then
		PANEL:AddControl("Label", { Label = "You are not an admin.", Text = "You are not an admin." })
		return
	end
	
	PANEL:AddControl("Label", { Label = "Damage:", Text = "Damage:" })
	local gui = {}
	gui.MenuButton = 0
	gui.Label = "Damage Options"
	gui.Options = {}
	gui.Options["All Damage To Players and Props Disabled (Global Godmode)"] = {fac_dmg = DMG_GODMODE}
	gui.Options["Players Cannot Damage Eachother (Or Their Props)"] = {fac_dmg = DMG_PLYOFF}
	gui.Options["Allow All Damage"] = {fac_dmg = DMG_ALL}
	PANEL:AddControl("ComboBox", gui)
	
	PANEL:AddControl("Label", { Label = "Mode:", Text = "Mode:" })
	gui = {}
	gui.Label = "Play Mode"
	gui.MenuButton = 0
	gui.Options = {}
	gui.Options["Free"] = {fac_mode = "Free"}
	gui.Options["War"] = {fac_mode = "War"}
	PANEL:AddControl("ComboBox", gui)
	
	Factions.Make2OpCombo( PANEL, "Friendly Fire", "fac_ff" )
	Factions.Make2OpCombo( PANEL, "Fragile Props", "fac_fragileprops" )
	Factions.Make2OpCombo( PANEL, "Auto Team Balance", "fac_autoteambalance" )
	Factions.Make2OpCombo( PANEL, "Auto-Spawn NPCS", "fac_autospawnnpcs" )
	
	PANEL:AddControl( "Button", { Text = "Spawn NPCS", Command = "fac_spawnnpcs" } )
	PANEL:AddControl( "Button", { Text = "Remove NPCS", Command = "fac_removenpcs" } )
end
local function HookinAdminMenu()
	spawnmenu.AddToolMenuOption( "Utilities", "Admin", "Factions Admin Menu", "Factions Admin Menu", "", "", Factions.AdminMenu )
end
hook.Add( "PopulateToolMenu", "[FAC] HookinFactionsAdminMenu", HookinAdminMenu )
function Factions.Make2OpCombo( PANEL, label, cmd )
	PANEL:AddControl("Label", { Label = label, Text = label })
	local gui = {}
	gui.MenuButton = 0
	gui.Label = label
	gui.Options = {}
	gui.Options["Enabled"] = {[cmd] = 1}
	gui.Options["Disabled"] = {[cmd] = 0}
	PANEL:AddControl("ComboBox", gui)
end
