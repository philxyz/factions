
COMBATDAMAGEENGINE = 1

gcombat = {}

function gcombat.registerent( ent, health, armor )
	local h = ent:GetPhysicsObject():GetMass() * 4
	ent.cbt = {};
	ent.cbt.health = health or math.Clamp( h, 1, 4000 )
	ent.cbt.armor = armor or 8
	ent.cbt.maxhealth = health or math.Clamp( h, 1, 4000 )
end

function gcombat.validate( ent )

	if (ent:GetPhysicsObject():IsValid() and !ent:IsPlayer() and ent:GetClass() != "wreckedstuff" and !ent:IsWorld() and !ent:IsWeapon() and string.find(ent:GetClass(), "func_") != 1 ) then
		if ent.cbt then return true else gcombat.registerent(ent) end
		return true
	end
	return false
end

function gcombat.devhit( entity, damage, pierce )
	local valid = gcombat.validate(entity)
	
	if valid then
		local armornum = pierce + math.Rand(0, 6)
		if armornum < entity.cbt.armor then return 0 end
		if ((entity.cbt.health) < damage) then
			if (entity.hasdamagecase == true) then
				entity:gcbt_breakactions(damage, pierce)
				return 1
			else
				return 2
			end
		else
			entity.cbt.health = entity.cbt.health - damage
			return 1
		end
		
	end
	
end

cbt_dealdevhit = gcombat.devhit

--cbt_dealhcghit deals a hollow charge style hit to the object.
function gcombat.hcghit( entity, damage, pierce, src, dest)

	local attack = gcombat.devhit( entity, damage, pierce)
	
	
	
	if attack == 2 then
		 local tmp = entity:GetModel()
		local wreck = ents.Create( "wreckedstuff" )
		wreck:SetModel( entity:GetModel() )
		wreck:SetAngles( entity:GetAngles() )
		wreck:SetPos( entity:GetPos() )
		wreck:Spawn()
		wreck:Activate()
		entity:Remove()
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "Explosion", effectdata1 )
		
	elseif attack == 1 then

		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "HelicopterMegaBomb", effectdata1 )

	elseif attack == 0 then

		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "RPGShotDown", effectdata1 )
		
	end

return attack
end

cbt_dealhcghit = gcombat.hcghit

--cbt_dealnrghit deals an energy weapon hit to the object.
function gcombat.nrghit( entity, damage, pierce, src, dest)

	local attack = cbt_dealdevhit( entity, damage, pierce )

	if attack == 2 then

		local wreck = ents.Create( "wreckedstuff" )
		wreck:SetModel( entity:GetModel() )
		wreck:SetAngles( entity:GetAngles() )
		wreck:SetPos( entity:GetPos() )
		wreck:Spawn()
		wreck:Activate()
		wreck.deathtype = 1
		entity:Remove()
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		effectdata1:SetScale( 10 )
		effectdata1:SetRadius( 100 )
		util.Effect( "cball_bounce", effectdata1 )

	elseif attack == 1 then

		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		util.Effect( "ener_succeed", effectdata1 )
		
	elseif attack == 0 then
		
		local effectdata1 = EffectData()
		effectdata1:SetOrigin(src)
		effectdata1:SetStart(dest)
		util.Effect( "ener_fail", effectdata1 )

	end

return attack

end

cbt_dealnrghit = gcombat.nrghit

--this is how you d explosions, and is in here more as an example than anything else.
function gcombat.hcgexplode( position, radius, damage, pierce)

	local targets = ents.FindInSphere( position, radius)
	local tooclose = ents.FindInSphere( position, 5)
	
	for _,i in pairs(targets) do
		
		
		
		local tracedata = {}
		tracedata.start = position
		tracedata.endpos = i:LocalToWorld( i:OBBCenter( ) )
		tracedata.filter = tooclose
		tracedata.mask = MASK_SOLID
		local trace = util.TraceLine(tracedata) 
		
		
		
		if trace.Entity == i then
			local hitat = trace.HitPos
			cbt_dealhcghit( i, damage, pierce, hitat, hitat)
		end
	end
	
	
end

cbt_hcgexplode = gcombat.hcgexplode

function gcombat.nrgexplode( position, radius, damage, pierce)

	local targets = ents.FindInSphere( position, radius)
	
	for _,i in pairs(targets) do
		local hitat = i:NearestPoint( position )
		cbt_dealnrghit( i, damage, pierce, hitat, hitat)

	end
end

cbt_nrgexplode = gcombat.nrgexplode

--this is new, lol. It is what you should be using to heat things up.
function gcombat.applyheat(ent, temp)
	--nothing. this is kept here so that everything that used to use heat doesn't break.
end

cbt_applyheat = gcombat.applyheat

--Use this function to emit area heat. Input 0 to the fourth argument to have it heat up the prop emitting it as well.
function gcombat.emitheat( position, radius, temp, own)
	--nothing. this is kept here so that everything that used to use heat doesn't break.
end

cbt_emitheat = gcombat.emitheat

--This allows you to set a prop's armor.
function gcombat.modifyarmor( entity, armor )
	
	local index = entity.cbt.index
	local core = entity.cbt.core
	core.ppt[index].armor = def

end

cbt_modifyarmor = gcombat.modifyarmor

