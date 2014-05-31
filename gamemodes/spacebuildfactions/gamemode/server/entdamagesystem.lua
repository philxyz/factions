------------------------------------------
-- Spacebuild Factions
-- Team Ring-Ding
------------------------------------------
--the factions damage system for entities. Makes props breakable.

function Factions.EntityTakesDamage( victim, dmginfo )--inflictor, attacker, amount, dmginfo )
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	local amount = dmginfo:GetDamage()
	
	attacker = attacker or inflictor --the hells the difference? (RingDing) -- yeah, really? what is the difference? - philxyz
	if attacker and attacker:IsWorld() then return false end --we dont take no crap from no world
	
	if victim:IsPlayer() or victim:IsNPC() or victim:IsVehicle() or victim:IsWorld() then return false end --Only apply to props

	if victim:GetClass() == "prop_ragdoll" then return false end
	
	if not gamemode.Call("CanDamageEntity", dmginfo) then return false end
	
	Factions.DamageEntity( victim, amount )
end
hook.Add( "EntityTakeDamage", "[FAC] Factions.EntityTakesDamage: Entity Damage System: core.lua", Factions.EntityTakesDamage )

function Factions.SetEntityHealth( e, amount )
	if not amount then
		-- grab volume
			local min,max = e:WorldSpaceAABB()
			local volume = ( max - min )
			volume = volume.x * volume.y * volume.z * .0005
			
		--grab mass
			local phys = e:GetPhysicsObject()
			local mass = .5
			if phys and phys:IsValid() then
				mass = math.Clamp( e:GetPhysicsObject():GetMass() * .5, 1, 100 )
			end
			
		--Calc it and set it!
			amount = math.Clamp( volume * mass, 100, 5000 )
			e:SetMaxHealth( amount )
			e:SetHealth( amount )
	else
		e:SetMaxHealth( amount )
		e:SetHealth( amount )
	end
	
	fac_Debug( tostring(e) .. " health set to " .. tostring( amount ) )
end

function Factions.SetEntityArmor( e, amt )
	if amt and type(amt) == "number" then
		if amt < 0 then amt = 0 end
		
		e.fac_armor = amt
	else
		e.fac_armor = 0
	end
end

function Factions.DamageEntity( e, amount, armr )
	if not e.healthset then --Set the health (if it hasn't been set already)
		Factions.SetEntityHealth(e)
		e.healthset = true --make sure we don't set the health more than once
	end
	if not e.armorset then
		Factions.SetEntityArmor(e)
		e.armorset = true
	end
	
	--Determine mat type (metal, wood, etc.) and thus how much resistance it has to the attack
		local tr = {}
			tr.start = e:GetPos()
			tr.endpos = e:GetPos()
			tr = util.TraceLine( tr )
			
		local weakness = 1
		if tr and tr.MatType and tr.Entity == e then
			if tr.MatType == MAT_CONCRETE or tr.MatType == MAT_METAL or tr.MatType == MAT_DIRT or tr.MatType == MAT_SAND or tr.MatType == MAT_TILE then
				weakness = .5
				--fac_Debug("Setting weakness to .5")
			elseif tr.MatType == MAT_VENT or tr.MatType == MAT_GRATE or tr.MatType == MAT_PLASTIC then
				weakness = 1
				--fac_Debug("Setting weakness to 1")
			else
				weakness = 1.5
				--fac_Debug("Setting weakness to 1.5")
			end
		end

	--Apply the damage
		amount = amount * weakness
		if e:Armor() > 0 then
			e:SetHealth( e:Health() - ( amount * .25 ) )
			e:SetArmor( e:Armor() - ( amount * .75 ) - (armr or 0) )
		else
			e:SetHealth( e:Health() - amount )
		end
	
	--Color it based on health
		local color = ( e:Health() / e:GetMaxHealth() ) * 255
		e:SetColor(Color( color, color, color, 255 ))
	
	--If health is below 0, kill it!
		if e:Health() <= 0 then
			local startpos = e:GetPos()
				local effectdata = EffectData()
				effectdata:SetStart( startpos )
				effectdata:SetOrigin( startpos )
				effectdata:SetScale( 1 )
			util.Effect( "Explosion", effectdata )
			
			constraint.RemoveAll( e )
			e:Remove()
		end
end

function GM:CanDamageEntity( e, attacker, amount, dmginfo ) --amount, and dmginfo are optional at this point, but include them anyway if you have them so that later on if I need them I have access to them
	if not Factions.Config.FragileProps then return false end
	
	local class = string.lower(e:GetClass())
	if (class == "transformer" and not e:GetTable().spawned) or class == "flag" or string.find( class, "stone" ) then return false end
	
	local ply = Factions.GetEntOwner(e)
	if ply and ply.Team and ply:IsValid() and attacker and attacker.Team and attacker:IsValid() then
		if ply == attacker then return true end
		if ply:Team() == attacker:Team() and not Factions.FF then return false end
	end
	
	return true
end

----------------------------------------------------
--      Force Ask
----------------------------------------------------
--this is to force addons to play fair and ask us before they damage or remove our entities.

local function ForceAsk()
	if Factions.Addons.Gcombat then
		fac_Msg("Gcombat detected, implementing GCOMBAT08	v1.1 overwrite.")
		
		Factions.gcombat_devhit = gcombat.devhit
		function gcombat.devhit( entity, damage, pierce )
			if not gamemode.Call("CanDamageEntity", entity) then return false end
			
			return Factions.gcombat_devhit(entity, damage, pierce)
		end
		cbt_dealdevhit = gcombat.devhit
	end

	if Factions.Addons.CDS then
		fac_Msg("CDS detected, implementing CDS v1.0.2 overwrite.")
		
		Factions.cds_damageent = cds_damageent
		function cds_damageent(ent, damage, pierce, inflictor, heat)
			if not gamemode.Call("CanDamageEntity", ent, inflictor, damage) then return false end
			
			return Factions.cds_damageent(ent, damage, pierce, inflictor, heat)
		end
	end
	
	if Factions.Addons.SBMP then
		fac_Msg("Spacebuild Model Pack detected, implementing SBMP Beam Cannon v1.5b overwrite.")
	
		Factions.constraint_RemoveAll = constraint.RemoveAll
		function constraint.RemoveAll( ent )
			local class = string.lower(ent:GetClass())
			if (class == "transformer" and not ent:GetTable().spawned) or class == "flag" then return end
			
			return Factions.constraint_RemoveAll( ent )
		end
		
		Factions.SafeRemoveEntityDelayed = SafeRemoveEntityDelayed
		function SafeRemoveEntityDelayed(ent, tyme)
			local class = string.lower(ent:GetClass())
			if (class == "transformer" and not ent:GetTable().spawned) or class == "flag" then return end
			
			return Factions.SafeRemoveEntityDelayed(ent,tyme)
		end
		
		local e = FindMetaTable( "Entity" )
		Factions.ent_SetCollisionGroup = e.SetCollisionGroup
		function e:SetCollisionGroup(typ)
			local class = string.lower(self:GetClass())
			if (class == "transformer" and not self:GetTable().spawned) or class == "flag" then return end
			
			return Factions.ent_SetCollisionGroup(self, typ)
		end
		
		local phys = FindMetaTable( "PhysObj" )
		Factions.phys_EnableMotion = phys.EnableMotion
		function phys:EnableMotion( bool )
			local ent = self:GetEntity()
			local class = string.lower(ent:GetClass())
			if (class == "transformer" and not ent:GetTable().spawned) or class == "flag" then return Factions.phys_EnableMotion(self, false) end
			
			return Factions.phys_EnableMotion(self, bool)
		end
	end
end
hook.Add( "Overwrite", "[FAC] Overwrite Functions", ForceAsk )
