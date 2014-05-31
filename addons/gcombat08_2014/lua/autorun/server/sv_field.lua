
FIELDS = 1

field = {}



local fieldemitters = {}

function field.register( ent, name, value, radius)
	ent.fields = ent.fields or {}
	for _,p in pairs(ent.fields) do
		if name == p.name then return end
	end
	local isreg = false
	for _,g in pairs(fieldemitters) do
		if ent == g then isreg = true end
	end
	if isreg == false then fieldemitters[ #fieldemitters + 1] = ent end
	
	local fdtable = {}
	fdtable.ID = #ent.fields
	fdtable.value = value
	fdtable.name = name
	fdtable.radius = radius
	
	table.insert(ent.fields, fdtable)
	
end

function field.getpoint( vec, name )
	local rel = {}
	rel.entities = {}
	rel.value = 0
	rel.number = 0
	rel.signal = 0
	if #fieldemitters == 0 then return rel end
	for ind,i in pairs(fieldemitters) do
		if !i:IsValid() then 
			table.remove(fieldemitters, ind)
			
		else
			for _,u in pairs( i.fields ) do
				if u.name == name then
					local pos = i:GetPos()
					local check = i:Field( u ) or 0
					if pos:Distance(vec) < u.radius then
						rel.value = rel.value + (u.value * check)
						rel.entities[#rel.entities + 1] = i
						rel.number = rel.number + 1
						if check != 0 then rel.signal = rel.signal + check end
					end
				end
			end
		end
	end
	
	rel.value = rel.value / rel.signal
	
	return rel
end
