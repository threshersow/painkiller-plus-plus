--[[DoFile(path.."Classes/Ai/idle.state")
DoFile(path.."Classes/Ai/attack.state")
DoFile(path.."Classes/Ai/farattack.state")
DoFile(path.."Classes/Ai/closeAttack.state")
DoFile(path.."Classes/Ai/hunt.state")
DoFile(path.."Classes/Ai/hearing.state")
DoFile(path.."Classes/Ai/flee.state")
DoFile(path.."Classes/Ai/jump.state")
DoFile(path.."Classes/Ai/jumpUp.state")
DoFile(path.."Classes/Ai/runToPlayer.state")
DoFile(path.."Classes/Ai/throw.state")
--]]
--------------------------------

CAiBrain = {
	
-- private
	_goals = {},
	_currentGoal = nil,
	r_closestEnemy = nil,
	_enemyLastSeenTime = -100,
	_enemyLastSeenPoint = Vector:New(0,0,0),
	_enemyLastSeenVelocity = Vector:New(0,0,0),
	_enemyLastSeenVelocitySpeed = 0,
	_distToNearestEnemy = -100,
	_enemyLastSeenOrientation = 0,

	_Objactor = nil,
	_currentTime = 0,
	_GuardPos = {},
	_GuardAng = nil,

	_lastMissedTime = -100,
	_lastHitTime =	 -101,

	_walkAreaNo = 1,
	_walkArea = nil,	

    _Class = "CAiBrain",
	_velocityx = 0,
	_velocityy = 0,
	_velocityz = 0,
	_velocity = 0,
-------    
    _rotate180AfterEndWalking = nil,
	_lastHitFriendTime = -100,
	_lastHitByEnemyType = nil,
	_lastHitByEnemyTime = -100,
	_lastHitByEnemyPos = nil,
	_lastDamageTime = -100,
	r_lastDamageWho = nil,
	Objhostage = nil,
	FarAttack_Prio = 0.51,
	timeToIdle = 5,			-- dla spadania
	_animNameFalling = nil,
	s_BulletHitWallSnd = {"bullet-stone","bullet-stone2","bullet-stone3","bullet-stone4","ricochet1","ricochet2","ricochet3","ricochet4",},
	_diffInangleAttackX = 0,
	_diffInangleAttackY = 0,
	_confuseEnemy = nil,
}

function CAiBrain:AddState(state)
    local actor = self._Objactor
    if actor.NeverMove then
        if state == "hunt" or state == "flee" or state == "runToPlayer" then
            Game:Print(actor._Name.." state ignored (nevermove): "..state)
            return 3
        end
    end
	if AiStates[state] then
		table.insert(self._goals, Clone(AiStates[state]))
		return 1
	else
		if actor._CustomAiStates and actor._CustomAiStates[state] then		-- gdy goalsa uzywa tylko jeden typ postaci, zeby nie zasmiecalo globalnej tablicy
			table.insert(self._goals, actor._CustomAiStates[state])
			return 2
		else
			DoFile(path.."Classes/Ai/"..state..".state")
			if not AiStates[state] then
				MsgBox(actor._Name.." %ERROR: no goal "..state)
			else
				table.insert(self._goals, Clone(AiStates[state]))
				return 1
			end
			return nil
		end
	end
end


function CAiBrain:OnInit(act)
	self._Objactor = act
	self._forceUpdateVisibility = true
end

function CAiBrain:OnApply()
	local actor = self._Objactor
	local aiParams = actor.AiParams
	self._GuardPos.X = actor.Pos.X
	self._GuardPos.Y = actor.Pos.Y
	self._GuardPos.Z = actor.Pos.Z
	if aiParams.walkArea and aiParams.walkArea ~= "" and type(aiParams.walkArea) == "string" then
		self._walkArea = rawget(getfenv(),aiParams.walkArea)
	end
	self._walkStepLocal = aiParams.walkStep
end


function CAiBrain:UpdateSensors()
	local actor = self._Objactor
	local aiParams = actor.AiParams	
	self._velocityx,self._velocityy,self._velocityz,self._velocity = ENTITY.GetVelocity(actor._Entity)

	local x,y,z = Player._groundx, Player._groundy, Player._groundz
	self._distToNearestEnemy = Dist3D(x,y,z,actor._groundx,actor._groundy,actor._groundz)		-- jeszcze distance po sciezce
	
	if self._confuseEnemyTimer then
		if self._confuseEnemy.Health <= 0 then
			self._confuseEnemyTimer = -1
			actor:Stop()
			self._enemyLastSeenTime = -100
			if actor.OnConfuseEnemyLost then
				actor:OnConfuseEnemyLost()
			end
		end
		self._confuseEnemyTimer = self._confuseEnemyTimer - 1/30
		if self._confuseEnemyTimer < 0 then
			self._confuseEnemy = nil
			self._confuseEnemyTimer = nil
		end
	end

	if Game.ConfuseEnemies then
		self._confuseEnemy = nil
		self._confuseEnemyTimer = nil
		if self._lockedEnemy and self._lockedEnemy.Health <= 0 then
			self._lockedEnemy = nil
			actor:Stop()
			self._enemyLastSeenTime = -100
			if actor.OnConfuseEnemyLost then
				actor:OnConfuseEnemyLost()
			end

		end
	end
	
	if self._lockedEnemy then		-- bo update speed moze byc <100%
		self._distToNearestEnemy = Dist3D(self._lockedEnemy._groundx, self._lockedEnemy._groundy, self._lockedEnemy._groundz, actor._groundx,actor._groundy,actor._groundz)
	end
	
	if math.random(100) < aiParams.updateSpeed*100 or self._forceUpdateVisibility then
		self._forceUpdateVisibility = false
		self.r_closestEnemy = nil				-- tu? napewno
		self._seeEnemy = false
		
		-- enemies
		local player = Player

		if (Game.ConfuseEnemies or self._confuseEnemy) and not actor.disableFreeze then		-- disableFreeze maja BOSS-owie
			if self._confuseEnemy then
				self._lockedEnemy = self._confuseEnemy
			else
				if math.random(100) < 7 then
					--if debugMarek then Game:Print(actor._Name.." Game.ConfuseEnemies") end
					--local dist = 99999
					--local closest = nil
					local alist = {}
					for i,v in Actors do
						if v.Health > 0 and v._AIBrain and not v.NotCountable and v ~= actor and v.AIenabled then
							table.insert(alist, v)
							--local d = Dist3D(actor._groundx,actor._groundy,actor._groundz, v._groundx,v._groundy,v._groundz)
							--if d < dist then
							--	dist = d
							--	closest = v
							--end
						end
					end
					--
					local size = table.getn(alist)
					local closest
					if size > 0 then
						closest = alist[math.random(1,table.getn(alist))]
					end
					self._lockedEnemy = closest
					--if closest then
					--	if debugMarek then Game:Print(actor._Name.." attack "..closest._Name) end
					--end
				end
			end

			if self._lockedEnemy then
				if self._lockedEnemy.Health <= 0 then
					self._lockedEnemy = nil
					actor:Stop()
					self._enemyLastSeenTime = -100
					if actor.OnConfuseEnemyLost then
						actor:OnConfuseEnemyLost()
					end
				else
					x,y,z = self._lockedEnemy._groundx, self._lockedEnemy._groundy, self._lockedEnemy._groundz
					self._distToNearestEnemy = Dist3D(x,y,z,actor._groundx,actor._groundy,actor._groundz)		-- jeszcze distance po sciezce
					self._lockedEnemy._velocityx = 0
					self._lockedEnemy._velocityy = 0
					self._lockedEnemy._velocityz = 0
					self._lockedEnemy._velocity = 0
					self._lockedEnemy._orientation = self._lockedEnemy.angle
				end
			end
			player = self._lockedEnemy
		end

		if player and player.Health > 0 then

			if aiParams.huntPlayer and not self._hunted then
				if aiParams.seeThruWalls then
					if self._distToNearestEnemy < aiParams.viewDistance360 then		-- dokonczyc
						self.r_closestEnemy = player
						self._hunted = true
						self._seeEnemy = true
					end
				else
					if ENTITY.SeesEntity(actor._Entity, player._Entity) then
						self.r_closestEnemy = player
						self._hunted = true
						self._seeEnemy = true
					end
				end
				self._enemyLastSeenTime = self._currentTime
				self._enemyLastSeenPoint.X = x
				self._enemyLastSeenPoint.Y = y
				self._enemyLastSeenPoint.Z = z
				self._enemyLastSeenOrientation = player._orientation
				self._enemyLastSeenVelocity.X = player._velocityx
				self._enemyLastSeenVelocity.Y = player._velocityy
				self._enemyLastSeenVelocity.Z = player._velocityz
				self._enemyLastSeenVelocitySpeed = player._velocity
			else
				if aiParams.seeThruWalls then
					if self._distToNearestEnemy < aiParams.viewDistance360 then		-- dokonczyc
						self.r_closestEnemy = player
						self._seeEnemy = true
					end
				else
					if ENTITY.SeesEntity(actor._Entity, player._Entity) then
						self._seeEnemy = true
						self.r_closestEnemy = player
					end
				end

				if aiParams.alwaysSee or self._seeEnemy then
					self._enemyLastSeenTime = self._currentTime
					self._enemyLastSeenPoint.X = x
					self._enemyLastSeenPoint.Y = y
					self._enemyLastSeenPoint.Z = z
					self._enemyLastSeenOrientation = player._orientation
					self._enemyLastSeenVelocity.X = player._velocityx
					self._enemyLastSeenVelocity.Y = player._velocityy
					self._enemyLastSeenVelocity.Z = player._velocityz
					self._enemyLastSeenVelocitySpeed = player._velocity
				end
			end
		end
	end
end

function CAiBrain:RotateHead(delta)
	--if actor.rotateHead > 0 then
        local actor = self._Objactor
        local headParams = actor.s_SubClass
        if (self.r_closestEnemy and self._seeEnemy) or actor.AiParams.forceRotateHead then
            if actor.AiParams.forceRotateHead then          -- UGLY HACK
                self.r_closestEnemy = Player
            end
			--local x1,y1,z1 = actor._groundx, actor._groundy, actor._groundz
			local x1,y1,z1 = actor:GetJointPos(headParams.rotateHeadBone)
			local x2,y2,z2 = self.r_closestEnemy._groundx, self.r_closestEnemy._groundy,self.r_closestEnemy._groundz
			local angleAttackX = math.atan2(x2 - x1, z2 - z1)
			y2 = y2 + 1.7

			local dist1 = Dist3D(x1,0,z1,x2,0,z2)
			
			local angleAttackY = math.atan2(y2 - y1, dist1)
			local aDist = AngDist(actor.angle, angleAttackX)
			
			if math.abs(aDist) > headParams.rotateHead then
				angleAttackX = headParams.rotateHead
				if aDist < 0 then
					angleAttackX = -angleAttackX
				end
			else
				angleAttackX = aDist
			end
			--aDist = AngDist(0, angleAttackY)
			aDist = angleAttackY
			if math.abs(aDist) > headParams.rotateHead then
				angleAttackY =  headParams.rotateHead
				if aDist < 0 then
					angleAttackY = -angleAttackY
				end
			else
				angleAttackY = aDist
			end
			
			--Game:Print("head = "..(angleAttackY*180/3.14).."  "..y1.." "..y2)
			
			local diff = AngDist(actor._angleAttackX, angleAttackX)
			self._diffInangleAttackX = diff
			local limit = headParams.rotateHeadMaxSpeed * delta * 20
			if diff > limit then
				diff = limit
			end
			if diff < -limit then
				diff = -limit
			end
			actor._angleAttackX = actor._angleAttackX + diff
			
			diff = AngDist(actor._angleAttackY, angleAttackY)		-- = angleAttackY - actor._angleAttackY
			self._diffInangleAttackY = diff
			if diff > limit then
				diff = limit
			end			
			if diff < -limit then
				diff = -limit
			end
			actor._angleAttackY = actor._angleAttackY + diff
		else
			if not actor.disableRotateHeadToZero then
				local speed = headParams.rotateHeadMaxSpeed * delta * 20
				if actor._angleAttackY > 0 then
					actor._angleAttackY = actor._angleAttackY - speed
					if actor._angleAttackY < 0.002 then
						actor._angleAttackY = 0
						self._diffInangleAttackY = 0
					end
				end
				if actor._angleAttackY < 0 then
					actor._angleAttackY = actor._angleAttackY + speed
					if actor._angleAttackY > -0.002 then
						actor._angleAttackY = 0
						self._diffInangleAttackY = 0
					end
				end

				if actor._angleAttackX > 0 then
					actor._angleAttackX = actor._angleAttackX - speed
					if actor._angleAttackX < 0.002 then
						actor._angleAttackX = 0
						self._diffInangleAttackX = 0
					end
				end
				if actor._angleAttackX < 0 then
					actor._angleAttackX = actor._angleAttackX + speed
					if actor._angleAttackX > -0.002 then
						actor._angleAttackX = 0
						self._diffInangleAttackX = 0
					end
				end
			end
		end
	--end
end

function CAiBrain:PreUpdate()
	local actor = self._Objactor
	-----------------
	if not actor._DontCheckFloors then
		self._onFloor, self._floorNormalX, self._floorNormalY, self._floorNormalZ = ENTITY.PO_IsOnFloor(actor._Entity)
		if not self._onFloor then
			self._velocityx,self._velocityy,self._velocityz,self._velocity = ENTITY.GetVelocity(actor._Entity)
			if self._velocityy < -0.01 then
				if self.timeToIdle > 0 then
					--if debugMarek then Game:Print(actor._Name.." prepare to flying "..self._velocityy) end
					self.timeToIdle = self.timeToIdle - 1
				else
					if self.timeToIdle == 0 then
						actor:Stop()
						if actor.s_SubClass.Falling then
							self._animNameFalling = actor.s_SubClass.Falling[math.random(1,table.getn(actor.s_SubClass.Falling))]
							actor:SetAnim(self._animNameFalling, true)
						else
							actor:SetIdle()
						end
					end
					self.timeToIdle = -1
					return
				end
			else
				self.timeToIdle = 6
			end
		else
			if actor.Animation == self._animNameFalling then
				actor:SetIdle()
				self._animNameFalling = nil
			end
			self.timeToIdle = 6
		end
	end
	-----------
	self:UpdateSensors()
end

function CAiBrain:OnUpdate()
	local actor = self._Objactor

	if self.Objhostage and not self.Objhostage.AIEnabled then
		ENTITY.RemoveRagdollFromIntersectionSolver(self.Objhostage._Entity)
	end
	
	self._currentTime = self._currentTime + 1/30
	local newGoal = self:EvaluateGoals()
	local cgoal = self._goals[self._currentGoal]
	if newGoal ~= self._currentGoal then
		if cgoal and cgoal.OnRelease then
			cgoal:OnRelease(self)
			if cgoal.active then
				--if debugMarek then
				--	Game:Print(actor._Name.." "..self._currentGoal.name.." self.active was true!")
				--	Game.freezeUpdate = true
				--end
				cgoal.active = false
			end
		end
		self._currentGoal = newGoal
		cgoal = self._goals[self._currentGoal]
		if cgoal and cgoal.OnInit then
			--Game:Print("NEW GOAL "..cgoal.name)
			cgoal:OnInit(self)
		end
	end
	if cgoal and cgoal.OnUpdate then		-- czy else?
		cgoal:OnUpdate(self)
	end

	if self.Objhostage and not self.Objhostage.AIEnabled then
		ENTITY.AddRagdollToIntersectionSolver(self.Objhostage._Entity)
	end

	--[[
	if debugMarek then
		actor.PUSHED = nil
        if not self._lastTimeWalking then
            self._lastTimeWalking = -100
        end
		if actor._isWalking then
			self._lastTimeWalking = self._currentTime
		end
		--Game:Print(self._velocityx.." "..self._velocityx.." "..self._velocityz.."   normal : "..self._floorNormalX.." "..self._floorNormalY.." "..self._floorNormalZ)
		if self._onFloor and not actor._isWalking and not self._notIsWalkingTimer and (self._velocityx > 0.2 or self._velocityz > 0.2) then
			--Game:Print(actor._Name.."NOT PLANNED VEL "..self._floorNormalY)
			-- czy podloze jest krzywe?
			if self._lastTimeWalking + 3/30 < self._currentTime then
				if self._floorNormalY > 0.95 then		-- ugly hack
					--Game:Print(actor._Name.."NIE MA SKOSU")
					-- czy nie dostal ostatnio damage
					if self._lastDamageTime + 2/30 < self._currentTime then
						Game:Print(actor._Name.." : KTOS mnie popchnal! "..self._velocityx.." "..self._velocityz)
						--self._lastPushedTime = self._currentTime
						actor.PUSHED = "PUSHED"
						--local d = 10
						--actor:WalkTo(actor._groundx + self._velocityx * d, actor._groundy + self._velocityy * d, actor._groundz + self._velocityz * d, true, 2, actor.s_SubClass.Hits[1])
						--Game.freezeUpdate = true
						
						if actor.s_SubClass.Hits and not actor._disableHits and not actor._hitDelay then
							local animName = actor.s_SubClass.Hits[math.random(1,table.getn(actor.s_SubClass.Hits))]
							if actor:SetAnim(animName, false) then
								actor._hitDelay = self.minimumTimeBetweenHitAnimation
								if not actor._hitDelay then
									actor._hitDelay = 90
								end
							end
						end
						
					end
				end
			end
		end
	end	
	--]]
end

function CAiBrain:EvaluateGoals()
	local eval = -1
	local currentEval = -1
	local goal = nil
	for i,v in self._goals do
		--if v.Evaluate then
			currentEval = v:Evaluate(self)
			if currentEval > eval then
				eval = currentEval
				goal = i
			end
		--else
		--	if debugMarek then Game:Print("no evaluate func") end
		--end
	end
	--if debugMarek and not goal then Game:Print("goal = nil "..table.getn(self._goals)) end
	return goal
end

-----------------------------

function Patrol(actor, brain, run, useOnlyWP, maxDist, anim)
	local aiParams = actor.AiParams
	local movement = FRand(brain._walkStepLocal, brain._walkStepLocal * 2)
	local ang = FRand(-12,12)

	if ENTITY.PO_Exist(actor._Entity) then
		local b = actor:Trace(movement + actor._SphereSize, ang)
		if b then
			--Game:Print("Patrol: Trace: nie mogie isc do przodu")
			ang = math.random(45,60)
			local b = actor:Trace(movement, ang)
			if b then
				ang = -ang
			end
		end
	end
--	Game:Print("Patrol: "..ang.." dist="..movement.." "..actor._groundy)
	actor:WalkForward(movement, run, ang, maxDist, anim, useOnlyWP)
end


function CAiBrain:WeaponFire(yDest,lrSrcZ, lrSrcY)
	--DEBUGgun = {}
	local actor = self._Objactor
	local aiParams = actor.AiParams
	local entity = actor._Entity
	local Joint
	local ax,ay,az
	if self._useSecondWeapon then
		Joint = MDL.GetJointIndex(entity, aiParams.secondWeaponBindPos)
		ax,ay,az = aiParams.secondWeaponBindPosShift.X, aiParams.secondWeaponBindPosShift.Y, aiParams.secondWeaponBindPosShift.Z
	else
		Joint = MDL.GetJointIndex(entity, aiParams.weaponBindPos)
		ax,ay,az = aiParams.weaponBindPosShift.X, aiParams.weaponBindPosShift.Y, aiParams.weaponBindPosShift.Z
	end
	
	if lrSrcZ then
		az = az + lrSrcZ
	end

	if lrSrcY then
		ay = ay + lrSrcY
	end

    local srcx,srcy,srcz = MDL.TransformPointByJoint(entity, Joint, ax,ay,az)
	local gun = aiParams.weapon
	local destx, desty, destz

	if self._enemyLastSeenShootTarget.X ~= 0 and self._enemyLastSeenShootTarget.Z ~= 0 then
		destx, desty, destz = self._enemyLastSeenShootTarget.X,self._enemyLastSeenShootTarget.Y,self._enemyLastSeenShootTarget.Z
	else
		-- z kierunku patrzenia
		local v = Vector:New(math.sin(actor.angle), 0, math.cos(actor.angle))
		v:Normalize()
		v.X,v.Y,v.Z = VectorRotate(v.X, v.Y, v.Z, 0, FRand(-gun.spreadAngle * math.pi/180, gun.spreadAngle * math.pi/180),FRand(-gun.spreadAngle * math.pi/180, gun.spreadAngle * math.pi/180))

		destx = v.X * self._distToNearestEnemy * 1.2 + actor._groundx
		desty = self._enemyLastSeenShootTarget.Y
		destz = v.Z * self._distToNearestEnemy * 1.2 + actor._groundz
	end

	if yDest then
		desty = desty + yDest
	end

	local v = Vector:New(destx - srcx, desty - srcy, destz - srcz)
	v:Normalize()
	

--[[
	if debugMarek then
		if not DEBUGtraces then
			DEBUGtraces = {}
		else
			if table.getn(DEBUGtraces) > 16 then
				DEBUGtraces = {}
			end
		end
		table.insert(DEBUGtraces, {destx, desty, destz, srcx, srcy, srcz})

		actor.yadebug1 = srcx
		actor.yadebug2 = srcy
		actor.yadebug3 = srcz
		actor.yadebug4 = destx
		actor.yadebug5 = desty
		actor.yadebug6 = destz
	end
--]]

	local changeDir = false
	
	local d = math.sqrt(v.X*v.X + v.Z*v.Z)
	local pitch = math.atan2(v.Y, d)
	local yaw = math.atan2(v.X, v.Z)
	local distYaw = AngDist(actor.angle, yaw)
	
	local maxPitch = 60 * math.pi/180
	local maxYaw = 60 * math.pi/180
	if gun.maxPitch then
		maxPitch = gun.maxPitch * math.pi/180
	end
	if gun.maxYaw then
		maxYaw = gun.maxYaw * math.pi/180
	end

	if math.abs(distYaw) > maxYaw then		-- max. angle reached (wzgl. kierunku patrzenia, to przed siebie)
		--if debugMarek then
			--Game:Print(actor._Name.." max YAW diff reached.")
		--end
		changeDir = true
		if distYaw > 0 then
			yaw = actor.angle + maxYaw
		else
			yaw = actor.angle - maxYaw
		end
	end
	
	if pitch > maxPitch then
		--if debugMarek then
			--Game:Print(actor._Name.." max PITCH diff reached.")
		--end
		pitch = maxPitch
		changeDir = true
	end
	if pitch < -maxPitch then
		--if debugMarek then
			--Game:Print(actor._Name.." max -PITCH diff reached.")
		--end
		pitch = -maxPitch
		changeDir = true
	end

	if changeDir then
		v.X,v.Y,v.Z = VectorRotate(1.0,0,0, 0, 0, pitch)
		v.X,v.Y,v.Z = VectorRotate(v.X,v.Y,v.Z, 0, -yaw+math.pi/2, 0)
		v.Y = -v.Y
		if debugMarek then
			actor.yaadebug1 = srcx
			actor.yaadebug2 = srcy
			actor.yaadebug3 = srcz
			actor.yaadebug4 = srcx + v.X
			actor.yaadebug5 = srcy + v.Y
			actor.yaadebug6 = srcz + v.Z
		end
	end

	
	local x1,y1,z1 = MDL.GetJointPos(entity,Joint) --MDL.TransformPointByJoint(entity, Joint, 0,0,0)
	local v2 = Vector:New(srcx - x1, srcy - y1, srcz - z1)
	v2:Normalize()
	local q = Quaternion:New_FromNormal(v2.X, v2.Y, v2.Z)
	
	if gun.fireParticle then
		AddPFX(gun.fireParticle, gun.fireParticleSize, Vector:New(srcx,srcy,srcz), q)
	end


	PlayLogicSound("FIRE",srcx,srcy,srcz,10,25,Player)		-- fake, ze player

	local hitObj
    local POe
	local playLogicRichochet = false
	local PO_Hit = false
	local PO_Hitx = 0			-- narazie
	local PO_Hity = 0
	local PO_Hitz = 0
	local xcol2 = 0
	local ycol2 = 0
	local zcol2 = 0
	local hitForce = gun.PO_HitForce
	local spread = gun.spreadAngle * math.pi/180

	local sndHit = false	
	for i=1,gun.bulletsPerShot do
		local x,y,z = VectorRotate(v.X, v.Y, v.Z, 0, FRand(-spread, spread),FRand(-spread, spread))
		local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(srcx, srcy, srcz, srcx + x*gun.maxDist, srcy + y*gun.maxDist, srcz + z*gun.maxDist)
		self._lastMissedTime = self._currentTime

		if b and e then
			local v6 = Vector:New(x,y,z)
			v6:Normalize()
			v6:MulByFloat(10)
			CheckStartGlass(he,xcol,ycol,zcol, 0.5, v6.X, v6.Y, v6.Z)
			local obj = EntityToObject[e]
			if obj then
				hitObj = obj
				self._lastHitTime = self._currentTime
				local damage = gun.damagePerBullet * FRand(0.9, 1.1)
				if obj._Class ~= "CPlayer" then
					damage = damage * Tweak.MonsterMonsterDamageModif
					if hitForce then
						hitForce = hitForce * Tweak.MonsterMonsterDamageModif
					end
					if obj._AIBrain then
						self._lastHitFriendTime = self._currentTime
					end
				end
				if obj == actor then
					if debugMarek then
						Game:Print(actor._Name.." WEAPON FIRE:col with self !!!!")
						--Game.freezeUpdate = true
					end
				else
					if obj.OnDamage then
						obj:OnDamage(damage, actor, AttackTypes.AIFar,xcol,ycol,zcol,nx,ny,nz)				
					end
					if obj.SoundHitByBullet and not sndHit and obj.Health > 0 then
						local snd = obj.SoundHitByBullet[math.random(1,table.getn(obj.SoundHitByBullet))]
				        PlaySound3D("impacts/"..snd,xcol,ycol,zcol,15,40)
				        sndHit = true			-- zeby > niz 1 dzwiek sie nie odpalal
					end
					if obj._Class == "CActor" or obj._Class == "CPlayer" then 
						if gun.PO_HitForce > 0 then
							PO_Hit = true
							PO_Hitx = x
							PO_Hity = y
							PO_Hitz = z
							POe = e
						end
					else
						local r = Quaternion:New()
						local ay = math.atan2(nx,-nz) + 1.57
						r:FromEuler(0,ay,-1.57 + ny*1.57)
						local phw = "RifleHitWall"
						local size = 0.5
						if gun.bulletHitWallParticle then
							phw = gun.bulletHitWallParticle
							size = gun.bulletHitWallParticleSize
						end
						AddPFX(phw,size,Vector:New(xcol,ycol,zcol),r)
						ENTITY.SpawnDecal(e,'bullethole',xcol,ycol,zcol,nx,ny,nz)
						playLogicRichochet =  true
					end
				end
				
            else		 -- entity whithout LUA gameobject            
				if not ENTITY.IsWater(e) then
					local r = Quaternion:New()
					local ay = math.atan2(nx,-nz) + 1.57
					r:FromEuler(0,ay,-1.57 + ny*1.57)    
					local phw = "RifleHitWall"
					local size = 0.5
					if gun.bulletHitWallParticle then
						phw = gun.bulletHitWallParticle
						size = gun.bulletHitWallParticleSize
					end
					AddPFX(phw,size,Vector:New(xcol,ycol,zcol),r)
					ENTITY.SpawnDecal(e,'bullethole',xcol,ycol,zcol,nx,ny,nz)
		
					playLogicRichochet =  true
					xcol2 = xcol
					ycol2 = ycol
					zcol2 = zcol
				end
	        end  
		end
		--table.insert(DEBUGgun, {srcx, srcy, srcz, srcx + x*gun.maxDist, srcy + y*gun.maxDist, srcz + z*gun.maxDist})
	end

	if playLogicRichochet then
		if math.random(100) < 50 then
			PlayLogicSound("RICOCHET",xcol2,ycol2,zcol2,5,10,Player)		-- fake, ze player
		end

        if not sndHit then
            local name = self.s_BulletHitWallSnd[math.random(1, table.getn(self.s_BulletHitWallSnd))]
            PlaySound3D("impacts/"..name,xcol2,ycol2,zcol2,22,52)
        end

	end

	if PO_Hit then
		ENTITY.PO_Hit(POe,xcol2,ycol2,zcol2,PO_Hitx*hitForce,PO_Hity*hitForce,PO_Hitz*hitForce)
	end
end
