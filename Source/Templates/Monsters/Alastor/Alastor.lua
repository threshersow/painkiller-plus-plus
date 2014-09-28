function Alastor:OnPrecache()
	Cache:PrecacheDecal(self.HitDecal)
	Cache:PrecacheParticleFX("AlastorenergyFX")
	Cache:PrecacheParticleFX(self.flamerFX)
	Cache:PrecacheParticleFX("but")
end


function Alastor:OnInitTemplate()
    self:SetAIBrain()
end

function Alastor:CustomDelete()
	if self._flySound then
		ENTITY.Release(self._flySound)
		self._flySound = nil
	end
	if self._soundSampleCharge then
		SOUND2D.SetVolume(self._soundSampleCharge, 0, 0.1)
		SOUND2D.Forget(self._soundSampleCharge)
		self._soundSampleCharge = nil
	end
end

function Alastor:CustomUpdate()
	if not self._died then
		local brain = self._AIBrain
		Game.MegaBossHealth = self.Health
	end
	if self._flameFX then
		if math.random(100) < 15 then		
			self:CheckDamageFromFlame()
		end
	end
--[[	if debugMarek then
		if not self.moder then
			self.moder = 0
		end
		if not self._isRotating and not self.x then
			--Game:Print("actor.angle "..(self.angle * 180/math.pi))
			--self.x = 1
			if self.moder == 0 then
				self:RotateWithAnim(45)
			end
			if self.moder == 1 then
				self:RotateWithAnim(-45)
			end
			if self.moder == 2 then
				self:RotateWithAnim(90)
			end
			if self.moder == 3 then
				self:RotateWithAnim(-90)
			end
		end
    end--]]
end



function Alastor:OnCreateEntity()
	--ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.OnlyWithFixedSpecial)
	self._disableHits = true
	Game.MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health	
	ENTITY.PO_EnableGravity(self._Entity,false)
	ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	self._speedDamping = true
	self._phase = 0
	self._floorNo = 1
	self.AiParams.wingJointsNo = {}
	for i,v in self.AiParams.wingJoints do
		local idx  = MDL.GetJointIndex(self._Entity,v)
		if idx == -1 then
			Game:Print(v.." not found")
		end
		table.insert(self.AiParams.wingJointsNo, idx)
	end
	if not debugMarek then
		Game.showCompassArrow = false
	end
	self._delayExplTime = 3
	
    --self._HasMovingCurveRot = "ROOOT"
	--self._HasMovingCurveX = true
	self._moveWithAnimationDoNotUpdateAngle = true
	DebugSpheres = {}
	--self.moder = 0
	self._pissedOffRatio = 0

	if self.enableCollisionsToMeshes then
		self.collisionsNumber = 0
		--local count = 0
		PHYSICS.ActiveMeshGroupSetActivationParams(1, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
						self.StoneParams.miminalMassReportingCollision,self.StoneParams.maximalMassReportingCollision, self.StoneParams.amountReportingCollisions * 100,
						self.StoneParams.timeToLive,self.StoneParams.timeToLiveRandomize)
		--Game:Print("Enable collision to "..count.." meshes")
		Lev.ObjBoss = self

	end
	PHYSICS.ActiveMeshGroupEnable(1, true)
	ENTITY.EnableDeathZoneTest(self._Entity, false)
	self:CreateMonks()

	for i,v in self._monks do
		ENTITY.EnableDraw(v._Entity,false)
	end

	--[[if debugMarek then		-- set phase 1 immid
		ENTITY.PO_SetMonsterMovementConst(self._Entity, self.havokInfluenceInMonsterMovementOnGround, false)
		self._speedDamping = nil
		ENTITY.PO_EnableGravity(self._Entity,true)
		self._phase = 1
		self._floorNo = 4
		--self:CreateMonks()
		self.AiParams.towerRadius = self.AiParams.towerRadiusBottom
		self.AiParams.towerRange = self.AiParams.towerRangeBottom
		for i,v in self._monks do
			ENTITY.EnableDraw(v._Entity,true)
		end
		self._randomizedParams.RotateSpeed = self.RotateSpeedGround
	end--]]

end

function Alastor:OnApply()
	self:PlayRandomSound2D({"alastor_ambient-stereo1","alastor_ambient-stereo2","alastor_ambient-stereo3",})
	self._flySound = self:BindSound("actor/alastor/alastor_fly-loop",16, 60, true)
end

function Alastor:CheckDamageFromFlame()
	-- dodac min. time between attacks
	local idx  = MDL.GetJointIndex(self._Entity,"k_szyja")
	local idx2  = MDL.GetJointIndex(self._Entity,"k_glowa")
	local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx)
	local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx2)
	local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
	v2:Normalize()
	
	-- spr. kilka sfer na drodze promienia, czy Player jest w zasiegu plomienia
	local i = 5
	if debugMarek then
		DebugSpheres = {}
	end
	
	local dist = 60
	local size = 9
	if self.Animation ~= "zieje02" and self.Animation ~= "zieje02a" then
		if self._phase == 0 then
			dist = 48
			size = 7
		else
			if self._floorNo ~= 4 then
				dist = 36
				size = 5.5
			end
		end
	else
		--Game:Print("y2 = "..y2.." y3 = "..y3)
		y3 = y3 + 1.0
	end
	--Game:Print("dist = "..dist.." size = "..size)
	
	
	while i < dist do
		local v3 = Clone(v2)
		v3:MulByFloat(i)
		i = i + size
		local x,y,z = x3 + v3.X, y3 + v3.Y, z3 + v3.Z
		
		if debugMarek then
			local a = {}
			a.X = x
			a.Y = y
			a.Z = z
			a.Size = size
			table.insert(DebugSpheres, a)
		end
		local dist = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.5, Player._groundz)
		if dist < size then
			Player:OnDamage(self.flameDamage, self)
			break
		end
	end
end


function Alastor:CustomOnDamage(he,x,y,z,obj,damage,type,nx,ny,nz)
	-- tu spr. czy nie od wlasnej eksplozji
	if type == AttackTypes.OutOfLevel then
		self._died = true
		self.Health = 0
		self._disableDemonic = true
		Game.MegaBossHealth = nil
		self._deathTimer = self.DeathTimer
		GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		Game.MegaBossHealthMax = nil
		Game:Print("ERROR: ALASTOR POZA LEVELEM")
		return true
	end
	if obj == self then
		--Game:Print("self damage "..damage)
		return true
	end
	if not self._ABdo then
		if nz then
			--Game:Print("blood fx")
			self:BloodFX(x,y,z,nx,ny,nz)
		end
		self.Health = self.Health - damage
		if self._AIBrain._lastDamageTime + 1.5 < self._AIBrain._currentTime then
			self:PlaySoundHitBinded("hurt", 50, 200)
			self._AIBrain._lastDamageTime = self._AIBrain._currentTime + FRand(0.0, 0.3)
		end
		if self.Health < 0 then
			self.Health = 0
			if self._floorNo == 4 then
				local monkNotDestroyed = 0
				for i,v in self._monks do
					if v.Health > 0 then
						monkNotDestroyed = monkNotDestroyed + 1
					end
				end
				if monkNotDestroyed == 0 then
					if not debugMarek then
						Game.showCompassArrow = true
					end
					self._died = true
					self:Stop()
					ENTITY.PO_Enable(self._Entity,false)
					self:EnableRagdoll(true,true,x,y,z)
					Game.MegaBossHealth = nil
					self._deathTimer = self.DeathTimer
					Game.MegaBossHealthMax = nil
					self:BindRandomSound({"alastor_death"}, 50, 300)
					--Game:Print("alastor died")
					if self._flameFX then
						PARTICLE.Die(self._flameFX)
						self._flameFX = nil
					end
					if self._soundSampleCharge then
						SOUND2D.SetVolume(self._soundSampleCharge, 0, 0.1)
						SOUND2D.Forget(self._soundSampleCharge)
						self._soundSampleCharge = nil
					end
					Game.BodyCountTotal = Game.BodyCountTotal + 1
					--AddItem("EndOfLevel.CItem",nil,Vector:New(0, 36, 0), true)
					
					self._disableDemonic = true
					self._timerToDemon = 4
					
					return true
				else
					--Game:Print("Monks destroyed = "..monkNotDestroyed)
				end
			end
			--Game:Print("HEALTH < 0 : ABDO "..self._floorNo)
			self._ABdo = 1
		else
			-- narazie 
			if self.Health * 0.4 < self._HealthMax then
				self._pissedOffRatio = 0.7
			end
			--
		end
	end

	return true
end
 


-----------------
Alastor._CustomAiStates = {}

Alastor._CustomAiStates.idleAlastor = {
	lastTimeAmbientSound = 0,
	lastAmbient = 1.0,
	name = "idleAlastor",
}
function Alastor._CustomAiStates.idleAlastor:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:Stop()
	--Game:Print("idle oninit")
end

function Alastor._CustomAiStates.idleAlastor:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if self.lastAmbient + 1.0 < brain._currentTime and actor._phase == 0 then
		local tabl = aiParams.actions
		--Game:Print("losowanie check "..brain._currentTime)
		self.lastAmbient = brain._currentTime
		self._submode = nil
		local mul = 1.0
		if actor._damage then
			mul = 1.2			-- jak dostanie hita to chetniej losuje ataki
		end
		for i,v in tabl do
			if FRand(0.0, 1.0) < v[2] * mul then
				self._submode = v[1]
				break
			end
		end

		if self._submode then
			--Game:Print("losowanie "..self._submode)
			brain._submode = self._submode
			return
		end
		actor._damage = false
	end

	actor._CANWALK = true
end

function Alastor._CustomAiStates.idleAlastor:OnRelease(brain)
	local actor = brain._Objactor
	brain._rotate180AfterEndWalking = nil
	actor._CANWALK = false
end

function Alastor._CustomAiStates.idleAlastor:Evaluate(brain)
	return 0.01
end


------------
Alastor._CustomAiStates.attackFlyAlastor = {
	name = "attackFlyAlastor",
	active = false,
	posVFar = 150,		-- y
	posFar = 230 - 36,		-- y		(bylo: 250, 224, 180)
	posClose = 224 - 36,		-- y
	distFly2 = 100,
	distFly = 100,
}

function Alastor._CustomAiStates.attackFlyAlastor:OnInit(brain)
	--Game:Print("attack")
	local actor = brain._Objactor
	brain._submode = nil
	self.mode = -1
	
	-- random pos
	--if not self.angle then
		self.angle = math.random(0,360)
	--else
	--	self.angle = self.angle + math.random(-60,60) + 180
	--end
	self.angle = self.angle * math.pi/180
	local x = math.sin(self.angle) + math.cos(self.angle)
	local z = math.cos(self.angle) - math.sin(self.angle)
	local d = self.distFly + self.distFly2
	x = x * d
	y = self.posVFar
	z = z * d
	actor.Pos.X = x
	actor.Pos.Y = y
	actor.Pos.Z = z
	ENTITY.SetPosition(actor._Entity, x,y,z)
	--Game.freezeUpdate = true
	--
	self.active = true
	self._sound = nil
end

function Alastor._CustomAiStates.attackFlyAlastor:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == -1 then
		actor._groundx,actor._groundy,actor._groundz = ENTITY.PO_GetPawnFloorPos(actor._Entity)
		actor:RotateToVector(Player._groundx, self.posClose, Player._groundz)
		self.mode = 0
		return
	end
	if self.mode == 0 and not actor._isRotating then
		--Game:Print("fly up")
		--Game.freezeUpdate = true
		local x,y,z = Player._groundx, self.posFar, Player._groundz
		actor:FlyForward(self.distFly2, nil, self.posFar - self.posVFar)		-- cel zawsze na ts wysokosci
		self.mode = 1
		return
	end
	
	if self.mode == 1 and not actor._isWalking then
		--Game.freezeUpdate = true
		self.delay = FRand(actor.delayBetweenFlyAttacks,actor.delayBetweenFlyAttacks*1.5)
		actor._groundx,actor._groundy,actor._groundz = ENTITY.PO_GetPawnFloorPos(actor._Entity)
		local x,y,z = Player._groundx, self.posClose, Player._groundz
		actor:FlyTo(x,y,z)		-- cel zawsze na ts wysokosci
		--actor:FlyForward(self.distFly, nil, self.posClose - self.posFar)		-- cel zawsze na ts wysokosci
		self._targetX = x
		self._targetY = y
		self._targetZ = z
		self.mode = 2
		self._animSpeed = MDL.GetAnimTimeScale(actor._Entity, actor._CurAnimIndex)
		--Game:Print("1 "..self._animSpeed)
        self.speed = self._animSpeed
        self._actorSpeed = actor._Speed
		return
	end

	if self.mode == 2 then
		local dist = Dist3D(actor._groundx,actor._groundy,actor._groundz,self._targetX,self._targetY,self._targetZ)
		if dist < 60 then
			self.speed = self.speed + 0.035
			actor._Speed = actor._Speed + 0.035
			if self.speed > 2.5*self._animSpeed then
				self.speed = 2.5*self._animSpeed
			end
			if actor._Speed > 2.5*self._actorSpeed then
				actor._Speed = 2.5*self._actorSpeed
			end
			MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, self.speed)
		end
		if not actor._isWalking then
			self.mode = 3
			--Game:Print("2 "..self.speed)
		else
			local dist = Dist3D(actor._groundx,0,actor._groundz,0,0,0)
			if dist < 45 and not self._sound then
				self._sound = true
				--if math.random(100) < 60 then
					local j = MDL.GetJointIndex(actor._Entity, "k_szczeka")
					local snd = actor:PlaySoundHitBinded({"alastor_attack1-attackvoice","alastor_onfly1"},40, 200, j)
					SND.SetVelocityScaleFactor(snd, 0,0)
				--end
			end
		end
		return
	end
	if self.mode == 3 then		-- atak
		local b = actor._Speed
		actor:FlyForward(self.distFly + 120, nil, self.posFar - self.posClose)		-- pozniej precyzyjnie - 140 poza srodek
		actor._Speed = b
		MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, self.speed)
		self.mode = 4
	end
	if self.mode == 4 then		-- odlot
		if not actor._isWalking then
			-- tu spr. czy naprawde odlecial daleko
			--Game.freezeUpdate = true
			--Game:Print("fly down")
			self.mode = 5
			actor:PlayRandomSound2D({"alastor_ambient-stereo1","alastor_ambient-stereo2","alastor_ambient-stereo3",})
			actor:FlyForward(self.distFly2, nil, self.posVFar - self.posFar)
			--
		else
			local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
			v:Normalize()
			v:MulByFloat(8.0)
			local x,y,z = actor._groundx,actor._groundy+2,actor._groundz
			WORLD.Explosion2(x+v.X, y, z+v.Z, 5000, --[[range--]]8,nil,AttackTypes.Rocket,actor.AiParams.flyDamage)
			actor.DEBUGl1 = x + v.X
			actor.DEBUGl2 = y
			actor.DEBUGl3 = z + v.Z

		
			self.speed = self.speed - 0.035
			actor._Speed = actor._Speed - 0.035
			if self.speed < self._animSpeed then
				self.speed = self._animSpeed
			end
			if actor._Speed < self._actorSpeed then
				actor._Speed = self._actorSpeed
			end
			MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, self.speed)
		end
	end
	if self.mode == 5 and not actor._isWalking then
		self.speed = self._animSpeed
		actor._Speed = self._actorSpeed
		if self.delay then
			self.delay = self.delay - 1
			if self.delay < 0 then
				self.delay = nil
			end
		else
			self.active = false
			self.mode = 0
		end
	end
end

function Alastor._CustomAiStates.attackFlyAlastor:OnRelease(brain)
	self.active = nil
end

function Alastor._CustomAiStates.attackFlyAlastor:Evaluate(brain)
	if self.active or brain._submode == "attack" then
		return 0.3
	end
	return 0
end



------------
Alastor._CustomAiStates.attackFlameAlastor = {		-- dodac spr. czy plajer nie wypadl poza
	name = "attackFlameAlastor",
	active = false,
	posFar = 130,
	posClose = 221 - 36,
	distFly = 120,
	distFly2 = 150,
}

function Alastor._CustomAiStates.attackFlameAlastor:OnInit(brain)
	local dist = Dist3D(Player._groundx, 0, Player._groundz, 0,0,0)
	self.PosClose = 220 + FRand(0.6, 1.2)
	--Game:Print("attackFlame "..dist)
	local actor = brain._Objactor
	brain._submode = nil
	self.mode = -1

	local v = Vector:New(Player._groundx, 0, Player._groundz)

	local distPlayerFromCentre = v:Len()
	if distPlayerFromCentre < 0.01 then
		Game:Print("gracz jest w srodku")
		distPlayerFromCentre = 0
		v = Vector:New(actor._groundx, 0, actor._groundz)
	end
	v:Normalize()

	self.dest = Clone(v)
	local d = self.distFly + self.distFly2

	x = v.X * d
	y = self.posFar
	z = v.Z * d

	self._animSpeed = MDL.GetAnimTimeScale(actor._Entity, actor._CurAnimIndex)
	actor.Pos.X = x
	actor.Pos.Y = y
	actor.Pos.Z = z
	ENTITY.SetPosition(actor._Entity, x,y,z)
	--
	self.active = true
end

function Alastor._CustomAiStates.attackFlameAlastor:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == -1 then
		actor._groundx,actor._groundy,actor._groundz = ENTITY.PO_GetPawnFloorPos(actor._Entity)
		actor:RotateToVector(Player._groundx, self.posClose, Player._groundz)
		self.mode = 0
		return
	end

	if self.mode == 0 and not actor._isRotating then
		actor:FlyForward(self.distFly2, nil)
		self.mode = 1
	end
	if self.mode == 1 and not actor._isWalking then
		--Game.freezeUpdate = true
		self.delay = 100
		actor._groundx,actor._groundy,actor._groundz = ENTITY.PO_GetPawnFloorPos(actor._Entity)
		local x,y,z = Player._groundx, self.posClose, Player._groundz
		x = 0
		z = 0
		local v = Clone(self.dest)
		v:MulByFloat(65,66)
		actor:FlyTo(v.X,y,v.Z,false,"fly_up")		-- cel zawsze na ts wysokosci
		self._targetX = x
		self._targetY = y
		self._targetZ = z
		self.mode = 2
        self.speed = self._animSpeed
        self._actorSpeed = actor._Speed
        --MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, self.speed * 1.6)
		return
	end

	if self.mode == 2 then
		if not actor._isWalking then
			if self.delay then
				if not actor._flameFX then
					actor:PlaySound({"alastor_attack2-attack"},40,200,"k_szczeka")
					actor:StartFlame()
				else
					if math.random(100) < 15 then		
						--actor:CheckDamageFromFlame()
						actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
					end
				end
				
				-- fade anim to 1.0
				--MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, self.speed )
				
				self.delay = self.delay - 1
				if self.delay < 0 then
					self.delay = nil
				end
				if self.delay == 10 then
					PARTICLE.Die(actor._flameFX)
				end
			else
				actor._flameFX = nil
				self.delay = math.random(50,90)
				self.mode = 3
				local v = Clone(self.dest)
				v:MulByFloat(self.distFly)
				actor:FlyTo(v.X,self.posFar,v.Z,false,"fly_up")
				--MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, self.speed * 0.6)
			end
		end		
	end

	if self.mode == 3 then
		if not actor._isWalking then
			--Game.freezeUpdate = true
			actor:FlyForward(self.distFly2, nil)
			self.mode = 4
			actor:PlayRandomSound2D({"alastor_ambient-stereo1","alastor_ambient-stereo2","alastor_ambient-stereo3",})
		end
		return
	end
		
	if self.mode == 4 then
		if not actor._isWalking then
			if self.delay then
				self.delay = self.delay - 1
				if self.delay < 0 then
					self.delay = nil
				end
			else
				self.active = false
				self.mode = 0
			end
		end
		return
	end
end

function Alastor._CustomAiStates.attackFlameAlastor:OnRelease(brain)
	self.active = nil
end

function Alastor._CustomAiStates.attackFlameAlastor:Evaluate(brain)
	if self.active or brain._submode == "attackFlame" then
		return 0.3
	end
	return 0
end

--------------

Alastor._CustomAiStates.ABAlastor = {
	name = "ABAlastor",
	active = false,
}

function Alastor._CustomAiStates.ABAlastor:OnInit(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
    actor:Stop()
	if actor._phase == 0 then
		ENTITY.Release(actor._flySound)
		actor._flySound = nil
		local x,y,z = 0,400,0
		actor.Pos.X = x
		actor.Pos.Y = y
		actor.Pos.Z = z
		ENTITY.SetPosition(actor._Entity, x,y,z)
		actor._selfrotate = true
		self.mode = 0
		actor:SetAnim("spada", true)
		
		actor._randomizedParams.RotateSpeed = actor.RotateSpeedGround
		
		self.b1 = actor:BindFX(actor.fallingFX, 1.0, "wing_l_z1_3")
		self.b2 = actor:BindFX(actor.fallingFX, 1.0, "wing_l_z_3")
		self.b3 = actor:BindFX(actor.fallingFX, 1.0, "wing_p_z1_2")
		self.b4 = actor:BindFX(actor.fallingFX, 1.0, "wing_p_z_3")
		--Game:Print(">>> PHASE = 0: spada ")

		ENTITY.PO_EnableGravity(actor._Entity,true)
		ENTITY.SetVelocity(actor._Entity,0,-20,0)
	else
		self.mode = 0
		local dist = math.sqrt(actor._groundx * actor._groundx + actor._groundz * actor._groundz)
		if dist > 5 then
			Game:Print(">>> PHASE > 0: walk to srodek with rotate")
			actor:RotateToVectorWithAnim(0,actor._groundy,0)
		else
			Game:Print(">>> PHASE > 0: walk to srodek with NO rotate")
			self.mode = 1
		end
	end
	self._sound = nil
	self._fallen = false
end

function Alastor._CustomAiStates.ABAlastor:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
	--Game:Print("actor._groundy = "..actor._groundy.." "..brain._velocity)
	if actor._phase == 0 then
		if self.mode == 0 then
			actor._groundx,actor._groundy,actor._groundz = ENTITY.PO_GetPawnFloorPos(actor._Entity)		-- pozniej to tylko raz!
			if actor._groundy < 250 and not self._sound then
				self._sound = true
				actor:BindSound("actor/giant/meteor-fall3",100,400,false)
			end
			
			if actor._groundy < 190 then
				actor._selfrotate = false
				self.mode = 1
				--Game:Print("KOLIZJA! at vel: "..brain._velocityy)
				
				actor:ExplodePhase()

				ENTITY.PO_SetMonsterMovementConst(actor._Entity, self.havokInfluenceInMonsterMovementOnGround, true)
				actor._speedDamping = nil
				actor.enableAIin = 30--(actor.FloorsTimeToDelete) * 30
				ENTITY.SetVelocity(actor._Entity,0,brain._velocityy,0)
				if actor._ragdollWhenFalling then
					actor._isAnimating = false
					ENTITY.PO_Enable(actor._Entity, false)
					MDL.EnableRagdoll(actor._Entity, true, ECollisionGroups.RagdollNonColliding)
					actor.enableAIin = (actor.FloorsTimeToDelete + actor.FloorsTimeToDeleteRandomize) * 30
				end
				ENTITY.SetVelocity(actor._Entity,0,brain._velocityy,0)
				self.delay = 5
				actor.AIenabled = false
			end
		end
		if self.mode == 1 then
			if self.delay then
				self.delay = self.delay - 1
				
				if self.delay == 3 then
					local fx = actor.resurectFX
					if fx then
						local x,y,z = actor:GetJointPos(fx.joint)
						AddPFX(fx.name,fx.size,Vector:New(x,y + fx.deltaY,z))
					end
				end

				if self.delay < 0 then
					self.delay = nil
					if not actor._ragdollWhenFalling then
						actor:SetAnim("idle2",true,nil,0.6)
					end
					Game:Print("!!! koniec spadania")
					--Game.freezeUpdate = true
				end
			else
				--local x,y,z = actor:GetJointPos("root")
				x = 0
				y = 193 - 37
				z = 0
				if actor._ragdollWhenFalling then
					Game:Print("!!! off ragdoll")
					MDL.SetRagdollCollisionGroup(actor._Entity, ECollisionGroups.Ragdoll)
					MDL.EnableRagdoll(actor._Entity, false)
					ENTITY.PO_Enable(actor._Entity, true)
					ENTITY.SetPosition(actor._Entity,x,y,z)
					actor.Pos.X = x
					actor.Pos.Y = y
					actor.Pos.Z = z
					actor:ForceAnim("idle2",true)
					--ENTITY.PO_EnableGravity(actor._Entity,true)
				end				
				Game.MegaBossHealthMax = actor.HealthOnGround
				actor._HealthMax = actor.HealthOnGround
				actor.Health = actor.HealthOnGround
				PARTICLE.Die(self.b1)
				PARTICLE.Die(self.b2)
				PARTICLE.Die(self.b3)
				PARTICLE.Die(self.b4)
				
				actor:ExplodePhase2()

				actor._ABdo = nil
				self.mode = 2
				--Game:Print("ozywianie")
				
			    SOUND.StreamPlay(1) -- od poczatku
				AddObject(Templates["PMusicFade.CProcess"]:New(1,SOUND.StreamGetVolume(1),Cfg.MusicVolume,0.1))
				AddObject(Templates["PMusicFade.CProcess"]:New(0,SOUND.StreamGetVolume(0),0,0.1,"SOUND.StreamPause(0);Lev._fade=false"))
			end
		end
	else
		if self.mode == 0 and not actor._isRotating then
			actor:WalkTo(0,actor._groundy,0)		-- ### uwaga w obrocie mogl przejsc srodek i bedzie sie obracal w animacji
			self.mode = 1
		end
		if self.mode == 1 and not actor._isWalking then
			local dist = math.sqrt(actor._groundx*actor._groundx + actor._groundz*actor._groundz)
			--Game:Print("break_floor distance = "..dist)
			if dist > 12 then
				actor:WalkTo(0,actor._groundy,0)
				self.mode = 0
				if debugMarek then
					--Game:Print("break_floor RETRY")
					--Game.freezeUpdate = true
				end
				return
			end
			actor:FullStop()
			if actor._floorNo == 4 then
				--Game:Print("recharge")
				for i,v in actor._monks do
					v.Immortal = false
					if v.Health > 0 then
						v._pffx = AddPFX("AlastorenergyFX", 1.0, v.particleP, v.particleQ)
					end
				end
				actor:SetAnim("charge",false)
				local fx = actor.chargeFX
				if fx then
                    actor._fxcharge = {}
                    for i,v in fx.joints do
                        table.insert(actor._fxcharge,actor:BindFX(fx.name, fx.scale, v))
                    end
				end
				actor._soundSampleCharge = SOUND2D.Create("actor/alastor/alastor-chargingfigures-stereo-loop")
				SOUND2D.SetLoopCount(actor._soundSampleCharge, 0)
				SOUND2D.Play(actor._soundSampleCharge)
				self.mode = 4
			else
				self.mode = 2
				actor:SetAnim("break_flo",false)
			end
			--Game:Print("break floor")
			return
		end
		if self.mode == 2 then
			if (actor.Animation ~= "break_flo" or not actor._isAnimating) then
				self.mode = 3
				actor:ForceAnim(actor.fallingAnim,true,2.0,0.8)
				actor:ExplodePhase2()
				--Game:Print("end floor")
			end
		end
		if self.mode == 3 then
			--if (actor.Animation ~= "idle2" or not actor._isAnimating) then
			--	actor.Health = actor._HealthMax
			--	actor._ABdo = nil
			--	self.mode = 0
			--	Game:Print("ABdo = false")
			--else
				if not self._fallen then
					local b,d,x,y,z = WORLD.LineTraceFixedGeom(actor._groundx, actor._groundy + 0.5, actor._groundz, actor._groundx, actor._groundy - 2.5, actor._groundz)
					if x then
						actor:FootFX('s_l_kostka')
						actor:FootFX('s_p_kostka')
						actor:PlaySound({'alastor_attacks-naskok'}, 40, 200)
						Game._EarthQuakeProc:Add(Player._groundx,Player._groundy,Player._groundz, actor.StompTimeOut, actor.StompRange, actor.CameraMov, actor.CameraRot, 1.0)
						self._fallen = true
						actor.Health = actor._HealthMax
						actor._ABdo = nil
						self.mode = 0
					end
				end		
			--end
		end
		if self.mode == 4 then
			if (actor.Animation ~= "charge" or not actor._isAnimating) then
				if actor._soundSampleCharge then
					SOUND2D.SetVolume(actor._soundSampleCharge, 0, 0.1)
					SOUND2D.Forget(actor._soundSampleCharge)
					actor._soundSampleCharge = nil
				end
                if actor._fxcharge then
                    for i,v in actor._fxcharge do
                        PARTICLE.Die(v)
                    end
                end

				for i,v in actor._monks do
					if v.Health > 0 then
						v.Immortal = true
						if v._pffx then
							PARTICLE.Die(v._pffx)
							v._pffx = nil
						end
					end
				end
				actor._ABdo = nil
				self.mode = 0
				--Game:Print("ABdo = false")
			else
                local monkNotDestroyed = 0
				for i,v in actor._monks do
					if v.Health > 0 then
						monkNotDestroyed = monkNotDestroyed + 1
					end
				end
				if monkNotDestroyed == 0 and actor._soundSampleCharge then
					SOUND2D.SetVolume(actor._soundSampleCharge, 0, 0.1)
					SOUND2D.Forget(actor._soundSampleCharge)
					actor._soundSampleCharge = nil
				end
			end
		end
	end
end

function Alastor._CustomAiStates.ABAlastor:OnRelease(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if actor._phase == 0 then
		brain._goals = {}
		for i,v in aiParams.aiGoalsGround do
			if not brain:AddState(v) then
				Game:Print(v.." state not found")
			end
		end
		actor._phase = 1
	else
		--if actor._floorNo == 4 then
		--	WORLD.EnableDrawMeshGroup(11, false)		-- wylaczenie rysowania skaly na zewnatrz
		--end
	end
	Game:Print("on release "..actor._floorNo)
end

function Alastor._CustomAiStates.ABAlastor:Evaluate(brain)
	if brain._Objactor._ABdo then
		return 0.2
	end
	return 0.0
end


-------------
function Alastor:OnTick(delta)

--- cheat ---
    if not IsFinalBuild() then
        if INP.Key(Keys.PgUp) == 1 then 
            self:OnDamage(1500, Player,nil,nil,nil,nil,AttackTypes.Rocket,nil,nil,0)
            Game:Print("DAMAGE alastor")
        end
	end
-------------

	if self._flameFX then
		local idx  = MDL.GetJointIndex(self._Entity,"k_szyja")
		local idx2  = MDL.GetJointIndex(self._Entity,"k_glowa")
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx2)
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)

		--q.W, q.X, q.Y, q.Z = LookAtToQuat(x2,y2,z2, x3,y3,z3, 0,0,1)

		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x3,y3,z3) 
	end
	
	if self._isWalking or self._moveWithAnimation then	
		self._delayExplTime = self._delayExplTime - 1
		if self._delayExplTime < 0 then
			if self._flying then
				self._delayExplTime = 4
			else
				self._delayExplTime = 12
			end
			local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
			v:Normalize()
			v:MulByFloat(7.0)
			local x,y,z = self._groundx,self._groundy,self._groundz
			if self._flying then
				y = y + 2
			else
				y = y + 6
			end

			self.DEBUGl1 = x + v.X
			self.DEBUGl2 = y
			self.DEBUGl3 = z + v.Z
			WORLD.Explosion2(x+v.X, y, z+v.Z, 5000, --[[range--]]8,nil,AttackTypes.Rocket,self.AiParams.walkDamage)
			if math.random(100) < 15 then
				PlayLogicSound("EXPLOSION",x+v.X, y, z+v.Z,16,32)
			end
		end
	end
	
	if self._selfrotate then
		self.angle = self.angle + self.fallingRotateSpeed * delta
		self._angleDest = self.angle
		ENTITY.SetOrientation(self._Entity,self.angle)
	end
end



-----------------------------
function Alastor:ExplodePhase2()
    local actor = self
    local aiParams = self.AiParams
	if self._floorNo == 2 then
		PHYSICS.ActiveMeshGroupEnable(5, true)		-- 3 korona
		PHYSICS.ActiveMeshGroupSetActivationParams(5, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
						self.StoneParams.miminalMassReportingCollision,
						self.StoneParams.maximalMassReportingCollision, self.StoneParams.amountReportingCollisions * 100,
						self.StoneParams.timeToLive,self.StoneParams.timeToLiveRandomize)
						
	end
	if self._floorNo == 3 then
		PHYSICS.ActiveMeshGroupEnable(9, true)
		PHYSICS.ActiveMeshGroupEnable(18, true)		-- 4 korona
		PHYSICS.ActiveMeshGroupSetActivationParams(9, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
						self.StoneParams.miminalMassReportingCollision,
						self.StoneParams.maximalMassReportingCollision, self.StoneParams.amountReportingCollisions * 100,
						self.StoneParams.timeToLive,self.StoneParams.timeToLiveRandomize)
		PHYSICS.ActiveMeshGroupSetActivationParams(18, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
						self.StoneParams.miminalMassReportingCollision,
						self.StoneParams.maximalMassReportingCollision, self.StoneParams.amountReportingCollisions * 100,
						self.StoneParams.timeToLive,self.StoneParams.timeToLiveRandomize)
	end
	if self._floorNo == 4 then
		self.AiParams.towerRadius = self.AiParams.towerRadiusBottom
		self.AiParams.towerRange = self.AiParams.towerRangeBottom
		PHYSICS.ActiveMeshGroupEnable(8, true)
		PHYSICS.ActiveMeshGroupSetActivationParams(8, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
						self.StoneParams.miminalMassReportingCollision,
						self.StoneParams.maximalMassReportingCollision, self.StoneParams.amountReportingCollisions * 100,
						self.StoneParams.timeToLive,self.StoneParams.timeToLiveRandomize)

		WORLD.SetCollisionGroupMeshGroup(12, ECollisionGroups.Fixed)
	end
end

function Alastor:ExplodePhase()
    local actor = self
    local aiParams = self.AiParams
	Game._EarthQuakeProc:Add(Player._groundx,Player._groundy,Player._groundz, self.StompTimeOut, self.StompRange, self.CameraMov, self.CameraRot, 1.0)
	PlaySound2D("actor/giant/giant_hit-ground")
	if self._floorNo == 1 then
		PHYSICS.ActiveMeshGroupSetActivationParams(2, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
			self.StoneParams.miminalMassReportingCollision,	1000000.0, self.StoneParams.amountReportingCollisions * 100)
	
		PHYSICS.ActiveMeshGroupEnable(2, true)		-- 2 podloga
         PHYSICS.ActiveMeshGroupEnable(14, true)    -- ?
		WORLD.EnableDrawMeshGroup(5, true)			-- 3 korona 
		WORLD.EnableDrawMeshGroup(6, true)			-- 3 podloga
		WORLD.EnableDrawMeshGroup(16, true)			-- 3 podloga
		PHYSICS.ActiveMeshGroupStaticMeshEnable(5, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(6, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(16, true)

		if self.floorsCollisionGroup then
			WORLD.SetCollisionGroupMeshGroup(2, self.floorsCollisionGroup)
			WORLD.SetCollisionGroupMeshGroup(1, self.floorsCollisionGroup)
			WORLD.SetCollisionGroupMeshGroup(14, self.floorsCollisionGroup)
		end

		if self.nextFloorCollisionGroup then
			WORLD.SetCollisionGroupMeshGroup(6, self.nextFloorCollisionGroup)
		end

		if debugMarek then
			DebugSphereX,DebugSphereY,DebugSphereZ = self._groundx,200,self._groundz
			DebugSphereRange = aiParams.Explosion.ExplosionRange / 2
		end

		WORLD.Explosion2(self._groundx,200,self._groundz, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)

		--[[for i=1,4 do
			local angle = FRand(0, 6.28)	
			local dist = math.random(30, 40)
			local x = math.sin(angle) + math.cos(angle)
			local z = math.cos(angle) - math.sin(angle)
			x = x * dist
			y = 180
			z = z * dist
			WORLD.Explosion2(x,y,z, aiParams.Explosion.ExplosionStrength,16,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)		
		end	--]]	
		
		WORLD.SetTimeToDeleteMeshGroup(14, self.WallsTimeToDelete, self.WallsTimeToDeleteRandomize, true)	-- 1 korona
		WORLD.SetTimeToDeleteMeshGroup(1,self.CoronasTimeToDelete, self.CoronasTimeToDeleteRandomize, true)	-- 1 boczna
		WORLD.SetTimeToDeleteMeshGroup(2, self.FloorsTimeToDelete, self.FloorsTimeToDeleteRandomize, false)	-- 2 podloga

	end

	if self._floorNo == 2 then
		PHYSICS.ActiveMeshGroupSetActivationParams(6, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
			self.StoneParams.miminalMassReportingCollision,	1000000.0, self.StoneParams.amountReportingCollisions * 100)

		PHYSICS.ActiveMeshGroupEnable(6, true)		-- 3 podloga
		WORLD.EnableDrawMeshGroup(9, true)
		WORLD.EnableDrawMeshGroup(10, true)			-- ost. podloga
		WORLD.EnableDrawMeshGroup(16, true)
		WORLD.EnableDrawMeshGroup(18, true)			-- 4 korona
		--WORLD.EnableDrawMeshGroup(11, true)

		PHYSICS.ActiveMeshGroupStaticMeshEnable(9, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(10, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(16, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(18, true)
		--PHYSICS.ActiveMeshGroupStaticMeshEnable(11, true)
		
		if self.floorsCollisionGroup then
			WORLD.SetCollisionGroupMeshGroup(6, self.floorsCollisionGroup)
			WORLD.SetCollisionGroupMeshGroup(5, self.floorsCollisionGroup)
			WORLD.SetCollisionGroupMeshGroup(16, self.floorsCollisionGroup)
		end
		if self.nextFloorCollisionGroup then
			WORLD.SetCollisionGroupMeshGroup(10, self.nextFloorCollisionGroup)
		end
		
		WORLD.Explosion2(0,160,0, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)

		WORLD.SetTimeToDeleteMeshGroup(16, self.WallsTimeToDelete, self.WallsTimeToDeleteRandomize, true)
		WORLD.SetTimeToDeleteMeshGroup(5,self.CoronasTimeToDelete, self.CoronasTimeToDeleteRandomize, true)
		WORLD.SetTimeToDeleteMeshGroup(6, self.FloorsTimeToDelete, self.FloorsTimeToDeleteRandomize, false)-- 3 podloga
	end

	if self._floorNo == 3 then
		for i,v in self._monks do
			ENTITY.EnableDraw(v._Entity,true)
		end

		PHYSICS.ActiveMeshGroupSetActivationParams(10, true, self.StoneParams.collisionMinimumFrequency, self.StoneParams.collisionMinimumStrength,
			self.StoneParams.miminalMassReportingCollision,	1000000.0, self.StoneParams.amountReportingCollisions * 100)

		PHYSICS.ActiveMeshGroupEnable(10, true)		-- 4 podloga

		WORLD.EnableDrawMeshGroup(12, true)
		WORLD.EnableDrawMeshGroup(8, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(12, true)
		PHYSICS.ActiveMeshGroupStaticMeshEnable(8, true)
		if self.floorsCollisionGroup then
			WORLD.SetCollisionGroupMeshGroup(10, self.floorsCollisionGroup)
			WORLD.SetCollisionGroupMeshGroup(18, self.floorsCollisionGroup)
			WORLD.SetCollisionGroupMeshGroup(9, self.floorsCollisionGroup)
		end
		if self.floorsCollisionGroup then
			WORLD.SetCollisionGroupMeshGroup(12, self.nextFloorCollisionGroup)		-- ###
		end

		WORLD.Explosion2(0,125,0, aiParams.Explosion.ExplosionStrength,aiParams.Explosion.ExplosionRange,nil,AttackTypes.Rocket,aiParams.Explosion.Damage)

		WORLD.SetTimeToDeleteMeshGroup(18,self.CoronasTimeToDelete, self.CoronasTimeToDeleteRandomize, true)	-- 3 boczna
		WORLD.SetTimeToDeleteMeshGroup(9, self.CoronasTimeToDelete, self.CoronasTimeToDeleteRandomize, true)
		WORLD.SetTimeToDeleteMeshGroup(10, self.FloorsTimeToDelete, self.FloorsTimeToDeleteRandomize, false)	-- 4 podloga
	end
	self._floorNo = self._floorNo + 1	
	if C4L4_Alastor then
		C4L4_Alastor._floorNo = self._floorNo
	end
end


function Alastor:Throw()
	local aiParams = self.AiParams
    local brain = self._AIBrain

	local Joint = MDL.GetJointIndex(self._Entity, "d_l_5_3")
	local x,y,z = MDL.TransformPointByJoint(self._Entity,Joint,0,0,0)
	local v2 = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v2:Normalize()
	x = x + v2.X * 3.0
	z = z + v2.Z * 3.0
	local e, obj = AddItem("FireBallAlastor.CItem",nil,Vector:New(x,y,z),true)
	obj.ObjOwner = self
	obj.Pos.X = x
	obj.Pos.Y = y
	obj.Pos.Z = z
	obj:Apply()
	obj:Synchronize()
	self._objTakenToThrow = obj
	brain._enemyLastSeenPoint.X = Player._groundx
	brain._enemyLastSeenPoint.Y = Player._groundy
	brain._enemyLastSeenPoint.Z = Player._groundz
	self:ThrowTaken(nil, true)
end

function Alastor:StrikeGround()
	local x,y,z = self:GetJointPos("d_p_5_3")
	WORLD.Explosion2(x, self._groundy + 1.0, z, 5000, --[[range--]]7,nil,AttackTypes.Rocket,self.AiParams.strikeDamage)
	if debugMarek then
		Game:Print("strike ground")
		self._debugdx3 = x
		self._debugdy3 = self._groundy + 1.0
		self._debugdz3 = z
		self.d1 = x
		self.d2 = y
		self.d3 = z
		self.d4 = x
		self.d5 = y - 3.0
		self.d6 = z
	end
	
	if self.FXwhenHit then
		AddObject(self.FXwhenHit,1.0, Vector:New(x,y,z), nil, true)
	end
	
	if self.HitDecal then
		local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x,y,z,x,y - 3.0,z)
		if e then
			--Game:Print("spawn decal")
			ENTITY.SpawnDecal(e,self.HitDecal,x,y,z,0,1,0, 10)
		end
	end

end

function Alastor:StartFlame()
	if not self._flameFX then
		local idx  = MDL.GetJointIndex(self._Entity,"k_szyja")
		local idx2  = MDL.GetJointIndex(self._Entity,"k_glowa")
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx2)
		
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)

		if debugMarek then
			self.yaadebug1 = x2
			self.yaadebug2 = y2
			self.yaadebug3 = z2
			self.yaadebug4 = x3
			self.yaadebug5 = y3
			self.yaadebug6 = z3
		end
		
		
		local size = 2.3
		if self.Animation ~= "zieje02" and self.Animation ~= "zieje02a" then
			if self._phase == 0 then
				size = 1.8
			else
				if self._floorNo ~= 4 then
					size = 1.4
				end
			end
		end
		
		--Game:Print("PARTICLE size "..size)
		
		self._flameFX = AddPFX(self.flamerFX, size, Vector:New(x3,y3,z3), q)
	end
end

function Alastor:Stomp(joint, modif)
	local p = modif
	if not p then
		p = 1.0
	end
	local x,y,z = self:GetJointPos(joint)
	Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange * p, self.CameraMov * p, self.CameraRot * p, 1.0)
	--WORLD.Explosion2(x, y + 3, z, 1000, --[[range--]]5,self._Entity,AttackTypes.Rocket,200)
	self:FootFX(joint)
end

function Alastor:FootFX(joint)
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    AddPFX('but',0.8,Vector:New(x,y,z))
end

function Alastor:CreateMonks()
	local monks = rawget(getfenv(),"monks")
	self._monks = {}

    if monks then
		local h = 1
        for i,v in monks.Points do
            local r = Clone(Quaternion)
		    r:FromEulerZYX(0,-v.A+math.pi/2,0)
            --local r = q:FromEulerZYX(0,-v.A+math.pi/2,0)
            local obj, e = AddObject("MonkStatue.CItem",nil,Vector:New(v.X,v.Y + 8,v.Z),r,true)
            ENTITY.PO_SetPinned(e,true)
            obj.Immortal = true
            obj.particleQ = Quaternion:New(unpack(self.particles[h]))
            obj.particleP = Vector:New(unpack(self.particles[h+1]))
            h = h + 2
            table.insert(self._monks, obj)
        end
    end
end

function Alastor:Charge()
	--Game:Print("charge!")
	if self.Health < self._HealthMax then
		for i,v in self._monks do
			if v.Health > 0 then
				self.Health = self.Health + self._HealthMax * 1/80
			end
		end
	end
	if self.Health > self._HealthMax then
		self.Health = self._HealthMax
	end
end

function Alastor:EndFlame()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
end

function Alastor:EnableRotate()		-- zeby w powietrzu mogl sie obracac
	self._canRotate = true
end

function Alastor:DisableRotate()
	self._canRotate = false
end




------------
Alastor._CustomAiStates.groundAttackAlastor = {
	name = "groundAttackAlastor",
	active = false,
	
	-- atak1 - 27 <- przebyty dystans
	-- atak2 - 30
	-- atak3 - 27
	
	--atak1minDistance = 54.0,	-- fireball
	atak3minDistance = 35.0,	-- atak lapami
	minAttackDistance = 25.0,
}

function Alastor._CustomAiStates.groundAttackAlastor:OnInit(brain)
	--Game:Print("gr attack "..brain._distToNearestEnemy)
	local actor = brain._Objactor
	self.atak1minDistance = actor.AiParams.breathAttackDistMin
	brain._submode = nil
	--self.mode = 0
	self.active = true
	actor:SetAnim("idle1",false)
	actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
	--actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
	self.attackMode = false
	self.breathPoints = rawget(getfenv(),"alastorBreath")
	self.breathPointsWrong = rawget(getfenv(),"alastorBreathWrong")
end

function Alastor._CustomAiStates.groundAttackAlastor:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
	
	if not self.attackMode then
		if actor._ABdo then
			self.active = false
			actor:Stop()
			return
		end
		--if true then return end

		if not actor._isRotating and not actor._isWalking then
			if debugMarek then Game:Print("GRACZ DYSTANS: "..brain._distToNearestEnemy) end
			if brain._distToNearestEnemy < self.minAttackDistance then
				-- gracz jest blisko: obrot o 180, albo idzie na gracza
				if math.random(100) < 70 + actor._pissedOffRatio * 20 then
					--actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
					local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
					v:Normalize()
					
					
					-- sprawdzanie, zeby nie spadl 
					local dist = 40
					local ok = false
					while not ok do
						local distTarget = Dist3D(actor._groundx + v.X*dist, 0, actor._groundz + v.Z*dist, 0,0,0)	-- narazie
						if distTarget < aiParams.towerRadius then		-- poza wieza (44min, 47max)
							--Game:Print(aiParams.towerRadius.."OBROT dist = "..dist.." "..distTarget)
							ok = true
						else
							dist = dist - 5
							if dist < 10 then
								--Game:Print("OBROT o 180")
								actor:RotateWithAnim(180)
								return
							end
						end
					end
					--
					actor:WalkTo(actor._groundx + v.X*dist, actor._groundy, actor._groundz + v.Z*dist)
				else
					local v = Vector:New(Player._groundx - actor._groundx, 0, Player._groundz - actor._groundz)
					v:Normalize()
					local angleToPlayer = math.atan2(v.X, v.Z)
					local aDist = AngDist(actor.angle, angleToPlayer)
					if debugMarek then Game:Print("GRACZ ANGLE: "..(aDist*180/math.pi)) end

					if math.random(100) < 30 then
						if math.abs(aDist) > 60.0 * math.pi/180 and brain._distToNearestEnemy > 8 then
							actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
							if debugMarek then Game:Print("zly kat zeby ziac!!!!!!!!!!!!!!!!!") end
							--Game.freezeUpdate = true
							return
						end
					
						actor:SetAnim("zieje01",false)
						self.attackMode = "zieje01"
						--Game:Print("zieje01 close")
						return
					end
					
					if math.abs(aDist) > 90.0 * math.pi/180 and brain._distToNearestEnemy > 10 then
						actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
						if debugMarek then Game:Print("zly kat zeby idle!!!!!!!!!!!!!!!!!") end
						return
					end

					if math.random(100) < 5 and actor._floorNo < 3 then
						actor:SetAnim("idle1",false)
						self.attackMode = "idle1"
						--Game:Print("idle1 close")
						return
					end
					if math.random(100) < 15 then
						actor:SetAnim("idle2",false)
						self.attackMode = "idle2"
						--Game:Print("idle2 close")
						return
					else
						actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
						--Game:Print("rotate close")
					end
				end
			else
				local v = Vector:New(Player._groundx - actor._groundx, 0, Player._groundz - actor._groundz)
				v:Normalize()
				local angleToPlayer = math.atan2(v.X, v.Z)
				local aDist = AngDist(actor.angle, angleToPlayer)

				if math.abs(aDist) > 30.1 * math.pi/180 then
					actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
					return
				end

				local dist = Dist2D(Player._groundx, Player._groundz, 0,0)
				local distSelf = Dist2D(actor._groundx, actor._groundz, 0,0)
				if debugMarek then
					self.a = actor._groundx
					self.c = actor._groundz
					--Game:Print("player at "..dist.." dy = "..(actor._groundx - Player._groundx))
				end
				actor._canRotate = false
				actor._moveWithAnimationDoNotUpdateAngle = false
				if math.random(100) < 4 - (actor._pissedOffRatio * 10) then
					actor:SetAnim("idle2",false)
					self.attackMode = "idle2"
					--Game:Print("idle2")
					return
				end

				-- sprawdzanie czy nie spadnie w ataku
				local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
				v:Normalize()
				v:MulByFloat(self.minAttackDistance + 4.0)		-- narazie tyle dla wszystkich animacji
				local distAtEnd = math.sqrt((actor._groundx + v.X)*(actor._groundx + v.X) + (actor._groundz + v.Z)*(actor._groundz + v.Z))
				if distAtEnd > aiParams.towerRange and dist <= aiParams.towerRange then		-- moze czasmi walk?
					--Game:Print("NIE moze atakowac bo dist po skoku przekroczy zakres")
					-- todo: odchodzi
					actor:RotateToWithAnim(0,actor._groundy,0)
					self.mode = 0
					self.attackMode = "WALKAWAY"
					return
				end
				--

				if actor._floorNo == 4 then
					-- czy gracz jest poza kolumnami
					if dist > aiParams.towerRange and distAtEnd >= aiParams.towerRange then		-- a co jesli idzie i gracz mu sie pojawi
						--Game:Print("gracz poza "..dist.." "..distAtEnd)
						--Game.freezeUpdate = true
						local p = self.breathPoints
						local closest = 999
						local ok = true
						if p then
							self.destPoint = nil
							for i,v in p.Points do
								local dist = Dist3D(Player._groundx, 0, Player._groundz, v.X, 0, v.Z)
								if dist < closest then
									closest = dist
									self.destPoint = v
								end
							end
							local p2 = self.breathPointsWrong
							for i,v in p2.Points do
								local dist = Dist3D(Player._groundx, 0, Player._groundz, v.X, 0, v.Z)
								if dist < closest then
									closest = dist
									ok = false
									--Game:Print("point wrong pos")
									--self.destPoint = v
								end
							end

						end
						if closest < 45 then
							if not ok or math.random(100) < 6 then
								--Game:Print("walkaway w breath")
								--Game.freezeUpdate = true
								actor:RotateToWithAnim(0,actor._groundy,0)
								self.mode = 0
								self.attackMode = "WALKAWAY"
								return
							end
							local distToPoint = Dist3D(self.destPoint.X, 0, self.destPoint.Z, actor._groundx, 0, actor._groundz)
							--Game:Print("Najblizszy punkt "..closest.." do niego: "..distToPoint)
							if distToPoint > 10 then
								actor:RotateToVectorWithAnim(self.destPoint.X, self.destPoint.Y, self.destPoint.Z)
								--Game:Print("punkt daleko")
							end
							brain._point = self.destPoint
							brain._submode = "breath"
							self.mode = 0
							self.active = false
							return
						else
							--Game:Print("gracz jest za kolumnami, ale jest daleko")
						end
					end
				end

				--[[
				if actor._floorNo < 3 then
					if math.random(100) < 4 - (actor._pissedOffRatio * 10) then
						actor:SetAnim("idle1",false)
						self.attackMode = "idle1"
						Game:Print("idle")
						return
					end
				end
				--]]

				if brain._distToNearestEnemy < self.atak3minDistance then
					actor:SetAnim("atak3", false)
					self.attackMode = "atak3"
					return
				else
					if brain._distToNearestEnemy < self.atak1minDistance then		-- przedzial miedzy 35 i 40 jest niejsany
						actor:SetAnim("atak2", false)
						self.attackMode = "atak2"
						--Game:Print("atak2")
						return
					else
						if (math.random(100) < 25 and dist < 40) or (distSelf > 33 and actor._floorNo < 4) then		-- dist - odl. gracza od srodka
							actor:WalkTo(Player._groundx, Player._groundy, Player._groundz, false, FRand(20, 40))
							--Game:Print("walkTo PLAYER")
						else
							actor:SetAnim("atak1", false)
							self.attackMode = "atak1"
							--Game:Print("atak1")
							return
						end
					end
				end
			end
		end
	else
		if self.attackMode == "WALKAWAY" then
			if self.mode == 0 and not actor._isRotating then
				actor:WalkTo(0,actor._groundy,0, false, FRand(26,42))
				self.mode = 1
			end
			if self.mode == 1 and not actor._isWalking then
				--Game:Print("koniec walkaway")
				self.attackMode = false
			end
			return
		end
		if not actor._isAnimating then
			if self.attackMode == "atak2" then
				if actor._flameFX then
					PARTICLE.Die(actor._flameFX)
					actor._flameFX = nil
				end
			end
			if debugMarek and self.c and self.attackMode and self.a then
				local dist2 = Dist3D(actor._groundx, 0, actor._groundz, self.a,0,self.c)
				--Game:Print("kniec atakmode "..self.attackMode.." przebyty dystans = "..dist2)
			end
			self.attackMode = false
			actor._moveWithAnimationDoNotUpdateAngle = true
		else
			if actor._canRotate then
				actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
			else
				if actor._isRotating then
					actor:FullStop()
				end
			end
			--if self.attackMode == "atak2" then
				--if actor._flameFX and  math.random(100) < 15 then		
				--	actor:CheckDamageFromFlame()
				--end
			--end
		end
	end
end

function Alastor._CustomAiStates.groundAttackAlastor:OnRelease(brain)
	self.active = nil
	local actor = brain._Objactor
	actor:EndFlame()
end

function Alastor._CustomAiStates.groundAttackAlastor:Evaluate(brain)
	if self.active then
		return 0.3
	end
	return 0.1
end




------------
Alastor._CustomAiStates.breathAlastor = {
	name = "breathAlastor",
	active = false,
}

function Alastor._CustomAiStates.breathAlastor:OnInit(brain)
	brain._submode = nil
	self.mode = 0
	self.active = true
	--Game:Print("breath alastor <<<<")
end

function Alastor._CustomAiStates.breathAlastor:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams

	if self.mode == 0 and not actor._isRotating then
		local distToPoint = Dist3D(brain._point.X, 0, brain._point.Z, actor._groundx, 0, actor._groundz)
		--Game:Print("distToPoint "..distToPoint)
		if distToPoint > 1.2 then
			actor:WalkTo(brain._point.X, brain._point.Y, brain._point.Z)
		end
		self.mode = 1
		return
	end
	if self.mode == 1 then
		if not actor._isWalking then
			-- dodac sprawdzanie, czy doszedl
			--Game:Print("doszedl")
			self.angleDest = (math.atan2(-brain._point.X, -brain._point.Z) + math.pi) * 180/math.pi
			self.mode = 2
			return
		else
			local dist = Dist3D(Player._groundx, 0, Player._groundz, 0,0,0)
			local distFromPoint = Dist3D(Player._groundx, 0, Player._groundz, brain._point.X,0,brain._point.Z)
			if dist < 70 or distFromPoint > 70 then
				actor:Stop()
				self.active = false
				--Game:Print("gracz wyszedl z zwenetrznej "..dist.." dist from point = "..distFromPoint)
				return
			end
		end
	end
	if self.mode == 2 and not actor._isRotating then
		-- Game.freezeUpdate = true
		--Game:Print("koniec obrotu z animacja")
		actor:RotateTo(self.angleDest)
		if math.random(100) < 50 then
			actor:SetAnim("zieje02", false)
		else
			actor:SetAnim("zieje02a", false)
		end
		self.mode = 3
	end
	if self.mode == 3 and (not actor._isAnimating or not (actor.Animation == "zieje02" or actor.Animation == "zieje02a")) then
		self.active = false
		if actor._flameFX then
			PARTICLE.Die(actor._flameFX)
			actor._flameFX = nil
		end
	end
end

function Alastor._CustomAiStates.breathAlastor:OnRelease(brain)
	local actor = brain._Objactor
	brain._point = nil
	actor._moveWithAnimationDoNotUpdateAngle = true
	actor:EndFlame()
end


function Alastor._CustomAiStates.breathAlastor:Evaluate(brain)
	if self.active or brain._submode == "breath" then
		return 0.3
	end
	return 0
end



function Alastor:CustomOnDeathUpdate()
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			self._demonfx = Game:EnableDemon(true, 10, false, 0.25)
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end
