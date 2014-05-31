------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------
--modifications to the spawn menu to fit our needs. I wish there was a better way to do these, but there isnt.

--add the cost of the stool to the stools list
local done = {}
Factions.spawnmenu_GetToolMenu = spawnmenu.GetToolMenu
function spawnmenu.GetToolMenu( name )
	local tbl = Factions.spawnmenu_GetToolMenu( name )

	for _,a in pairs(tbl) do
		if type(a) == "table" then
			for _,b in pairs(a) do
				if type(b) == "table" and b.ItemName and not done[b.ItemName] then
					local cost, arg2, arg3 = Factions.GetStoolCost(b.ItemName)
					
					if not cost and arg2 and arg3 then arg2( unpack( arg3 ) ); return tbl end
						
					if cost and cost ~= 0 then b.Text = b.Text .. " - $" .. cost end
					
					done[b.ItemName] = true --we only want to append our text to the name once
				end
			end
		end
	end
	
	return tbl
end
--[[
Factions.weapons_Get = weapons.Get
function weapons.Get( name )
	local wep = Factions.weapons_Get( name )

	if ( wep.Spawnable || wep.AdminSpawnable ) then
		if !Factions.Config.AllowSpawnmenuSWEPS then
			local exception
			for k,v in pairs(Factions.Config.AllowedSWEPS) do
				if v == wep.PrintName or v == wep.ClassName then
					exception = true
					break
				end
			end
				
			if not exception then
				wep.AdminSpawnable = Factions.Config.AllowAdminSWEPSpawn
				wep.Spawnable = false
			end
		end
	end
	
	return wep
end
--]]

--My lousy attempt to add costs to multistools (stools that spawn more than one type of entity)
--[[
Factions.Overrides.spawnmenu_AddToolMenuOption = spawnmenu.AddToolMenuOption
function spawnmenu.AddToolMenuOption( tab, category, itemname, text, command, controls, cpanelfunction, TheTable ) -- add cost texts to multistool
	--if str != "ComboBox" then return tbl end

	for mode,_ in pairs(tbl.Options) do
		for _, tbl2 in pairs(Factions.Stools) do
			if type(tbl2) == "table" then
				for m,tbl3 in pairs(tbl2) do
					if string.gsub(mode,"#","") == m then
						if tbl3.cost then
							mode = mode .. " - $" .. tbl3.cost
						end
					else
						fac_Msg("mode = " .. tostring(itemname))
					end
				end
			end
		end
	end

	return Factions.Overrides.spawnmenu_AddToolMenuOption( tab, category, itemname, text, command, controls, cpanelfunction, TheTable )
end
--]]
