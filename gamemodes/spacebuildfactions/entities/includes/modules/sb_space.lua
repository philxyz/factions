local setmetatable = setmetatable
local util = util
local Vector = Vector

module( "sb_space" )
local space = {}
space.__index = space
local obj = nil

function space:CheckAirValues()
end

function space:IsOnPlanet()
	return nil
end

function space:AddExtraAirResource(resource, start, ispercentage)
end

function space:PrintVars()
	Msg("No Values for Space\n")
end

function space:ConvertResource(res1, res2, amount)
	return 0
end

function space:GetEnvironmentName()
	return "Space"
end

function space:GetResourceAmount(res)
	return  0
end

function space:GetResourcePercentage(res)
	return 0
end

function space:SetEnvironmentName(value)
end

function space:Convert(air1, air2, value)
	return 0
end

function space:GetSize()
	return 0
end

function space:SetSize(size)
end

function space:GetGravity()
	return 0
end

function space:UpdatePressure(ent)
end

function space:GetO2Percentage()
	return 0
end

function space:GetCO2Percentage()
	return 0
end

function space:GetNPercentage()
	return 0
end

function space:GetHPercentage()
	return 0
end

function space:GetEmptyAirPercentage()
	return 0
end

function space:UpdateGravity(ent)
	if not ent then return end
	local phys = ent:GetPhysicsObject()
	if not phys:IsValid() then return end
	local trace = {}
	local pos = ent:GetPos()
	trace.start = pos
	trace.endpos = pos - Vector(0,0,512)
	trace.filter = { ent }
	local tr = util.TraceLine( trace )
	if (tr.Hit) then
		if (tr.Entity.grav_plate == 1) then
			ent:SetGravity(1)
			ent.gravity = 1
			phys:EnableGravity( true )
			phys:EnableDrag( true )
			return
		end
	end
	if ent.gravity and  ent.gravity == 0 then 
		return 
	end
	phys:EnableGravity( false )
	phys:EnableDrag( false )
	ent:SetGravity(0.00001)
	ent.gravity = 0
end

function space:GetPriority()
	return 0
end

function space:GetAtmosphere()
	return 0
end

function space:GetPressure()
	return 0
end

function space:GetTemperature()
	return 14
end

function space:GetEmptyAir()
	return 0
end

function space:GetO2()
	return 0
end

function space:GetCO2()
	return 0
end

function space:GetN()
	return 0
end

function space:CreateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n)
end

function space:UpdateSize(oldsize, newsize)
end

function space:UpdateEnvironment(gravity, atmosphere, pressure, temperature, o2, co2, n)
end

function space:GetVolume()
	return 0
end

function space:IsPlanet()
	return false
end

function space:IsStar()
	return false
end

function space:IsSpace()
	return true
end

function Get()
	if not obj then
		obj = {}
		setmetatable( obj, space )
	end
	return obj
end
