function o:OnInitTemplate()
    self:SetAIBrain()
    self._disableHits = true
    self._hitsCounter = 0
    self._AIBrain._lastThrowTime = FRand(-3, 3)
end


function o:Explode(joint)
	local x,y,z = self:GetJointPos(joint)
	--Game._EarthQuakeProc:Add(x,y,z, self.StompTimeOut, self.StompRange, self.CameraMov, self.CameraRot, 1.0)
	if debugMarek then
		DebugSphereX = x
		DebugSphereY = y + 1
		DebugSphereZ = z
		DebugSphereRange = self.AiParams.explosionWhenWalkRange
	end
	WORLD.Explosion2(x,y + 1,z, self.AiParams.explosionWhenWalkStreng, self.AiParams.explosionWhenWalkRange, nil, AttackTypes.Step, self.AiParams.explosionWhenWalkDamage)		-- damege na zero?
    local j = MDL.GetJointIndex(self._Entity, joint)
end

function o:CustomOnHit()
	if not self.s_SubClass.Hits then return end
	self._hitsCounter = self._hitsCounter + 1
	if self._hitsCounter >= 4 and not self._isRotating then
		self._hitsCounter = 0

		if not self._speeded then
			self._randomizedParams.WalkSpeed = self._randomizedParams.WalkSpeed * 1.1
			self._speeded = true
		end

		local animName = self.s_SubClass.Hits[math.random(1,table.getn(self.s_SubClass.Hits))]
						
		if not self.AIenabled and self._isAnimating then
			self._animationBeforeHit = self.Animation
		end
		if self:ForceAnim(animName, false) then
			self._lastHitAnim = animName
			self._hitDelay = self.minimumTimeBetweenHitAnimation
			if not self._hitDelay then
				self._hitDelay = 4
			end
			if self.AIenabled then
				self:Stop()
			else
				self._hitDelay = 99999	-- az do zakonczenia animacji
			end
		end
	end
end
