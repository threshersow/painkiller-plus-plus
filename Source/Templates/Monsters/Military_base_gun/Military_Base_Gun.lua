function Military_Base_Gun:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastThrowTime = FRand(-3, 3)
	self._dontPinStake = true
end

function Military_Base_Gun:OnCreateEntity()
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)
	ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)
	--self:BindSound("actor/tank/tank-idle-loop",20,100,true)
	--self._moveSnd = nil
	self._turretSnd = nil
	self._turretSound = nil
	self._lastAngleAttackX = 0
	self._barrelPitch = 0
    self._disableGibSound = true
	----self:BindFX("pochodnia",0.3,"lufa",0,0.6,-5.6)
	--if debugMarek then ENTITY.PO_EnableGravity(self._Entity, false) end
	self:AddTimer("pin",1.0)
end

function Military_Base_Gun:pin()
    ENTITY.PO_SetPinned(self._Entity, true)
    self:ReleaseTimers()
end


function Military_Base_Gun:CustomOnDeath()
	--self:CreateGib("skeletonsoldier_gib")
	MDL.SetMeshVisibility(self._Entity,"soldatShape", false)
end


function Military_Base_Gun:CustomOnDeathAfterRagdoll()
	if self._turretSound then
		ENTITY.Release(self._turretSound)
		self._turretSound = nil
	end
    local x,y,z = self:GetJointPos("root")
    y = y - 0.3
    WORLD.Explosion2(x,y,z, self.Explosion.ExplosionStrength,self.Explosion.ExplosionRange,nil,AttackTypes.Rocket,self.Explosion.Damage)
    --self:BindFX("barrel_flame_fx", 0.8, "root")
    self:BindFX("explode")
    self:BindFX("tankflame")
    self:BindFX("tankflameBarrel")
    self:BindFX("warp")
	local j = MDL.GetJointIndex(self._Entity,"root")
	self:BindSound("actor/skeleton_soldier/Skeleton_fire-loop",10,40, true, j)
	MDL.SetPinnedJoint(self._Entity, j, true)
	MDL.SetPinnedJoint(self._Entity, MDL.GetJointIndex(self._Entity,"ROOOT"), true)

	local r = Quaternion:New_FromEuler(0,-self._lastAngleAttackX+math.pi,0)
	local v = Vector:New(math.sin(self._lastAngleAttackX),0,math.cos(self._lastAngleAttackX))
	local obj = AddObject("Skeleton_Soldier.CActor",nil,Vector:New(x,y+6,z),r,true) 
	ENTITY.PO_SetCollisionGroup(obj._Entity, ECollisionGroups.Noncollidong)
	obj:Ignite()
    --obj.throwHeart = false
    obj.NotCountable = true
	obj.DeathTimer = self.DeathTimer
	obj.enableGibWhenHPBelow = nil
	ENTITY.SetVelocity(obj._Entity, -v.X*self.throwSkeletonSoldierVelocityXZ, self.throwSkeletonSoldierVelocityY, -v.Z*self.throwSkeletonSoldierVelocityXZ)
	obj:OnDamage(99999,obj)
end


function Military_Base_Gun:OnTick(delta)
	--if (math.abs(self._angleAttackX - self._lastAngleAttackX) > 0.02) or (math.abs(self._angleAttackY - self._lastAngleAttackY) > 0.02) then
	if math.abs(self._AIBrain._diffInangleAttackX) > 0.01 then
		if not self._turretSnd then
			self._turretSound, self._turretSnd = self:BindSound("actor/military_base_gun/cannon-rotate-loop",20,60, true)
			self._countdownToStopSound2 = nil
		end
	else
		if self._turretSnd then
			if not self._countdownToStopSound2 then
				self._countdownToStopSound2 = 0.2
			end
			self._countdownToStopSound2 = self._countdownToStopSound2 - delta
			if self._countdownToStopSound2 < 0 then
				if SND.IsPlaying(self._turretSnd) then
					local e = ENTITY.GetPtrByIndex(self._turretSnd)
					if e then
						ENTITY.Release(e)
					end
					self._turretSnd = nil
					self._turretSound = nil
				end
			end
		end
	end

	self._lastAngleAttackX = self._angleAttackX

	if self._AIBrain.r_closestEnemy and Player then
		local joint = MDL.GetJointIndex(self._Entity, "lufa")
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
		MDL.ApplyJointRotation(self._Entity, joint, -self._barrelPitch, 0, 0)
	end

end


--------------------------------------

Military_Base_Gun._CustomAiStates = {}

Military_Base_Gun._CustomAiStates.militarybasegunFire = {
	name = "militarybasegunFire",
    delayRandom = 1,
}

function Military_Base_Gun._CustomAiStates.militarybasegunFire:OnInit(brain)
end

function Military_Base_Gun._CustomAiStates.militarybasegunFire:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
    if brain.r_closestEnemy and not self.delay then
		local actor = brain._Objactor
		local aiParams = actor.AiParams
        if brain._lastThrowTime + self.delayRandom + aiParams.minDelayBetweenThrow < brain._currentTime then
			if aiParams.throwAmmo > 0 then
				if brain._distToNearestEnemy < aiParams.throwRangeMax and brain._distToNearestEnemy > aiParams.throwRangeMin then
					self.delay = 10
				end
			end
		end
	end
	
	if self.delay then
		self.delay = self.delay - 1
		if self.delay == 1 then
			local e
			local idx  = MDL.GetJointIndex(actor._Entity, "lufa")
			local q = Quaternion:New_FromEuler(0, -actor._angleAttackX - actor.angle + math.pi/2, math.pi/2)
			local x,y,z = MDL.TransformPointByJoint(actor._Entity, idx, 0,0.6,-5.6)
			e, actor._objTakenToThrow = AddItem(aiParams.ThrowableItem, nil, Vector:New(x,y,z),true,q)

			actor._objTakenToThrow.ObjOwner = actor
			actor:BindFX("shot")

			self.lockedAngle = actor._angleAttackX
			ENTITY.PO_Enable(e,false)
		end
		if self.delay <= 0 then
			self.delay = nil
			actor:PlaySound({"$/actor/tank/tank-shoot1","$/actor/tank/tank-shoot2"},80,120)
			actor:ThrowTaken(math.pi/2 - self.lockedAngle - actor.angle)
			brain._lastThrowTime = brain._currentTime
			self.delay = nil
            self.delayRandom = FRand(0.0,1.0)
            brain._lastThrowTime = brain._currentTime
		end
	end
end

function Military_Base_Gun._CustomAiStates.militarybasegunFire:OnRelease(brain)
end

function Military_Base_Gun._CustomAiStates.militarybasegunFire:Evaluate(brain)
	return 0.1
end

