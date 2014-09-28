function Tank:OnPrecache()
    Cache:PrecacheParticleFX("explode")
    Cache:PrecacheParticleFX("tankflame")
    Cache:PrecacheParticleFX("tankflameTurret")
    Cache:PrecacheParticleFX("GasTankExplode")
end
    
function Tank:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastThrowTime = FRand(-3, 3)
    self._dontPinStake = true
end

function Tank:OnCreateEntity()
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalBodyNCWithSelf)
	ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	self._engineSnd = self:BindSound("actor/tank/tank-idle-loop",20,100,true)
	self._moveSnd = nil
	self._turretSnd = nil
	self._lastAngleAttackX = 0
	self._lastAngleAttackY = 0
    self._barrelPitch = 0
	self._disableGibSound = true
	
	--[[for i=1,4 do
		local j = MDL.GetJointIndex(self._Entity, "g"..i)
		ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 1.0, 2.0)
		Game:Print(j)
	end
	local j = MDL.GetJointIndex(self._Entity, "ROOOT")
	ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 1.0, 2.0)--]]
	--ENTITY.EnableCollisions(self._Entity, true)
end

--function Tank:OnCollision()
--	Game:Print(" Tank col")
--end

function Tank:CustomOnDamage(he,x,y,z,obj, damage, type)
	if type == AttackTypes.Tank then
		return true
	end
    if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        if j then
			local name = MDL.GetJointName(e,j)
            self._hitGasTank = false
			if name == "b1" or name == "b2" then
                self._hitGasTank = name
				--self:BindFX('GasTankExplode',nil,j)
				--if self.Health > 1 then
				--	self.Health = 1
				--end
                return false, damage * 2
			end
        end
    end
end

function Tank:CustomOnDeathAfterRagdoll()
    if self._turretSound then
		ENTITY.Release(self._turretSound)
		self._turretSound = nil
    end
    if self._moveSound then
		ENTITY.Release(self._moveSound)
		self._moveSound = nil
    end
    if self._engineSnd then
        ENTITY.Release(self._engineSnd)
        self._engineSnd = nil
    end

    if self._hitGasTank then
        self:BindFX('GasTankExplode',nil,self._hitGasTank)
    end

    self:BindFX("explode")
    self:BindFX("tankflame")
    self:BindFX("tankflameTurret")
    
    self:BindFX("warp")
    local x,y,z = self:GetJointPos("k_head")
    y = y - 2.0
    local j = MDL.GetJointIndex(self._Entity,"ROOOT")
    self:BindSound("actor/skeleton_soldier/Skeleton_fire-loop",10,40, true, j)
    MDL.SetPinnedJoint(self._Entity, j, true)
    j = MDL.GetJointIndex(self._Entity,"k_head")
    MDL.ApplyVelocitiesToJoint(self._Entity, j, 0,self.turretExplodeUp,0)
    WORLD.Explosion2(x,y,z, self.Explosion.ExplosionStrength,self.Explosion.ExplosionRange,nil,AttackTypes.Rocket,self.Explosion.Damage)
    if Game._EarthQuakeProc then
        Game._EarthQuakeProc:Add(x,y,z, 15, 20 --[[g.ExplosionCamDistance--]], 0.25, 0.25)
    end

end

function Tank:RotateToVector(tx,ty,tz)
	self._angleDest = math.atan2(tx - self._groundx, tz - self._groundz)
	self:RotTank()
end

function Tank:RotTank()
	local angDest = AngDist(self.angle, self._angleDest)
	local angDest2 = AngDist(self.angle, self._angleDest + math.pi)
	if math.abs(angDest2) < math.abs(angDest) then
		self._angleDest = self._angleDest + math.pi
	end
--[[	if angDest > math.pi/2 then
		Game:Print(self._Name.." +a")	-- to zle
		self._angleDest = math.pi - self._angleDest
	end
	if angDest < -math.pi/2 then
		Game:Print(self._Name.." +b")
		self._angleDest = math.pi + self._angleDest
	end--]]
	self._isRotating = true
end

function Tank:Rotate(ang)
	self._angleDest = math.mod(self.angle + ang * math.pi/180, math.pi*2)
	self:RotTank()
end

function Tank:RotateTo(ang)
	self._angleDest = math.mod(ang * math.pi/180, math.pi*2)
	self:RotTank()
end


function Tank:OnTick(delta)
	local x,y,z,v = ENTITY.GetVelocity(self._Entity)
	-- okreslenie kierunku jazdy
	if v > 1 and not self._moveSnd then
		local snd
		self._moveSound, self._moveSnd = self:BindSound("actor/tank/tank-move-loop",20,100, true)
		--Game:Print("start sound "..self._moveSnd)
		self._countdownToStopSound = nil
	end
	if v < 0.5 and self._moveSnd then
		if not self._countdownToStopSound then
			self._countdownToStopSound = 0.2
		end
		self._countdownToStopSound = self._countdownToStopSound - delta
		if self._countdownToStopSound < 0 then
			if SND.IsPlaying(self._moveSnd) then
				local e = ENTITY.GetPtrByIndex(self._moveSnd)
				if e then
					--Game:Print("stop sound")
					--self._moveSound
					ENTITY.Release(e)
				end
				self._moveSnd = nil
				self._moveSound = nil
			end
		end
	end
	
	--if (math.abs(self._angleAttackX - self._lastAngleAttackX) > 0.2) or (math.abs(self._angleAttackY - self._lastAngleAttackY) > 0.2) then
	if math.abs(self._AIBrain._diffInangleAttackX) > 0.01 then
		if not self._turretSnd then
			self._turretSound, self._turretSnd = self:BindSound("actor/tank/tank-move-loop",20,60, true)
			--Game:Print("start sound turret")
			self._countdownToStopSound2 = nil
		end
	else
		if self._turretSnd then
			if not self._countdownToStopSound2 then
				self._countdownToStopSound2 = 0.25
			end
			self._countdownToStopSound2 = self._countdownToStopSound2 - delta
			if self._countdownToStopSound2 < 0 then
				if SND.IsPlaying(self._turretSnd) then
					local e = ENTITY.GetPtrByIndex(self._turretSnd)
					if e then
						--Game:Print("stop sound turret")
						ENTITY.Release(e)
					end
					self._turretSnd = nil
					self._turretSound = nil
				end
			end
		end
	end
	local przod = 1 
	if self._isWalking then
		local v2 = Vector:New(x,y,z)
		v2:Normalize()
	
		local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
		v:Normalize()
		
		local dotProduct = v2.X * v.X + v2.Y * v.Y + v2.Z * v.Z

		if dotProduct > 0 then
			przod = -1
		end
	end
	
	--
	self._lastAngleAttackX = self._angleAttackX
	self._lastAngleAttackY = self._angleAttackY

	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, v*0.2*przod)
	
	-- kilowanie
	if v > 1 then
		local range = 2
		local j = MDL.GetJointIndex(self._Entity, self.s_SubClass.killJoint)
		local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,przod*-3.5)
		DebugSphereX = x
		DebugSphereY = y - 0.6
		DebugSphereZ = z
		DebugSphereRange = 2
		if przod > 0 then
			DebugSphereRange = 2.5
			range = 2.5
		end
		WORLD.Explosion2(x,y - 0.6,z, 100,range,nil,AttackTypes.Tank,300)
 
	end
	--
	
	if self._AIBrain.r_closestEnemy and Player and not self._disableRotateHead then
		local joint = MDL.GetJointIndex(self._Entity, self.AiParams.weaponBindPos)
		local x,y,z = MDL.TransformPointByJoint(self._Entity,joint,0,0,0)	--0,0.6,-5.6)
		
		local aiParams = self.AiParams
		local pitch
		local distToTarget = Dist3D(x,y,z, Player._groundx, Player._groundy + 1.2,Player._groundz)
		
		local v = Vector:New(Player._groundx - x, Player._groundy + 1.2 - y, Player._groundz - z)
		v:Normalize()
		local angleToPlayer = math.atan2(v.Z, v.X)
		local maxRotateSpeed = 0.5 * delta
		local diff
		if distToTarget > 4 and distToTarget < 260 then
			local x2,y2,z2
			x2,y2,z2,pitch = CalcThrowVectorGivenVelocity(distToTarget - aiParams.throwDistMinus, aiParams.throwVelocity, angleToPlayer, Player._groundy + 1.2 - y, math.pi)
			if pitch < -0.1 then
				pitch = -0.1
			end
			if pitch > math.pi/3 then
				pitch = math.pi/3
			end

			if debugMarek then
				DEBUG1 = x
				DEBUG2 = y + 0.01
				DEBUG3 = z
				DEBUG4 = x + x2
				DEBUG5 = y + y2 + 0.01
				DEBUG6 = z + z2
			end
			diff = self._barrelPitch - pitch
		else
			diff = self._barrelPitch
		end
		if diff > maxRotateSpeed then
			diff = maxRotateSpeed
		end
		if diff < -maxRotateSpeed then
			diff = -maxRotateSpeed
		end

		self._barrelPitch = self._barrelPitch - diff
		if self._barrelPitch < -0.04 then
			self._barrelPitch = -0.04
		end
		MDL.ApplyJointRotation(self._Entity, joint, self._barrelPitch, 0, 0)
	end


end

------------------------------------------

Tank._CustomAiStates = {}
Tank._CustomAiStates.tankIdle = {
	name = "tankIdle",
}

function Tank._CustomAiStates.tankIdle:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	self.GuardStill = aiParams.GuardStill
	self.walked = false
	self._dir = 1
end

function Tank._CustomAiStates.tankIdle:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if not self.GuardStill then
		if not actor._isWalking and brain._walkArea then
			if aiParams.stopAfterWalking and FRand(0.0, 1.0) <= aiParams.stopAfterWalking and self.walked then
				self.timeChangeStillToFalse = math.random(aiParams.stopAfterWalkingTime[1],aiParams.stopAfterWalkingTime[2])
				self.GuardStill = true
				actor._canPlayStartEngine = true
				self.walked = false
				return
			else
				if actor._canPlayStartEngine then
					actor._canPlayStartEngine = nil
					actor:PlaySound("engineAccelerate")
				end
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
					
					actor:WalkTo(brain._walkArea.Points[rnd].X, brain._walkArea.Points[rnd].Y, brain._walkArea.Points[rnd].Z, false)
				else
					local dist = Dist2D(brain._walkArea.Points[brain._walkAreaNo].X, brain._walkArea.Points[brain._walkAreaNo].Z,actor._groundx,actor._groundz)
					if debugMarek then Game:Print(actor._Name.." dist to point = "..dist) end
					if dist < 3 then 
						brain._walkAreaNo = brain._walkAreaNo + self._dir
						if aiParams.WalkAreaPingPong and brain._walkAreaNo < 1 then
							if table.getn(brain._walkArea.Points) > 1 then
								brain._walkAreaNo = 2
							end
							self._dir = -self._dir
						end

						if brain._walkAreaNo > table.getn(brain._walkArea.Points) then
							if aiParams.WalkAreaPingPong then
								self._dir = -self._dir
								brain._walkAreaNo = brain._walkAreaNo - 2
							else
								brain._walkAreaNo = 1
							end
						end
						if brain._walkAreaNo < 1 then
							brain._walkAreaNo = 1
						end
					end
					
					--Game:Print(actor._Name.." wa "..brain._walkAreaNo)
					actor:WalkTo(brain._walkArea.Points[brain._walkAreaNo].X, brain._walkArea.Points[brain._walkAreaNo].Y, brain._walkArea.Points[brain._walkAreaNo].Z, false)
				end
				self.walked = true
			end
		end
	else
		self.timeChangeStillToFalse = self.timeChangeStillToFalse - 1
		if self.timeChangeStillToFalse < 0 then
			self.GuardStill = false
		end
		
	end
end

function Tank._CustomAiStates.tankIdle:OnRelease(brain)
	local actor = brain._Objactor
end


function Tank._CustomAiStates.tankIdle:Evaluate(brain)
	return 0.01
end


---------------------------------
Tank._CustomAiStates.tankFire = {
	name = "tankFire",
	delayRandom = FRand(0,1),
}

function Tank._CustomAiStates.tankFire:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	brain._lastThrowTime = brain._currentTime
	
	local v = Vector:New(brain.r_closestEnemy._groundx - actor.Pos.X, 0, brain.r_closestEnemy._groundz - actor.Pos.Z)
	v:Normalize()
	local angleToPlayer = math.atan2(v.X, v.Z)
	local aDist = AngDist(actor._angleAttackX + actor.angle, angleToPlayer)
	Game:Print((angleToPlayer*180/math.pi).." CZOLG adist = "..(aDist*180/math.pi))
	if math.abs(aDist*180/math.pi) > aiParams.throwMaxAngleYawDiff then
		return
	end

	
	if actor._isWalking then
		actor:Stop()
		actor._canPlayStartEngine = true
		--brain._walkAreaNo = brain._walkAreaNo - 1
		--if brain._walkAreaNo < 1 then
		--	brain._walkAreaNo = table.getn(brain._walkArea.Points)
		--end
	end
    actor._disableHits = true
	self._throwed = true
	self.active = true
	self.mode = 0
	
	actor._disableRotateHead = false
	self.delay = 15	
	-- tu pozniej sprawdzac, czy roznica katow player/lufa nie jest za duza
end

function Tank._CustomAiStates.tankFire:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if self.delay then
		self.delay = self.delay - 1
		if self.delay == 1 then
			local e
			local idx  = MDL.GetJointIndex(actor._Entity, aiParams.weaponBindPos)
			local q = Quaternion:New_FromEuler(0, math.pi/2 - actor._angleAttackX - actor.angle, math.pi/2)
			local x,y,z = MDL.TransformPointByJoint(actor._Entity, idx, aiParams.weaponBindPosShift.X, aiParams.weaponBindPosShift.Y, aiParams.weaponBindPosShift.Z)
			e, actor._objTakenToThrow = AddItem(aiParams.ThrowableItem, nil, Vector:New(x,y,z),true,q)
			actor._objTakenToThrow.ObjOwner = actor
			local pd = actor.s_SubClass.ParticlesDefinitions.shot
			AddPFX(pd.pfx, pd.scale, Vector:New(x,y,z), q)
			brain._lockedAngle = actor._angleAttackX
			actor._disableRotateHead = true
			ENTITY.PO_Enable(e,false)
		end
		if self.delay == 0 then
			actor:PlaySound({"tank-shoot1","tank-shoot2"},80,120)
			actor:ThrowTaken(math.pi/2 - brain._lockedAngle - actor.angle)
			brain._lastThrowTime = brain._currentTime
		end
		if self.delay < -15 then
			self.delay = nil
			self.active = false
		end
	end
end

function Tank._CustomAiStates.tankFire:OnRelease(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams

	actor._disableRotateHead = false		-- pozniej po delay
	self.delayRandom = FRand(0,aiParams.minDelayBetweenThrow)
	self.active = false
    actor._disableHits = nil
    if actor._objTakenToThrow then
        Game:Print(actor._Name.." ERROR: actor._objTakenToThrow still exists")
    end
end

function Tank._CustomAiStates.tankFire:Evaluate(brain)

--[[
    if brain.r_closestEnemy then
        local actor = brain._Objactor
        local v = Vector:New(brain.r_closestEnemy._groundx - actor.Pos.X, 0, brain.r_closestEnemy._groundz - actor.Pos.Z)
        v:Normalize()
        local angleToPlayer = math.atan2(v.X, v.Z)
        Game:Print("angleToPlayer = "..angleToPlayer*180/math.pi.."  ax = "..(actor._angleAttackX + actor.angle)*180/math.pi.." actor.angle = "..actor.angle*180/math.pi)
    end
]]

	if self.active then
		return 0.8
	else
        if brain.r_closestEnemy then
		    local actor = brain._Objactor
			local aiParams = actor.AiParams
            if brain._lastThrowTime + self.delayRandom + aiParams.minDelayBetweenThrow < brain._currentTime then
				if aiParams.throwAmmo > 0 then
					if brain._distToNearestEnemy < aiParams.throwRangeMax and brain._distToNearestEnemy > aiParams.throwRangeMin then
						if math.random(100) < (10 - brain.r_closestEnemy._velocity) * 4 then
							return 0.61
						end
					end
				end
			end
		end
	end
	return 0
end

