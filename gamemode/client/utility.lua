------------------------------------------
--    Factions
-- Team Ring-Ding
------------------------------------------

local storeTemp = ""
function Factions.UmsgLargeHook(umsg)
	local k = umsg:ReadString() --usermessages are picky regaurding order
	local piece = umsg:ReadString()
	local last = umsg:ReadBool()

	storeTemp = storeTemp .. piece
	
	if last then
		fac_Msg( "Finished recieving '" ..k.. "' (len " ..string.len(storeTemp).. ") from server." )
		
		storeTemp = util.KeyValuesToTable( storeTemp )
		
		if ( Factions.UmsgLargeHooks[ k ] ) then --call the handler function, else print warning
			Factions.UmsgLargeHooks[ k ].Function( storeTemp )
		else Msg("Warning: Unhandled large usermessage '"..k.."'\n")
		end
		
		storeTemp = ""
	end
end
usermessage.Hook("Factions LargeUmsg", Factions.UmsgLargeHook)

Factions.UmsgLargeHooks = {}
function usermessage.HookLarge( key, func ) --handy for sending tables and or large volumes of information
	Factions.UmsgLargeHooks[ key ] = {}
	Factions.UmsgLargeHooks[ key ].Function = func
end

function Factions.IsOdd( num )
	return (num % 2 == 0)
end

Factions.NWVars = {}
function Factions.GetNWVar( index, default )
	return Factions.NWVars[index] or default
end

function Factions.GetStoolCost( mode, ply, stool, trace, leftclick, rightclick )
	local cost
	local costCharge
	local adminNotify
	
	local etype = "NOTIFY_ERROR"
	if ply and ply:IsAdmin() then etype = "NOTIFY_GENERIC" end

	if ply and mode == "adv_duplicator" then
		--special rules
		
		local advDup = stool:GetTable().Tool.adv_duplicator
		--grab the advDup table
		
		if not advDup.Entities or advDup:GetPasting() or not leftclick then return end --not gonna spawn anything
		
		cost  = Factions.GetEntitiesCost( advDup.Entities )
		costCharge = Factions.GetEntitiesCost( advDup.Entities, true )
		
	elseif ply and mode == "duplicator" then
		local ents = ply:UniqueIDTable( "Duplicator" ).Entities --grab entities duplicator wants to paste
		
		if not ents or not leftclick then return end --not gonna spawn anything
	
		cost  = Factions.GetEntitiesCost( ents )
		costCharge = Factions.GetEntitiesCost( ents, true )
	else
		--run through our stools table generated at GM:IntPostEntity
		if not Factions.Stools then
			return false, fac_Error, { "Factions Stools file not loaded correctly." }
		end
		
		for m, tbl in pairs(Factions.Stools) do
			if m == mode then --we found our match
				local classname = m --the classname of the entity this stool is going to spawn
			
				if ply and tbl.type then --is it a combination stool?
					local found = false
					for typ, tbl2 in pairs(tbl.type) do
						if tbl.type.var and tbl.type.var ~= "" then
							local info = ply:GetInfo( mode .."_" .. tbl.type.var )
							if info == typ then
								tbl = tbl2
								classname = typ
								found = true
								break
							end
						end
					end
					if not found and tbl.type.var and table.type.var ~= "" then
						return false, fac_Msg, { "var found in " .. mode .. ".type but unable to find a matching type for " .. tostring(ply:GetInfo( mode .."_" .. tbl.type.var )) .. ". Error will occur as a result unless a default cost is set." }
					end
				end
				
				if tbl.classname then
					classname = tbl.classname
				end
				
				if ply and tbl.restricted == "1" then --restricted?
					if ply:IsAdmin() then
						adminNotify = "You are using a restricted stool, admin."
					else
						return false, Factions.Notify, { ply, "That Tool Is Restricted.", etype }
					end
				end
				
				if ply and type(tbl.restrictions) == "table" then --within acceptable values?
					for restrict,Tbl in pairs(tbl.restrictions) do
						if type(Tbl) == "table" and type(restrict) == "string" then
							local info = ply:GetInfo( mode .."_" .. restrict )
							if info and tonumber(info) then
								if Tbl.max and tonumber(Tbl.max) then
									if tonumber(info) > tonumber(Tbl.max) then
										adminNotify = "Your " .. mode .. " exceeds the maximum " .. restrict .. " allowed. (" ..Tbl.max.. ")"
										if not ply:IsAdmin() then return false, Factions.Notify, { ply, "Your " .. mode .. " exceeds the maximum " .. restrict .. " allowed. (" ..Tbl.max.. ")", etype } end
									end
								end
								if Tbl.min and tonumber(Tbl.min) then
									if tonumber(info) < tonumber(Tbl.min) then
										adminNotify = "Your " .. mode .. " is below the minumum " .. restrict .. " allowed. (" ..Tbl.min.. ")"
										if not ply:IsAdmin() then return false, Factions.Notify, { ply, "Your " .. mode .. " is below the minumum " .. restrict .. " allowed. (" ..Tbl.min.. ")", etype } end
									end
								end
							else
								return false, fac_Error, { "Found restriction and restrictions table for " .. mode .. ", but GetInfo(" .. mode .."_" .. restrict .. ") returned nil or could not be converted to a number(info = " ..tostring(info).. ")! Are you sure that you are using the lastest versions of Factions and " .. mode .. "?" }
							end
						end
					end
				end
				
				if tbl.leftcost and leftclick then --different costs for right and left clicks?
					cost = tonumber(tbl.leftcost)
				elseif tbl.rightcost and rightclick then
					cost = tonumber(tbl.rightcost)
				else
					cost = tonumber(tbl.cost)
				end
				
				if trace and tbl.tracecost then --some stools upgrade an existing entity if they shoot one. check to see if this is the case
					if trace.Entity and trace.Entity:IsValid() and (trace.Entity:GetClass() == classname or trace.Entity:GetClass() == "gmod_" .. classname) then
						cost = tonumber(tbl.tracecost)
					end
				end
				
				break
			end
		end
	end
	
	return cost, costCharge, adminNotify
end
--[[
spawnmenu.OldGetTools = spawnmenu.GetTools --not my proudest moment, but fuck it. We're a custom gamemode, we do what we want
function spawnmenu.GetTools()
	local tools = spawnmenu.OldGetTools()
	if type(tools) != "table" then error("[FAC] Sandbox spawnmenu changed from expected") end

	for _,tbl1 in pairs(tools) do
		if type(tbl1) != "table" then error("[FAC] Sandbox spawnmenu changed from expected")
		else
			for _,tbl2 in pairs(tbl1) do
				if type(tbl2) != "table" then error("[FAC] Sandbox spawnmenu changed from expected")
				else
					for _,tbl3 in pairs(tbl2) do
						if type(tbl3) != "table" then error("[FAC] Sandbox spawnmenu changed from expected")
						else
							for k,v in pairs(tbl3) do
								if k == "ItemName" && fac_var.fac_Stools then
									local found
									for m,tbl in pairs(fac_var.fac_Stools) do
										if v == m then
											--if tbl.type then --is it a combination stool?
											--	local found = false
											--	for typ, tbl2 in pairs(tbl.type) do
											--		if tbl.type.var && tbl.type.var != "" then
											--			local info = ply:GetInfo( mode .."_" .. tbl.type.var )
											--			if info == typ then
											--				tbl = tbl2
											--				classname = typ
											--				found = true
											--				break
											--			end
											--		end
											--	end
											--	if !found && tbl.type.var && table.type.var != "" then
											--		fac_Msg("var found in " .. mode .. ".type but unable to find a matching type for " .. tostring(ply:GetInfo( mode .."_" .. tbl.type.var )) .. ". Error will occur as a result unless a default cost is set.")
											--	end
											--end
											
											if tbl.rightcost then cost = tonumber(tbl.rightcost)
											elseif tbl.leftcost then cost = tonumber(tbl.leftcost)
											else cost = tonumber(tbl.cost) end
											
											if type(cost) == "number" then
												if tbl.restricted != "1" then
													fac_Msg("new name: " ..tbl3[k].. " - $".. cost)
													--tbl3[k] = tbl3[k] .. cost
												else
													fac_Msg("new name: " ..tbl3[k].. " - admin only")
												end
											else fac_Error("unable to convert cost into a number for " .. mode .. " from data/globalrp/stools.txt.") end
											found = true
											break
										end
									end
									if !found then
										fac_Msg("Unable to find a cost for: " .. v)
									end
									break
								end
							end
						end
					end
				end
			end
		end
	end
	--for k,v in pairs(fac_var.fac_Stools) do
	--	
	--end

	return tools
end
--]]
