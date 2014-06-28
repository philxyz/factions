function GM:Register_Sun()
	local suns = ents.FindByClass( "env_sun" )


	for _, ent in ipairs( suns ) do

		if ent:IsValid() then

			local values = ent:GetKeyValues()

			for key, value in pairs(values) do

				if ((key == "target") and (string.len(value) > 0)) then
					local targets = ents.FindByName( "sun_target" )
					for _, target in pairs( targets ) do
						if SunAngle == nil then
							local tpos = target:GetPos()
							local en = ent:GetPos()
							TrueSun = en

							local mid = (tpos - en);
							SunAngle = mid:GetNormalized()
						end
						return -- SunAngle set, all that was needed
					end
				end
			end
			-- SunAngle still not set, but sun found
		    local ang = ent:GetAngles()
			ang.p = ang.p - 180
			ang.y = ang.y - 180
		    --get within acceptable angle values no matter what...
			ang.p = math.NormalizeAngle( ang.p )
			ang.y = math.NormalizeAngle( ang.y )
			ang.r = math.NormalizeAngle( ang.r )
			SunAngle = ang:Forward()

			return
		end
	end
	-- no sun found, so just set a default angle
	if not SunAngle then
		SunAngle = Vector(0,0,-1)
	end	
end

function GM:AddSentsToList()
	local SEntList = scripted_ents.GetList()
	for _, item in pairs( SEntList ) do
		local name =  item.t.ClassName
		local found = 0
		for _, check in pairs( self.affected ) do
			if ( check == name ) then
				found = 1
				break
			end
		end
		if ( found == 0 ) then table.insert(self.affected, name) end
	end
end

function GM:Register_Environments()
	local Blooms = {}
	local Colors = {}
	local Planets = {}
	-- Load the planets/stars/bloom/color
	local entities = ents.FindByClass( "logic_case" )
	for _, ent in ipairs( entities ) do
		local values = ent:GetKeyValues()
		for key, value in pairs(values) do
   			if key == "Case01" then
				if value == "star" then 
					local radius
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then radius = tonumber(value2) end
					end
					local num =  SB_Add_Environment(ent, radius, 0, 0, 0, 100000, 100000, 0, 1, true, nil, nil)
					-- Msg("Registered Outside Star = "..tostring(num).."\n")
					num = SB_Add_Environment(ent, radius/2, 0, 0, 0, 300000, 300000, 0, 1, true, nil, nil)
					-- Msg("Registered Middle Star = "..tostring(num).."\n")
					num = SB_Add_Environment(ent, radius/3, 0, 0, 0, 500000, 500000, 0, 1, true, nil, nil)
					-- Msg("Registered Core Star = "..tostring(num).."\n")
					TrueSun = ent:GetPos()
					local hash = {}
					hash.radius = radius
					hash.num = num
					hash.pos = ent:GetPos()
					if RES_DISTRIB and RES_DISTRIB == 2 then
						BeamNetVars.SB2UpdateStar( hash )
					end
				elseif value == "planet" then
					InSpace = 1
					SetGlobalInt("InSpace", 1)
					if not TrueSun or not (ent:GetPos() == TrueSun) then
						local radius
						local gravity
						local atmosphere
						local stemperature
						local ltemperature
						local ColorID
						local BloomID
						local unstable
						local habitat
						local sunburn
						for key2, value2 in pairs(values) do
							if (key2 == "Case02") then radius = tonumber(value2) end
							if (key2 == "Case03") then gravity = tonumber(value2) end
							if (key2 == "Case04") then atmosphere = tonumber(value2) end
							if (key2 == "Case05") then stemperature = tonumber(value2) end
							if (key2 == "Case06") then ltemperature = tonumber(value2) end
							if (key2 == "Case07") then
								if (string.len(value2) > 0) then
									ColorID = value2
								end
							end
							if (key2 == "Case08") then
								if (string.len(value2) > 0) then
									BloomID = value2
								end
							end
							if (key2 == "Case16") then habitat, unstable, sunburn = SB_CalculateHabUnStSun(tonumber(value2)) end
						end
						local num = SB_Add_Environment(ent, radius, gravity, habitat, atmosphere, ltemperature, stemperature, unstable, sunburn, true, nil, nil)
						-- Msg("Registered Planet = "..tostring(num).."\n")
						if num then
							Planets[num] = {}
							Planets[num].ColorID = ColorID
							Planets[num].BloomID = BloomID
						end
					--else
						-- Msg("Not registering planet => Same location as a star!\n")
					end
				elseif value == "planet_color" then
					local AddColor_r
					local AddColor_g
					local AddColor_b
					local MulColor_r
					local MulColor_g
					local MulColor_b
					local Brightness
					local Contrast
					local Color
					local ColorID
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then
							AddColor_r = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							AddColor_g = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							AddColor_b = tonumber(value2)
						end
						if (key2 == "Case03") then
							MulColor_r = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							MulColor_g = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							MulColor_b = tonumber(value2)
						end
						if (key2 == "Case04") then Brightness = tonumber(value2) end
						if (key2 == "Case05") then Contrast = tonumber(value2) end
						if (key2 == "Case06") then Color = tonumber(value2) end
						if (key2 == "Case16") then ColorID = value2 end
					end
					Colors[ColorID] = SB_Color(ent, AddColor_r, AddColor_g, AddColor_b, MulColor_r, MulColor_g, MulColor_b, Brightness, Contrast, Color)
				elseif value == "planet_bloom" then
					local Col_r
					local Col_g
					local Col_b
					local SizeX
					local SizeY 
					local Passes
					local Darken
					local Multiply
					local Color
					local BloomID
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then
							Col_r = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							Col_g = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							Col_b = tonumber(value2)
						end
						if (key2 == "Case03") then
							SizeX = tonumber(string.Left(value2, string.find(value2," ") - 1))
							value2 = string.Right(value2, (string.len(value2) - string.find(value2," ")))
							SizeY = tonumber(value2)
						end
						if (key2 == "Case04") then Passes = tonumber(value2) end
						if (key2 == "Case05") then Darken = tonumber(value2) end
						if (key2 == "Case06") then Multiply = tonumber(value2) end
						if (key2 == "Case07") then Color = tonumber(value2) end
						if (key2 == "Case16") then BloomID = value2 end
					end
					Blooms[BloomID] = SB_Bloom(ent, Col_r, Col_g, Col_b, SizeX, SizeY, Passes, Darken, Multiply, Color)
				end
			end
		end
	end
	for num, p in pairs( Planets ) do
		local color
		local bloom
		if (Colors[p.ColorID]) then color = Colors[p.ColorID] end
		if (Blooms[p.BloomID]) then bloom = Blooms[p.BloomID] end
		if color or bloom then
			if not SB_Update_Environment(num, nil, nil, nil, nil, nil, nil, nil, nil, true, bloom, color) then
				Msg("Update failed!\n")
			else
				Msg("Update Succesfull!\n")
			end
		end
	end
	Msg ( "Registered " .. table.Count(Planets) .. " planets\n" )
	BackupPlanetData = table.Copy(Planets)
	Msg ("Created backup value table.")
end
BackupPlanetData = {}
