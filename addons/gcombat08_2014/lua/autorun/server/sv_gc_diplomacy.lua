
DIPLOMACY = 1

diplomacy = {}

local dipnet = {}



function diplomacy.registerfreshmeat(ply)
	local id = ply:UniqueID()
	dipnet[id] = {}
end

function diplomacy.SetAlign(ply1, ply2, aln)
	local id1, id2 = ply1:UniqueID(), ply2:UniqueID();
	
	if (!id1 || !id2) then return false end
	
	dipnet[id1][id2] = aln
	dipnet[id2][id1] = aln
	return true
end

function diplomacy.GetAligned(ply, aln)
	local id = ply:UniqueID()
	local mcarta = {}
	for p,a in pairs(dipnet[id]) do
		if a == aln then
			local player = player.GetByUniqueID(p)
			if player:IsValid() then mcarta[#mcarta + 1] = player end
		end
	end
	return mcarta
end

function smoothEntToAngle( ang1, ang2, ent, percent)
	local pitch = math.AngleDifference( ang1.p, ang2.p )
	local yaw = math.AngleDifference( ang1.y, ang2.y )
	local roll = math.AngleDifference( ang1.r, ang2.r )
	
	local TargAngle = Angle( ang1.p + (pitch * percent), ang1.y + (yaw * percent), ang1.r + (roll * percent))
	
	ent:SetAngles(TargAngle)
	return true
end

hook.Add( "PlayerInitialSpawn", "mingebag", diplomacy.registerfreshmeat );


