
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')

local fuse = 10
local blrad = 100
local blpow = 100
local stickradius = 100

function ENT:Initialize()   

	math.randomseed(CurTime())
	self.exploded = false
	self.fuseleft = CurTime() + 2
	self.deathtype = 0	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS ) 
	self.Entity:SetColor(Color(20,20,20,255))
	self.Entity:SetCollisionGroup( 0 )
	local phys = self.Entity:GetPhysicsObject()  	
	local pos = self.Entity:GetPos()
	if (phys:IsValid()) then  		
		phys:Wake()
		phys:EnableGravity(false)
		phys:ApplyForceCenter(Vector((pos.x + math.random(-400,400)),(pos.y + math.random(-400,400)),(pos.z + math.random(-400,400))):GetNormalized() * 300)
	end 
 
end   
 
function ENT:Think()
	local Low, High = self.Entity:WorldSpaceAABB()
	local Center = High - (( High - Low ) * 0.5)
	local vPos = Vector( math.Rand(Low.x,High.x), math.Rand(Low.y,High.y), math.Rand(Low.z,High.z) )
	if (self.fuseleft < CurTime()) then
		self.Entity:Remove()
	end
	 
	if (self.deathtype == 0) then
		local effectdata = EffectData()
		effectdata:SetOrigin(vPos)
		effectdata:SetStart(vPos)
		effectdata:SetScale( 10 )
		effectdata:SetRadius( 100 )
		util.Effect( "spark_death", effectdata )
		
	elseif (self.deathtype == 1) then
		local effectdata = EffectData()
		effectdata:SetEntity( self.Entity )
		if self.exploded == false then
			util.Effect( "ener_death", effectdata )
			self.exploded = true
		end
		
		
	end
	self.Entity:NextThink( CurTime() + 0.1)
	self.Entity:SetColor(Color(20,20,20,255 * ((self.fuseleft - CurTime()) / 2)))
	self.Entity:SetRenderMode( RENDERMODE_TRANSALPHA )
	return true
end

function ENT:OnTakeDamage( dmginfo )

	// React physically when shot/getting blown
	self.Entity:TakePhysicsDamage( dmginfo )
	
end
