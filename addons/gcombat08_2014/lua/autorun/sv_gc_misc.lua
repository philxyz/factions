
/*
~= Propagating entity functions.
for things that spread like the plague, then fail and die.
*/
if (SERVER) then
local gcbt_p_ent = {}
propent = {}


	function propent.new( maxents, maxtime )
		local TD = {}
		TD.dietime = CurTime() + maxtime
		TD.maxents = maxents
		TD.entl0 = 0
		local ind = #gcbt_p_ent + 1
		gcbt_p_ent[ind] = TD
		return ind
	end

	function propent.think( id )
		return (gcbt_p_ent[id].dietime > CurTime())
	end
	
	function propent.addme( id )
		gcbt_p_ent[id].entl0 = gcbt_p_ent[id].entl0 + 1
	end
	
	function propent.delme( id )
		gcbt_p_ent[id].entl0 = gcbt_p_ent[id].entl0 - 1
	end
	
	function propent.canmakemore( id )
		return (gcbt_p_ent[id].entl0 < gcbt_p_ent[id].maxents)
	end

end
/*
~= Diplomacy system.
Good ol backstabby style diplomacy. Micht be useful for some user made thing, but I have no use as of yet.
*/
DIPLOMACY = 1

diplomacy = {}

local dipnet = {}


--lol k noob
function diplomacy.registerfreshmeat(ply)
	local id = ply:UniqueID()
	dipnet[id] = {}
end

--sets alignment between the players. PROTIP: you can use any number in aln
function diplomacy.SetAlign(ply1, ply2, aln)
	local id1, id2 = ply1:UniqueID(), ply2:UniqueID();
	
	if (!id1 || !id2) then return false end
	
	dipnet[id1][id2] = aln
	dipnet[id2][id1] = aln
	return true
end

--list of friends or enemies or custom.
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

hook.Add( "PlayerInitialSpawn", "mingebag", diplomacy.registerfreshmeat );

/*
~= GC math library
Functions I need for mai maths.
*/
GCMATH = 1

gcml = {}

--bell curve (square)
function gcml.bellcurve( I )
	return 1 - (I * I)
end

--converts a 0 to 1 float percentage into a range from -1 to 1
function gcml.pertopnv( I )
	return (I * 2) - 1
end

--converts a -1 to 1 range into a float percent. just in case.
function gcml.pnvtoper( I )
	return 1 + (I / 2)
end

--Returns a vector for a simple three point curve.
--Because all the other functions are useless, broken, confusing. in that order.
function gcml.threepointsmooth(v1, v2, direction, percent)
	return v1 + ((v2 - v1) * percent) + (direction * gcml.bellcurve( gcml.pertopnv( percent )))
end

--dunno what I'd need this for. other than MISC LOL. ALSO CAMERA
function gcml.smoothangle( ang1, ang2, percent)
	local pitch = math.AngleDifference( ang2.p, ang1.p )
	local yaw = math.AngleDifference( ang2.y, ang1.y )
	local roll = math.AngleDifference( ang2.r, ang1.r )
	
	return Angle( ang1.p + (pitch * percent), ang1.y + (yaw * percent), ang1.r + (roll * percent))
end
