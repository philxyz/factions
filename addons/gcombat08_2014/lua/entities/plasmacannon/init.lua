
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('entities/base_wire_entity/init.lua'); 
include('shared.lua')

util.PrecacheSound( "ambient/machines/spin_loop.wav")

function ENT:Initialize()  

	math.randomseed(CurTime())
	self.ammos = 100
	self.armed = false
	self.loading = false
	self.reloadtime = 0
	self.shelltype = 42
	self.infire = false
	self.Entity:SetModel( "models/combatmodels/tank_gun.mdl" ) 	
	self.Entity:PhysicsInit( SOLID_VPHYSICS )      -- Make us work with physics,  	
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )   --after all, gmod is a physics  	
	self.Entity:SetSolid( SOLID_VPHYSICS )        -- Toolbox     
	self.Entity:SetColor( Color(255, 255, 255, 255) )
	
	self.spinupsound = CreateSound(self.Entity, Sound("ambient/machines/spin_loop.wav"))
	self.spinuppercent = 0
	
	self.spinupsound:PlayEx( 0, 0 )
	
	self.val1 = 0
	self.val2 = 0
          
	local phys = self.Entity:GetPhysicsObject()  	
	if (phys:IsValid()) then  		
		phys:Wake() 
		phys:SetMass( 3 ) 
	end 
 
	self.Inputs = Wire_CreateInputs( self.Entity, { "Fire" } )
	self.Outputs = Wire_CreateOutputs( self.Entity, { "Can Fire" , "Shots Remaining" , "Spin" })
end   

function ENT:SpawnFunction( ply, tr)
	
	if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 60
	
	
	local ent = ents.Create( "tank_gun" )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	
	
	return ent

end

function ENT:OnRemove()
	self.spinupsound:Stop()
end


function ENT:fireAPshell()

	if (self.ammos > 0) then
		local pos = self.Entity:GetPos()
		
		
		local trace = {}
		trace.start = self.Entity:GetPos() + self.Entity:GetUp() * 50
		trace.endpos = self.Entity:GetPos() + self.Entity:GetUp() * 10000 + (VectorRand() * math.Rand(0, 500))
		trace.filter = self.Entity 
		local tr = util.TraceLine( trace ) 
		
		if (tr.Hit && tr.Entity:IsValid()) then
			if ( !tr.Entity:IsWorld() || !tr.Entity:IsPlayer() || !tr.Entity:IsNPC() || !tr.Entity:IsVehicle()) then
				local attack = cbt_dealhcghit( tr.Entity, 100, tr.HitNormal:Dot(self.Entity:GetUp() * -1) * 8, tr.HitPos, 		tr.HitPos)
			end
		end
	
		util.BlastDamage(self.Entity, self.Entity, tr.HitPos, 200, 50)
		
		self.reloadtime = CurTime() + 1.1 - (self.spinuppercent/100)
		
		local effectdata = EffectData()
		effectdata:SetOrigin(tr.HitPos)
		effectdata:SetStart(self.Entity:GetPos() +  self.Entity:GetUp() * 50)
		util.Effect( "plasmaray", effectdata )
		end

end

function ENT:Think()
	
	if (self.reloadtime > CurTime()) then
		self.armed = false
		Wire_TriggerOutput(self.Entity, "Can Fire", 0)
	end
	
	if (self.armed == true) then
		
		
		if self.spinuppercent > 30 then
			self:fireAPshell()
		end
		
		
		
	elseif (self.reloadtime < CurTime()) then
		Wire_TriggerOutput(self.Entity, "Can Fire", 1)
		
		if (self.infire == true) then self.armed = true end
	end
	
	if self.infire == true then 
		self.spinuppercent = math.min(self.spinuppercent + 1, 100)
	else
		self.spinuppercent = math.max(self.spinuppercent - 1, 0)
	end
	
	self.spinupsound:ChangePitch(self.spinuppercent, 2)
	self.spinupsound:ChangeVolume(self.spinuppercent * 1000, 2)
	
	Wire_TriggerOutput(self.Entity, "Spin", self.spinuppercent)
	
	self:NextThink( CurTime())
	return true
end

function ENT:TriggerInput(iname, value)

	if (iname == "Fire") then
		if (value == 1 && self.infire == false) then
			self.infire = true
			
		end
		if (value == 0 && self.infire == true) then 
			self.infire = false
		end
		self.Entity:NextThink( CurTime() )
		return true
	end

end
 
 
