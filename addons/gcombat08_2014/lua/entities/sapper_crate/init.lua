AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )


include('shared.lua')

util.PrecacheSound( "ambient/explosions/explode_1.wav" )
util.PrecacheSound( "ambient/explosions/explode_2.wav" )
util.PrecacheSound( "ambient/explosions/explode_3.wav" )
util.PrecacheSound( "ambient/explosions/explode_4.wav" )


function ENT:Initialize()

self.expl = {}
	self.expl[0] = "ambient/explosions/explode_1.wav"
	self.expl[1] = "ambient/explosions/explode_2.wav"
	self.expl[2] = "ambient/explosions/explode_3.wav"
	self.expl[3] = "ambient/explosions/explode_4.wav"
	
	self.hasdamagecase = true
	
	self.NextSapper = CurTime()
	
	self.Entity:SetModel( "models/items/item_item_crate.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.contents = {}
	self.contents[0] = "gcbt_sapper"
	self.contents[1] = "gcbt_tankgun"
	self.contents[2] = "gcbt_mortargun"
	self.cur = 0
	self:SetOverlayText( "Current weapon: \n" .. self.contents[self.cur] )
end

function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 16

	local ent = ents.Create( "munition_crate" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:gcbt_breakactions(damage, pierce)
	self.hasdamagecase = false
	local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		util.Effect( "sapper_explosion", effectdata )
		cbt_hcgexplode( self.Entity:GetPos(), 75, 200, 2)
		util.BlastDamage(self.Entity, self.Entity, self.Entity:GetPos(), 400, 100)
		self.Entity:Remove()
	self.Entity:EmitSound( self.expl[ math.random(0,3) ], 500, 100 )
end

function ENT:Think()
	if self.NextSapper < CurTime() then
		self.Entity:SetColor(Color(255,255,255,255))
	else
		self.Entity:SetColor(Color(100,100,100,255))
	end
end

function ENT:OnTakeDamage( oles )
	if !oles:GetAttacker( ):IsPlayer() then return end
	self.cur = self.cur + 1
	if self.cur > #self.contents then self.cur = 0 end
	self:SetOverlayText( "Current weapon: \n" .. self.contents[self.cur] )
end

function ENT:Use( act, cal )
if !act:IsPlayer() then return end
if self.NextSapper < CurTime() && !act:HasWeapon( self.contents[self.cur] ) then
	
	act:Give(self.contents[self.cur])
	
	self.NextSapper = CurTime() + 90
	return true
	
else
	return false
end

end

