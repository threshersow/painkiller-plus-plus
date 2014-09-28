function o:OnPrecache()
	Cache:PrecacheDecal(self.ShockWave.HitDecal)
    Cache:PrecacheActor(self.ShockWave.FXwhenHit)
	    Cache:PrecacheItem(self.AiParams.ThrowableItem2)
end


function o:OnInitTemplate()
    self:SetAIBrain()
    self._phase = 0
    self._phaseCounter = 1
end

function o:CustomOnDamage(he,x,y,z,obj, damage, type,nx,ny,nz)
	if type == AttackTypes.Step or obj == self then
		return true
	end
	if self._phase == 1 then
		if type == AttackTypes.Shotgun or type == AttackTypes.MiniGun or type == AttackTypes.Painkiller or 
			type == AttackTypes.Rifle or type == AttackTypes.PainkillerRotor or type == AttackTypes.Shuriken then
			self:PlaySoundHit("hit")
			if z then
				local s = self.s_SubClass.ParticlesDefinitions.hitImmortal
				local q
				if nz then
					q = Quaternion:New_FromNormal(-nx,-ny,-nz)
				end
				AddPFX(s.pfx,s.scale,Vector:New(x,y,z),q)
			end
		end
		if type == AttackTypes.Stake then
			PlaySound3D('impacts/stake-shield'..math.random(1,3),x,y,z,12,36,false)
		end
	else
		self:PlaySoundHit("hit2")
	end    
	if self._deathDone then
		return false
	end
	if self._doDeath then
		return true
	end
    if self._phase == 0 then
		if (self.Health - damage) < (1 - self.fisrtPhaseHP * self._phaseCounter) * self._HealthMax then
			self._phase = 1
			--Game:Print("phase = 1")
			self:AddPFX("AB")
			self.AiParams.throwItemBindTo = "k_sz"
			self.AiParams.throwMaxAngleYawDiff = 30.0
			self.AiParams.throwVelocity = self.AiParams.throwVelocityFireball
			self.AiParams.homingMissileAngleChangeSpeed = self.AiParams.homingMissileAngleChangeSpeedF
			self.AiParams.throwMaxAnglePitchDiff = 30.0
			self.AiParams.throwItemBindToOffset = self.AiParams.throwItemBindToOffsetFireball
			--Game:Print("SH = "..(self.Health - damage).." "..(1 - self.fisrtPhaseHP * self._phaseCounter) * self._HealthMax)
			self.Health = (1 - self.fisrtPhaseHP * self._phaseCounter) * self._HealthMax + 1

			self._immPFX = {}
			local p = self.s_SubClass.ParticlesDefinitions.isImmortal
			for i,v in self.s_SubClass.DeathJoints do
				table.insert(self._immPFX, self:BindFX(p.pfx, p.scale, v))
			end
			return true
		end
    end
    if self._phase == 1 then
		if type == AttackTypes.Tank and self._delayShock then
			self._delayShock = nil
			--Game:Print("phase = 0 "..self.Health.." "..damage)
			self.AiParams.throwItemBindTo = "root"
			self.AiParams.throwMaxAngleYawDiff = 5
			self.AiParams.throwMaxAnglePitchDiff = 5
			self.AiParams.homingMissileAngleChangeSpeed = self.AiParams.homingMissileAngleChangeSpeedR
			self.AiParams.throwVelocity = self.AiParams.throwVelocityRockets
			self.AiParams.throwItemBindToOffset = nil
			self._phaseCounter = self._phaseCounter + 1
			if self._immPFX then
				for i,v in self._immPFX do
					PARTICLE.Die(v)
				end
			end
			if self._sndloop then
				ENTITY.Release(self._sndloop)
				self._sndloop = nil
			end

			self._immPFX = nil
			self._phase = 0
			if (self.Health - damage) > 0 then
				self:PlaySound("hit2")
			else
				--Game:Print("do death")
				self._doDeath = true
				if not self._deathDone then
					return true
				end
			end
			return false
		end
		return true
	end    
end

function o:CustomOnDeathAfterRagdoll()
	local x,y,z = self.Pos.X,self.Pos.Y,self.Pos.Z
	local amount = 3
	MDL.ApplyVelocitiesToAllJoints(self._Entity,FRand(-amount,amount),FRand(-amount,amount),FRand(-amount,amount),FRand(-amount,amount),FRand(-amount,amount),FRand(-amount,amount))
	MDL.RagdollSelfExplosion(self._Entity,x,y+self.s_SubClass.GibExplosionDeltaY,z,self.s_SubClass.GibExplosionStrength,self.s_SubClass.GibExplosionRange)
	local s = self.ShockWave
    Game._EarthQuakeProc:Add(x,y,z, s.eqTimeOut*3, s.eqRange*1.8, s.eqCameraMove*1.2, s.eqCameraMove*1.2, 1.0)
    MDL.SetRagdollAngularDamping(self._Entity,0.4)
    MDL.SetRagdollLinearDamping(self._Entity,0.1)
    self:PlaySound("deathVoice")
    self:EndFlame()
    --Game:Print("---CustomOnDeathAfterRagdoll")
   	Game.MegaBossHealthMax = nil
	Game.MegaBossHealth = nil
	self._timerToDemon = 0
end

	
function o:CustomOnDeathUpdate()
	if self._timerToDemon then
		self._timerToDemon = self._timerToDemon - 1
		if self._timerToDemon <= 0 then
			self._demonfx = Game:EnableDemon(true, 10, false, 1.0)
			self._timerToDemon = nil
		end
	else
		if self._demonfx and self._demonfx.TickCount > self._demonfx.EffectTime - 1.0 then
			self._demonfx = nil
			GObjects:Add(TempObjName(),CloneTemplate("EndLevel.CProcess"))
		end
	end
end



function o:StdRagdollOnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl, velocity_me, velocity_other)
	local j = MDL.GetJointFromHavokBody(self._Entity, h_me)
	if j and j ~= -1 then
		if self._raggDollPrecomputedCollData[j] then
            local name	-- = ""
            --local sndDir = ""
            if self._frozen then
				name = "frozenSplash"
			else
				name = self._raggDollPrecomputedCollData[j][1]
			end
			AddPFX('but',0.6,Vector:New(x,y,z))
            self:PlaySound(name,nil,nil,nil,nil,x,y,z)
		end
	end
end

function o:OnCreateEntity()
	--self:BindFX("pochodnia",0.5,"root",5.0,6,-3.2)		-- przod, dol, lewo
	--self:BindFX("pochodnia",0.5,"root",5.0,6,3.2)
	
	--Game:Print("sphere size = "..self._SphereSize)
	--ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	--self._disableRotatingWhileWalking = true
	self._walkWithAngle = true
	self.disbleRotWhenStartWalk = true
	self._panzer = true
	--ENTITY.EnableCollisions(self._Entity, true, 0.2)


	--MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	--ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	--ENTITY.PO_SetMovedByExplosions(self._Entity, false)
--    self._walkAnimSpeed = 0.1 * self._randomizedParams.WalkSpeed * self.s_SubClass.Animations.walk[1]
	Game.MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health	
end

function o:WalkDamage()
    if not self._walkDamage then
        self._walkDamage = 1
    end
	local a = {"leg_1_3","leg_2_3","leg_4_3","leg_3_3"}
	local x,y,z = self:GetJointPos(a[self._walkDamage])
	self._walkDamage = self._walkDamage + 1
	if self._walkDamage > 4 then
		self._walkDamage = 1
	end
	WORLD.Explosion2(x,y,z, self.AiParams.explosionWhenWalkStreng*0.2, self.AiParams.explosionWhenWalkRange*0.7, nil, AttackTypes.Step, self.AiParams.explosionWhenWalkDamage*0.5)
end

function o:Stomp(joint, modif)
	--if debugMarek then return end
	local p = modif
	if not p then
		p = 1.0
	end
	local x,y,z = self:GetJointPos(joint)

	Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange * p, self.CameraM * p, self.CameraM * p, 1.0)
	if debugMarek then
		DebugSphereX = x
		DebugSphereY = y
		DebugSphereZ = z
		DebugSphereRange = self.AiParams.explosionWhenWalkRange
	end
	WORLD.Explosion2(x,y,z, self.AiParams.explosionWhenfStreng, self.AiParams.explosionWhenWalkRange, nil, AttackTypes.Step, self.AiParams.explosionWhenWalkDamage)
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    AddPFX('but',1.2,Vector:New(x,y,z))
    
    local b,d,x2,y2,z2,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x,y+1,z, x,y-2,z)
    --self.d1,self.d2,self.d3 = x,y+1,z
    --self.d4,self.d5,self.d6 = x,y-2,z
	if e then
		ENTITY.SpawnDecal(e,self.AiParams.walkDecal,x2,y2,z2,nx,ny,nz)
	end
    
end


o._CustomAiStates = {}
o._CustomAiStates.idleSpider = {
	lastTimeAmbientSound = 0,
	lastAmbient = -2,
	name = "idleSpider",
}

function o._CustomAiStates.idleSpider:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:SetIdle()
	self.delay = nil
	self.GuardStill = aiParams.GuardStill
	self.timeChangeStillToFalse = nil
	self.walked = false
	self._submode = "idle"
	self._mode = nil
	self._walkAfterRot = false
	self.lastTimeOnAttack = brain._currentTime
	
	self.traceCounter = 1
	self.traceTable = {}
    local i = 0
	local j = 1
	while i < 359 do
		self.traceTable[j] = 100 + FRand(-1,1)
		i = i + 45
		j = j + 1
	end

	self._startDelay = 0.5
end

function o._CustomAiStates.idleSpider:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	local angleToPlayer = math.atan2(brain._enemyLastSeenPoint.X - actor._groundx, brain._enemyLastSeenPoint.Z - actor._groundz)
	local aDist = AngDist(actor.angle, angleToPlayer)

	
	self._startDelay = self._startDelay - 1/30	

	--if self.changePosOrEscapeInProgress then
	--	if not actor._isWalking then
	--		Game:Print("change pos finished")
	--		self.changePosOrEscapeInProgress = nil
	--	end
	--end
	
	--------------
	local idx  = MDL.GetJointIndex(self._Entity,"root")
	--local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx,0,0,0)
	--y2 = y2 + FRand(2,3)
	
	local x2,y2,z2 = actor.Pos.X,actor.Pos.Y,actor.Pos.Z

	local angle = self.traceCounter * 45 * math.pi/180
	local v = Vector:New(math.sin(angle), 0, math.cos(angle))
	v:Normalize()
	v:MulByFloat(50)

	local b3,d3 = WORLD.LineTraceFixedGeom(x2,y2,z2,x2 + v.X,y2 + v.Y,z2 + v.Z)
	if d3 then
		self.traceTable[self.traceCounter] = d3
	else
		self.traceTable[self.traceCounter] = 50		-- + FRand(-1,1)
	end
	self.traceCounter = self.traceCounter + 1
	
	if self.traceCounter > 8 then
		self.traceCounter = 1
	end
	------------------
	
	if self._mode then
		if actor.Animation ~= self._mode or not actor._isAnimating then
			--Game:Print("end self._mode "..actor.Animation)
			self._mode = nil
		else
			return
		end
	end
	
	if actor._doDeath and not actor._rotatingWithAnim then
		--if debugMarek then Game:Print("diyong") end
		actor:PlaySound("deathVoice")
		actor:FullStop()
		self._mode = "atak1"
		actor:SetAnim(self._mode, false)
		return
	end


	--[[
	if math.random(100) < 10 then		--- and health low? + min time beetween
		local target = nil
		local x,y,z = actor:GetJointPos("k_sz")
		local distAct = aiParams.eatRange
		for i,v in Actors do
			if v.Health > 0 and v._AIBrain and not v._locked and v ~= self then
				local dist = Dist3D(v.Pos.X,v.Pos.Y,v.Pos.Z, x,y,z)
				if distAct > dist then
					distAct = dist
					target = v
				end
			end
		end
		if target then
			--Game:Print("target zjadanie Found")
			actor:SetAnim("atak4",false)
			self._mode = "atak4"
			return
		end
	end
	--]]
	------ ataki

	local x,y,z = actor:GetJointPos("k_sz")
	local dist = Dist2D(x,z, brain._enemyLastSeenPoint.X,brain._enemyLastSeenPoint.Z)

	if (brain._distToNearestEnemy > aiParams.farAttackRange and self.lastTimeOnAttack + aiParams.minTimeBetweenAttacksWhenFar < brain._currentTime) or 
	 (brain._distToNearestEnemy <= aiParams.farAttackRange and self.lastTimeOnAttack + aiParams.minTimeBetweenAttacksWhenClose < brain._currentTime) or
	 (dist < aiParams.closeAttackRange and self.lastTimeOnAttack + aiParams.minTimeBetweenAttacksWhenClose < brain._currentTime) then
		--Game:Print("poss at "..aDist*180/math.pi)
		if math.abs(aDist) < 40 * math.pi/180 then
			--if debugMarek then
				--local angleToPlayer = math.atan2(brain._enemyLastSeenPoint.X - actor._groundx, brain._enemyLastSeenPoint.Z - actor._groundz)
				--Game:Print("angle to player "..angleToPlayer*180/math.pi)
			--end
			
			--Game:Print("poss at ok")
			actor:Stop()
			actor._isRotating = nil
			actor._NEXTangleDestAnim = nil
			--Game.freezeUpdate = true
			
			if not actor._rotatingWithAnim then
				actor:FullStop()
				self.lastTimeOnAttack = brain._currentTime + FRand(0,2.5)
				if brain._distToNearestEnemy > aiParams.farAttackRange then 
					if (math.random(100) < 90) and brain._seeEnemy then
						self._mode = "atak3"
						--Game:Print("see enemy atak3")
						actor:SetAnim("atak3",false)
					else
                        if actor:CheckAtak1() then
                            self._mode = "atak1"
                            if brain._seeEnemy then
                                --Game:Print("see enemy atak1a see "..brain._distToNearestEnemy)
                            else
                                --Game:Print("see enemy atak1a Not zee")
                            end
                            actor:SetAnim("atak1",false)
                        else
                            --Game:Print("atak1a cant")
                            --move forward?
                        end
                    
					end
					return
				else
					
					if dist < aiParams.closeAttackRange and math.random(100) < 98 then
						--Game:Print("see enemy atak4 "..brain._distToNearestEnemy.." "..dist)
						self._mode = "atak4"
						actor:SetAnim("atak4",false)
						return
					end

					if brain._distToNearestEnemy > 30 or brain._distToNearestEnemy < 15 and actor:CheckAtak1() then 
						self._mode = "atak1"
						--Game:Print("see enemy atak1 "..brain._distToNearestEnemy)
						actor:SetAnim("atak1",false)
						return
					end
					if math.random(100) < 90 and not Player._slowDown then 
						self._mode = "atak2"
						--Game:Print("see enemy atak2")
						actor:SetAnim("atak2",false)
						return
					else
						if Player._slowDown then
							if math.random(100) < 20 then
								--if debugMarek then Game:Print(" skipped atak1") end
								return
							end
						end
						if actor:CheckAtak1() then
                            self._mode = "atak1"
                            --Game:Print("see enemy atak1b")
                            actor:SetAnim("atak1",false)
                        else
                            --Game:Print("atak1b failed")
                        end
						return
					end
				end
			end

		else
			-- nie widzi gracza
			if brain._distToNearestEnemy < aiParams.farAttackRange and not actor._rotatingWithAnim then
				if math.abs(aDist) < (aiParams.viewAngle * 0.6 * math.pi/180) and actor:CheckAtak1() then
					self.lastTimeOnAttack = brain._currentTime + FRand(0,1)
					self._mode = "atak1"
					actor:FullStop()
					--Game:Print("enemy atak1")
					actor:SetAnim("atak1",false)
					return
				end
			end
			
			if brain._distToNearestEnemy < 60 and not actor._isWalking and not actor._rotatingWithAnim then 	
				if debugMarek then
					--Game:Print("widzi grazca?")
					--actor.yadebug1 
				end
				--local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(actor:GetJointPos("root"), Player.Pos.X,Player.Pos.Y + 1.7, Player.Pos.Z)
				--if e then
				if brain._seeEnemy then
					if math.random(100) < 10 or self.b1 or self.b2 then
						if math.random(100) < 10 then
							--Game:Print("R to gracz")
							actor:RotateToVectorWithAnim(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
						else
							--Game:Print("walk random")
							actor:WalkForward(FRand(30,40), nil, FRand(-125,125),nil,nil,nil,true)
							return
						end
					else
						--Game:Print("walk to gracz")
						actor:WalkTo(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z,nil,FRand(10,15), nil, nil, true, moveBackward)
						return
					end
				end
				--[[
					local obj = EntityToObject[e]
					if (obj and obj._Class == "CPlayer" and d > 5) or (not obj and d > 20) then
						Game:Print("widzi grazca? -> idzie tam "..d)
						if obj then
                            Game:Print("idzie do obj "..obj.Pos.X.." "..obj.Pos.Y.." "..obj.Pos.Z)
							actor:WalkTo(obj.Pos.X,obj.Pos.Y,obj.Pos.Z,nil,FRand(10,15), nil, nil, true, moveBackward)
						else
							--actor:WalkTo(xcol,ycol,zcol,nil,FRand(12,14), nil, nil, true, moveBackward)
							if math.random(100) < 55 then
								Game:Print("rotate to anim PL")
								actor:RotateToVectorWithAnim(Player.Pos.X,Player.Pos.Y,Player.Pos.Z)
							else
								Game:Print("rotate to anim ODW")
								actor:RotateWithAnim(FRand(100,260))
							end
						end
						return
					end
				end--]]

			end
		end	
	end
	-----------------

	if actor._isWalking then
		local idx  = MDL.GetJointIndex(actor._Entity,"root")
		local x2,ysrc,y2 = MDL.TransformPointByJoint(actor._Entity, idx,0,0,0)
		local x2,y2,z2 = MDL.TransformPointByJoint(actor._Entity, idx,-1,5,-10)		-- przod, dol, lewo
		ysrc = ysrc - 3
		y2 = ysrc
		local angle = actor.angle + 1 * math.pi/180
		local v = Vector:New(math.sin(angle), 0, math.cos(angle))
		v:Normalize()
		v:MulByFloat(30)
		if debugMarek then
			actor.yaaaadebug1 = x2
			actor.yaaaadebug2 = y2
			actor.yaaaadebug3 = z2
			actor.yaaaadebug4 = x2 + v.X
			actor.yaaaadebug5 = y2
			actor.yaaaadebug6 = z2 + v.Z
		end
		local b1,d1,x1,y1,z1,nx1,ny1,nz1,he1,e1 = WORLD.LineTraceFixedGeom(x2,y2,z2,x2 + v.X,y2 + v.Y,z2 + v.Z)
		self.b1 = b1		

		local x2,y2,z2 = MDL.TransformPointByJoint(actor._Entity, idx,-1,5,10)
		y2 = ysrc
		local angle = actor.angle - 1 * math.pi/180
		local v = Vector:New(math.sin(angle), 0, math.cos(angle))
		v:Normalize()
		v:MulByFloat(30)

		if debugMarek then
			actor.yaaadebug1 = x2
			actor.yaaadebug2 = y2
			actor.yaaadebug3 = z2
			actor.yaaadebug4 = x2 + v.X
			actor.yaaadebug5 = y2
			actor.yaaadebug6 = z2 + v.Z
		end

		local b2,d2,x2,y2,z2,nx2,ny2,nz2,he2,e2 = WORLD.LineTraceFixedGeom(x2,y2,z2,x2 + v.X,y2 + v.Y,z2 + v.Z)
		self.b2 = b2

		if b1 and b2 then
			--Game:Print("both col")
			--[[if brain._seeEnemy then
				actor:Stop()
				local angleToPlayer = math.atan2(brain._enemyLastSeenPoint.X - actor._groundx, brain._enemyLastSeenPoint.Z - actor._groundz)
				if math.abs(angleToPlayer) < 30 * math.pi/30 then
					actor:SetAnim("idle",false)
					self._mode = "idle"
				else
					actor:RotateToWithAnim()
				end
				return
			end--]]
			
			
			local minDist = 0
			local target = 0
			for i,v in self.traceTable do
				if v > minDist then
					minDist = v
					target = i
				end
			end
			--Game:Print("STOP. target = "..minDist.."  "..target * 45)
			--Game.freezeUpdate = true
			self._delay = 15
			actor:Stop()
			-- wybor najbl. graczowi
			if not brain._seeEnemy or self.lastTimeOnAttack + 5 > brain._currentTime then
				if not brain._seeEnemy then
					--Game:Print("nie widzi")
				end
				--Game:Print("nie bedzie ataku "..self.lastTimeOnAttack.." "..brain._currentTime)
				actor:RotateToWithAnim(target * 45)
				return
			end
			--Game:Print("bedzie atak??")
			--Game.freezeUpdate = true
			if brain._seeEnemy and math.random(100) > 90 then
				--Game:Print("bedzie atak?? - see enemy "..brain._distToNearestEnemy.." time = "..self.lastTimeOnAttack + aiParams.minTimeBetweenAttacksWhenFar.." "..brain._currentTime)
				if (brain._distToNearestEnemy > aiParams.farAttackRange and self.lastTimeOnAttack + aiParams.minTimeBetweenAttacksWhenFar + 2 < brain._currentTime) or 
					(brain._distToNearestEnemy <= aiParams.farAttackRange and self.lastTimeOnAttack + aiParams.minTimeBetweenAttacksWhenClose + 2 < brain._currentTime) then
						--if math.abs(aDist) < 40 * math.pi/180 then
							--Game:Print("przypuszczalny atak")
							return
						--end
				end
			end
			--Game:Print("2nie bedzie ataku, walk "..self.lastTimeOnAttack.." "..brain._currentTime.." dist = "..brain._distToNearestEnemy.." "..minDist)
			--actor:RotateToWithAnim(target * 45)
			
			local angle = target * 45 * math.pi/180
			local v = Vector:New(math.sin(angle), 0, math.cos(angle))
			v:Normalize()
			v:MulByFloat(40)
			--local b3,d3 = WORLD.LineTraceFixedGeom(x2,y2,z2,x2 + v.X,y2 + v.Y,z2 + v.Z)
			
			actor:RotateToVectorWithAnim(v.X, v.Y, v.Z)

			return
				
		end
		
		if b1 then
			--Game:Print("rotate left")
			actor:Rotate(10)
			--Game.freezeUpdate = true
		end

		if b2 then
			--Game:Print("rotate right")
			actor:Rotate(-10)
			--Game.freezeUpdate = true
		end
		return	
	end


	if actor._rotatingWithAnim then
		return
	end
	if math.random(100) < 15 then		-- pozniej zeby nie pod rzad dwa razy
		--Game:Print("set idle")
		--actor:SetAnim("idle",false)
		--self._mode = "idle"
	else
	
		--Game.freezeUpdate = true
		--if debugMarek then Game:Print("change pos? "..self._startDelay)	end
		if self._startDelay < 0 then		--  + bonus
		
			if math.random(100) < 30 then
				--if debugMarek then Game:Print("tylko rotate") end
				actor:RotateToVectorWithAnim(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
				return
			end
		
			if brain._enemyLastSeenPoint.X == 0 then
				brain._enemyLastSeenPoint = Clone(Player.Pos)
				--if debugMarek then Game:Print("player pos") end
			end

			dist = FRand(20,30)
			local x2,y2,z2 = brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z
			--if debugMarek then Game:Print("--------> "..x2.." "..y2.." "..z2) end
			local x3,y3,z3 = actor._groundx,actor._groundy,actor._groundz
			local angle = FRand(0,6.28)
	
			local x = math.sin(angle) + math.cos(angle)
			local z = math.cos(angle) - math.sin(angle)
			local y = brain._enemyLastSeenPoint.Y
			x = x * dist + x2
			z = z * dist + z2

			--local _angleDest = AngDist(actor.angle, math.atan2((actor._groundx - x) - actor._groundx, (actor._groundz - z) - actor._groundz))
			local backward = false
			--if math.abs(_angleDest) > 120 * math.pi/180 then
			--	backward = true
			--end

			actor:RotateToVector(x,y,z)
			actor:WalkTo(x,y,z,nil,FRand(30,45), nil, nil, true, moveBackward)
		end
	end

	
end

function o._CustomAiStates.idleSpider:OnRelease(brain)
	local actor = brain._Objactor
end

function o._CustomAiStates.idleSpider:Evaluate(brain)
	if brain._Objactor._phase == 0 then
		return 0.5
	end
	if self._mode then
		return 0.9
	end
	return 0
end

--[[
function o:FindSpace()
end

function o:Eat()
	local x,y,z = self:GetJointPos("k_sz")
	for i,v in Actors do
		if v.Health > 0 and v._AIBrain and not v._locked and v ~= self then
			local dist = Dist3D(v.Pos.X,v.Pos.Y,v.Pos.Z, x,y,z)
			if dist < self.AiParams.eatRange then
				ENTITY.SetVelocity(target._Entity,0,10,0)
				MsgBox("eat "..target._Name)
				target:OnDamage(target.Health + 2, self)
				self.Health = self._HealthMax * self.eatHPBonus
				if self.Health > self._HealthMax then
					self.Health = self._HealthMax
				end
			end
		end
	end
end--]]



function o:StartFlame()
	local idx  = MDL.GetJointIndex(self._Entity,"k_sz")
	local p = self.s_SubClass.ParticlesDefinitions.flame
	local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx,p.pos1Offset.X,p.pos1Offset.Y,p.pos1Offset.Z)
	local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx,p.pos2Offset.X,p.pos2Offset.Y,p.pos2Offset.Z)
	
	local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
	v2:Normalize()
	local q = Clone(Quaternion)
	q:FromNormalX(v2.X, v2.Y, v2.Z)

	self._flameStart = Vector:New(x2,y2,z2)
	self._flameEnd = Vector:New(x3,y3,z3)

	self._flameFX = AddPFX(p.pfx, p.size, Vector:New(x2,y2,z2), q)

end

function o:EndFlame()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
end

function o:OnTick(delta)
	if self._flameFX then
		local idx  = MDL.GetJointIndex(self._Entity,"k_sz")
		local p = self.s_SubClass.ParticlesDefinitions.flame
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx,p.pos1Offset.X,p.pos1Offset.Y,p.pos1Offset.Z)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx,p.pos2Offset.X,p.pos2Offset.Y,p.pos2Offset.Z)
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)

		self._flameStart = Vector:New(x2,y2,z2)
		self._flameEnd = Vector:New(x3,y3,z3)
		
		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x2,y2,z2) 
	end

	if self._delay then
		self._delay = self._delay - delta
		if self._delay < 0 then
			self._delay = nil
		else
			return
		end


	end

--[[	if self._isWalking and self._walkAnimSpeed then
		self._walkAnimSpeed = self._walkAnimSpeed + delta * 2
		if self._walkAnimSpeed > self.WalkSpeed * self.s_SubClass.Animations.walk[1] then
			self._walkAnimSpeed = self.WalkSpeed * self.s_SubClass.Animations.walk[1]
		end
		self:SetAnimSpeed(self._walkAnimSpeed)
	else
		-- pozniej po delayu 1/10sec
		self._walkAnimSpeed = self._walkAnimSpeed - delta
		if self._walkAnimSpeed < 0.1 * self.WalkSpeed * self.s_SubClass.Animations.walk[1] then
			self._walkAnimSpeed = 0.1 * self.WalkSpeed * self.s_SubClass.Animations.walk[1]
		end
	end--]]
	
	--[[
	if not self._isWalking and self._isRotating and not self._rotatingWithAnim then
		---Game.freezeUpdate = true
		--Game:Print("not w, r")
		self._angleDest = self.angle
		self._isRotating = false

	end--]]
end

function o:CheckFlame()
	local v2 = Vector:New(self._flameEnd.X - self._flameStart.X, self._flameEnd.Y - self._flameStart.Y, self._flameEnd.Z - self._flameStart.Z)
	v2:Normalize()
	
	local idx  = MDL.GetJointIndex(self._Entity,"k_sz")
	local x3,y3,z3 = self._flameStart.X,self._flameStart.Y,self._flameStart.Z
	
	local i = 6
	local dist = 29
	
	if debugMarek then
		DebugSpheres = {}
	end
	local size = 6.5
	
	local temps = GObjects.Elements
	for i,v in temps do
		v._markedTemp = true
	end

	--local s = Templates["Shotgun.CWeapon"]:GetSubClass()
	local playe = true
	
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

		local das = Dist3D(x,y,z, Player.Pos.X,Player.Pos.Y+0.5,Player.Pos.Z)
		--Game:Print("dist to pl "..das)
		if das < size and playe then
			Player:OnDamage(self.AiParams.fireDamage,self)
			playe = false
		end

        
        if temps then
            for i,v in temps do
                if v.Health and v.Health > 0 and v._markedTemp then
                    local dist = Dist3D(x,y,z, v.Pos.X,v.Pos.Y,v.Pos.Z)
                    if dist < size then
						--Game:Print("in range "..v._Name)
						v:OnDamage(self.AiParams.fireDamage, self)
						v._markedTemp = nil
                    end
                end
            end
        end
	end

	for i,v in temps do
		v._markedTemp = nil
	end

	
end

function o:CheckDamageFromAtak4()
	local idx  = MDL.GetJointIndex(self._Entity,"k_sz")
	local x,y,z = MDL.TransformPointByJoint(self._Entity,idx,0,3,0)	--MDL.GetJointPos(self._Entity,idx)
	
	y = y - 4.5

	DebugSpheres = {}
	
	if debugMarek then
		local a = {}
		a.X = x
		a.Y = y
		a.Z = z
		a.Size = self.AiParams.eatRange
		table.insert(DebugSpheres, a)
	end

	self.DEBUG_P1 = x
	self.DEBUG_P2 = y
	self.DEBUG_P3 = z
	WORLD.Explosion2(x,y,z, 20--[[Streng--]], self.AiParams.eatRange, nil, AttackTypes.Step, self.AiParams.eatDamage)
end

function o:Shockwave()
	local v = Vector:New(self:GetJointPos("root"))
	v.Y = v.Y - 5

    local s = self.ShockWave
    AddObject(s.FXwhenHit,1.0, v, nil, true) 

	if self._doDeath then
		Game:Print("_doDeath done")
		self._doDeath = nil
		self._deathDone = true
		self:OnDamage(99999)
		return
	end


	--WORLD.ExplosionUp(v.X, v.Y, v.Z, self.ShockWave.stren, self.ShockWave.distance, self.ShockWave.stren, self.ShockWave.random)

    Game._EarthQuakeProc:Add(v.X,v.Y,v.Z, s.eqTimeOut, s.eqRange, s.eqCameraMove, s.eqCameraMove, 1.0)

	--Game._EarthQuakeProc:Add(v.X, v.Y, v.Z, 8, 60, 0.4, 0.4, 2.0)

	local dist = Dist3D(v.X,v.Y,v.Z,Player._groundx, Player._groundy, Player._groundz) 
	
    local b,d,x,y,z,nx,ny,nz,he,e
	if s.HitDecal then
		b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(v.X,v.Y + 2.0,v.Z,v.X,v.Y - 6.0,v.Z)
		if debugMarek then
		 self.DEBUG_P1 = v.X
		 self.DEBUG_P2 = v.Y + 2.0
		 self.DEBUG_P3 = v.Z
		end
		ENTITY.SpawnDecal(e,s.HitDecal,v.X,v.Y,v.Z,0,1,0, 10)
	end

	Game:Print("SHOCK "..dist)	
	if dist < s.range then
		if not ENTITY.PO_IsFlying(Player._Entity) then
			ENTITY.PO_SetPlayerFlying(Player._Entity, 0.3)
			--ENTITY.SetVelocity(Player._Entity, v2.X, v2.Y, v2.Z)
			Player:OnDamage(s.damage - s.damage * dist / s.range, self)
			local v2 = Vector:New(Player._groundx - v.X,0,Player._groundz - v.Z)
			v2:Normalize()
			v2.Y = 1.2
			v2:MulByFloat(s.playerHitStr * FRand(0.9,1.1))
			ENTITY.SetVelocity(Player._Entity, v2.X, v2.Y, v2.Z)
		end
	end
	
    if z then
        WORLD.Explosion2(x,y - 18,z, s.explosionStren, s.range, nil, AttackTypes.Rocket, 0)
    end
end


function o:CheckAtak1()
	local v = Vector:New(math.sin(self.angle+math.pi), 0, math.cos(self.angle+math.pi))
	v:Normalize()
	v:MulByFloat(24)
	local x2,y2,z2 = self.Pos.X,self.Pos.Y + 7,self.Pos.Z
	local b = WORLD.LineTraceFixedGeom(x2,y2,z2,x2 + v.X,y2 + v.Y,z2 + v.Z)
	if debugMarek then
		self.yaaaaadebug1 = x2
		self.yaaaaadebug2 = y2
		self.yaaaaadebug3 = z2
		self.yaaaaadebug4 = x2 + v.X
		self.yaaaaadebug5 = y2 + v.Y
		self.yaaaaadebug6 = z2 + v.Z
	end
	if b then
		return false
	end
	return true
end

o._CustomAiStates.spiderPhase2 = {
	name = "spiderPhase2",
}

function o._CustomAiStates.spiderPhase2:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	Game:Print("phase 1 "..actor.Animation)
	actor:Stop()
	actor:PlayRandomSound2D("phase2")
	actor._isRotating = nil
	actor._NEXTangleDestAnim = nil
	actor._delayShock = 40
	self._lastTimeAtak = brain._currentTime + FRand(2,2+aiParams.minTimeBetweenAttacks2ndPhase*0.2)
end

function o._CustomAiStates.spiderPhase2:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	if actor._delayShock then
		actor._delayShock =  actor._delayShock - 1
		if actor._delayShock < 0 then
			actor._delayShock = nil
		end
		if not actor._isAnimating then
			actor:SetAnim("idle",true)
		end
		return
	end

	if self._modePreCharge then
		if not actor._rotatingWithAnim then
			actor:SetAnim("charge",false)
			self._lastTimeAtak = brain._currentTime
			self._anim = "charge"
			self.walked = nil
			self._modePreCharge = nil
		else
			return
		end
	end


	if self._anim then
		if actor.Animation ~= self._anim or not actor._isAnimating then
			Game:Print("end self._anim "..actor.Animation)
			self._lastTimeAtak = brain._currentTime + FRand(0,aiParams.minTimeBetweenAttacks2ndPhase*0.2)
			self._anim = nil
		else
			return
		end
	end

	if self._x then
		if not actor._rotatingWithAnim then
			actor:WalkTo(self._x, self._y, self._z, false)
			self._x = nil
		end
		return
	end


	if self.timeChangeStillToFalse then
		self.timeChangeStillToFalse =  self.timeChangeStillToFalse - 1
		if self.timeChangeStillToFalse < 0 then
			self.timeChangeStillToFalse = nil
			self.GuardStill = false
			--Game:Print("self.GuardStill END")
		end
	end
	
	if self.GuardStill then
		return
	end

	if not actor._isWalking then
		if self._lastTimeAtak + aiParams.minTimeBetweenAttacks2ndPhase < brain._currentTime then
			Game:Print("precharge "..self._lastTimeAtak.." "..brain._currentTime)
			actor:RotateToVectorWithAnim(Player._groundx,Player._groundy,Player._groundz)
			self._modePreCharge = true
			return
		end
		
		if aiParams.stopAfterWalking and FRand(0.0, 1.0) <= aiParams.stopAfterWalking and self.walked then
			self.timeChangeStillToFalse = math.random(aiParams.stopAfterWalkingTime[1],aiParams.stopAfterWalkingTime[2])
			self.GuardStill = true
			self.walked = false
			return
		else
			if aiParams.walkAreaRandom then
				local size = table.getn(brain._walkArea.Points)
				local rnd = math.random(1, size)
				if size > 1 and rnd == brain._walkAreaNo then	-- zeby nie szedl do tego samego punktu
					if rnd < size then
						rnd = rnd + 1
					else
						rnd = rnd - 1
					end
				end

				brain._walkAreaNo = rnd
				local angle = math.atan2(brain._walkArea.Points[rnd].X - actor._groundx, brain._walkArea.Points[rnd].Z - actor._groundz)

				local angDist = AngDist(actor.angle, angle)

				if math.abs(angDist) < 60*math.pi/180 then
					actor:WalkTo(brain._walkArea.Points[rnd].X, brain._walkArea.Points[rnd].Y, brain._walkArea.Points[rnd].Z, false)
				else
					self._x, self._y, self._z = brain._walkArea.Points[rnd].X, brain._walkArea.Points[rnd].Y, brain._walkArea.Points[rnd].Z
					actor:RotateToVectorWithAnim(self._x, self._y, self._z)
				end
			else
				--actor:WalkTo(brain._walkArea.Points[brain._walkAreaNo].X, brain._walkArea.Points[brain._walkAreaNo].Y, brain._walkArea.Points[brain._walkAreaNo].Z, false)
				brain._walkAreaNo = brain._walkAreaNo + 1
				if brain._walkAreaNo > table.getn(brain._walkArea.Points) then
					brain._walkAreaNo = 1
				end
			end
			self.walked = true
		end
	end
end

function o._CustomAiStates.spiderPhase2:OnRelease(brain)
end

function o._CustomAiStates.spiderPhase2:Evaluate(brain)
	local actor = brain._Objactor
	Game.MegaBossHealth = actor.Health
	actor:WalkDamage()
	if actor._phase == 1 then
		return 0.4
	end
	return 0
end



function o:OnThrow(vx,vy,vz,angle,pitch)
	local obj = self._objTakenToThrow.ObjOwner
	self._objTakenToThrow._selfSpeed = Vector:New(vx,vy,vz)
	self._objTakenToThrow._target = Player
    self._objTakenToThrow._lastAngle = angle + math.pi
	self._objTakenToThrow._lastPitch = pitch

	if self._phase == 0 then
		local q = Quaternion:New_FromEuler(0, math.pi/2 - self.angle, math.pi/2)
		local x,y,z = self._objTakenToThrow.Pos.X,self._objTakenToThrow.Pos.Y,self._objTakenToThrow.Pos.Z
		local pd = self.s_SubClass.ParticlesDefinitions.shot
		AddPFX(pd.pfx, pd.scale, Vector:New(x,y,z), q)
	end
	
	if self._chargeFX then
		PARTICLE.Die(self._chargeFX)
		self._chargeFX = nil
	end
	
--[[	local bindOffset = Vector:New(0,0,0)
	if self._bindedLight then
		ENTITY.UnregisterAllChildren(self._Entity)		-- dodac typ
		ENTITY.RegisterChild(self._objTakenToThrow._Entity,self._bindedLight._Entity,true)
		MESH.SetLighting(self._objTakenToThrow._Entity, false)
		ENTITY.SetPosition(self._bindedLight._Entity,bindOffset.X, bindOffset.Y, bindOffset.Z)
		self._objTakenToThrow._bindedLightT = Templates[self.s_SubClass.Light.template]
		self._objTakenToThrow._bindedLight = self._bindedLight
		self._bindedLight = nil
	end--]]

end

function o:FireBallHit()
	if self._objTakenToThrow then
		GObjects:ToKill(self._proc)
		self._proc = nil
		self:SetIdle()
		self._delayShock = self.AiParams.shockTime + FRand(0,self.AiParams.shockTime*0.1)
		--Game:Print("dostal w fireballa")
		self:PlayRandomSound2D("shutdown")
	
		self._sndloop = self:BindRandomSound("stunned",nil,nil,self:GetAnyJoint(),nil,true)	
		if self._chargeFX then
			PARTICLE.Die(self._chargeFX)
			self._chargeFX = nil
		end
		self._objTakenToThrow = nil
	end
end


function o:TakeToThrowCustom()
	local aiParams = self.AiParams
	local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem2))
	obj.ObjOwner = self
	--obj._enabled = false
	obj:Apply()
    if obj.Synchronize then
        obj:Synchronize()
    end

	if self._objTakenToThrow then
		Game:Print(self._Name.." ERROR!!!: self._objTakenToThrow already exists")
		GObjects:ToKill(self._objTakenToThrow)
		Game.freezeUpdate = true
	end
	
	self._objTakenToThrow = obj
    local brain = self._AIBrain
	if aiParams.throwItemBindToOffsetFireball then
		self._proc = AddObject(Templates["PBindToJoint.CProcess"]:New(obj._Entity,self._Entity,aiParams.throwItemBindTo,aiParams.throwItemBindToOffsetFireball.X,aiParams.throwItemBindToOffsetFireball.Y, aiParams.throwItemBindToOffsetFireball.Z))
	else
		self._proc = AddObject(Templates["PBindToJoint.CProcess"]:New(obj._Entity,self._Entity,aiParams.throwItemBindTo,0.0,0,0.0))
	end
	if aiParams.hideMesh then
		MDL.SetMeshVisibility(self._Entity, aiParams.hideMesh, false)		-- narazie
	end
	self._chargeFX = self:BindFX("charge")
	self:AddPFX("chargeFlash")
end

