-- This file was created by echo - http://www.garrysmod.org/downloads/?a=view&id=65402 (link might be dead by the time someone reads this)
-- Credit and thanks for its creation goes to echo.
-- SB Gravity Mod 0.5a
-- Further Adjustments by philxyz and SnakeSVx

local envs = {}
local entities = ents.FindByClass( "logic_case" )
for _, ent in ipairs( entities ) do
	local values = ent:GetKeyValues()
	for key, value in pairs(values) do
		if key == "Case01" then
			if value == "planet" then
					local radius
					for key2, value2 in pairs(values) do
						if (key2 == "Case02") then radius = tonumber(value2) end
					end
					table.insert(envs, {['ent'] = ent, ['rad'] = radius})
			end
		end 
	end
end
						
CreateConVar( "sb_gravmul", "0.0024", FCVAR_NOTIFY )
CreateConVar( "sb_rad", 4000, FCVAR_NOTIFY )
CreateConVar( "sb_updatera", "0.1", FCVAR_NOTIFY )
CreateConVar( "sb_affectnoclip", "0", FCVAR_NOTIFY )
CreateConVar( "sb_disablegrav", "1", FCVAR_NOTIFY )


--Added Revision v1.1
--This function is internal and has no error checks, careful...
local function doPush(Entity, Gravity, posTocenter, totalRad, nonaffectRadius, affectPlayers, affectNoclipped)

	--Perform checks, make sure we are in the desired environment to continue
	--if not Entity:IsValid() or not Entity:GetPhysicsObject():IsValid() or Entity:GetPhysicsObject():IsAsleep() --[[Is it frozen?]] then return end --Don't do anything
	if Entity:IsPlayer() and not affectPlayers then return end --allowed to touch players?
	if (Entity:GetMoveType() == MOVETYPE_NOCLIP) and not affectNoclipped then return end --allowed to touch noclipped?
	
	local entityPos 		= Entity:GetPos()
	local totalDistance		= entityPos:Distance( posTocenter )
	local estimatedForceMul	= (Gravity * (1 - ((totalDistance - nonaffectRadius) / totalRad))) --Beta distance gravity decay

	if Entity:IsPlayer() then
		--Msg("Mul: " .. estimatedForceMul .. "\n")
		--Msg("Mul %: " .. (1 - ((totalDistance - nonaffectRadius) / totalRad)) .. "\n")
		local forceVector = (posTocenter - entityPos) * estimatedForceMul
		Entity:SetVelocity( forceVector )
	else
		local physObj = Entity:GetPhysicsObject()
		local parentPhysObj, mass = physObj, physObj:GetMass()
		for _, child in pairs(Entity:GetChildren()) do
			physObj = child:GetPhysicsObject()
			if IsValid(physObj) then
				mass = mass + physObj:GetMass()
			end
		end
		local forceVector = (posTocenter - entityPos) * (mass * estimatedForceMul)
		parentPhysObj:ApplyForceCenter(forceVector)
	end
	
end

local nextUpdate = 0

local function performUpdate()

	local nextUpdateInterval = tonumber(GetConVarNumber("sb_updatera"))

	local ct = CurTime()

	if ct > nextUpdate then
		--print(tostring(ct))
		local Gravity 		= tonumber(GetConVarNumber("sb_gravmul"))
		local affectRadius 	= tonumber(GetConVarNumber("sb_rad"))
		local touchNoclip 	= tonumber(GetConVarNumber("sb_affectnoclip")) == 1
		local disableGravity = tonumber(GetConVarNumber("sb_disablegrav")) == 1
		local entList = ents.GetAll( )
		
		--Temporarly disabled...
		
		local cents = {}
		--local over = false
		--local orbitEnts = ents.FindByClass( "orbit" )
		-- We don't use the orbit sent in factions

	
		
		for _, ent in ipairs( entList ) do
			if not IsValid(ent) 
				or not ent:GetPhysicsObject():IsValid() 
				or ent:GetPhysicsObject():IsAsleep()
				or IsValid(ent:GetParent()) then
				-- Do nothing
			else
				if ent.defgrav then
					ent:SetGravity(1)
					local phys = ent:GetPhysicsObject()
					phys:EnableGravity( true )
					phys:EnableDrag( true )
					ent.defgrav = false
				end
				local entityPos = ent:GetPos()
				--SB3 compatibility, Thanks Snake for the help!
				--Latest SVN recommended for this to work.
				if GAMEMODE.FindClosestPlanet then
					local nearplanet = GAMEMODE:FindClosestPlanet(entityPos, true) 
					local envPos = nearplanet:GetPos()
					local ig = nearplanet:GetSize()
					if (entityPos:Distance(envPos) > ig) and (entityPos:Distance(envPos) < (ig + affectRadius)) then
						doPush(ent, Gravity * nearplanet:GetGravity(), envPos, affectRadius, ig, true, touchNoclip)
					end
				--Otherwise SB2
				elseif (InSpace == 1) and SB_OnEnvironment then
					local inEnv, envNum = SB_OnEnvironment(entityPos, ent.num, affectRadius, ent.IgnoreClasses)
					local valid, planet, envPos , ig, planetGrav = SB_Get_Environment_Info(envNum)
					if valid and planet then
						if (entityPos:Distance(envPos) > ig) and (entityPos:Distance(envPos) < (ig + affectRadius)) then
							doPush(ent, Gravity * planetGrav, envPos, affectRadius, ig, true, touchNoclip)
						end
					end
				--No spacebuild found
				else
					for _, v in pairs(envs) do
						local environPos = v.ent:GetPos()
						local totalDistance = entityPos:Distance(environPos)
						if (totalDistance > v.rad) and (totalDistance < (v.rad + affectRadius)) then
							if disableGravity then
								ent.defgrav = true
								ent:SetGravity(0.00001)
								local phys = ent:GetPhysicsObject()
								phys:EnableGravity( false )
								phys:EnableDrag( false )								
							end
							doPush(ent, Gravity * 0.5, environPos, affectRadius, v.rad, true, touchNoclip)
						end
					end
				end
			end
		end

		nextUpdate = CurTime() + nextUpdateInterval
	end
end

if CAF == nil or CAF.GetAddon("Spacebuild").GetVersion() < 4 then
	hook.Add("Think", "Gravity_Push", performUpdate)
end
