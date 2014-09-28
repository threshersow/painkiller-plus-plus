function Ghost:OnInitTemplate()
    self:SetAIBrain()
    self._lastTimeAmbientSound = 0
    self._sndDelayAdd = FRand(0, self.sndAmbientsWhileLiveMinDelayAdd)
end

function Ghost:OnCreateEntity()
	self._flyWithAngle = true
end

function Ghost:OnApply()
	self._moveSnd = self:BindSound(self._SoundDirectory.."ghost_onfly-loop", 10, 50, true)
	self._moveSndPtr = SND.GetSound3DPtr(self._moveSnd)
	SOUND3D.SetVolume(self._moveSndPtr, 0, 0)
	self._moveSndVol = 0
end

function Ghost:CustomOnDeath()
	if self._moveSnd then
		ENTITY.Release(self._moveSnd)
		self._moveSnd = nil
	end
end

function Ghost:CustomUpdate()
	local brain = self._AIBrain
	if self._lastTimeAmbientSound + self.sndAmbientsWhileLiveMinDelay + self._sndDelayAdd < brain._currentTime then	
		self._lastTimeAmbientSound = brain._currentTime
		--Game:Print("play rnd snd")
		self._sndDelayAdd = FRand(0, self.sndAmbientsWhileLiveMinDelayAdd)
		self:PlaySound("ambientsWhileLive")
	end

    if self.TimeToLive then
		self.TimeToLive = self.TimeToLive - 1
		if self.TimeToLive < 0 then
			self.TimeToLive = nil
			self:PlaySound("disap")
			GObjects:ToKill(self)
		end
    end
    if self._isWalking then
		if self._moveSndVol == 0 then
    		SOUND3D.SetVolume(self._moveSndPtr, 100, 1.0)
    		self._moveSndVol = 100
    	end
    else
		if self._moveSndVol == 100 then
			SOUND3D.SetVolume(self._moveSndPtr, 0, 1.0)
			self._moveSndVol = 0
		end
    end
end


-----------------
AiStates.ghostAttack = {			-- narazie, pozniej wywalenie idle
	name = "ghostAttack",
	lastDamageTime = -100,
}

function AiStates.ghostAttack:OnUpdate(brain)
	local actor = brain._Objactor
	
	--if not actor._isRotating then
		local modyf = brain._distToNearestEnemy
		if modyf > 10 then
			modyf = 10
		end
		modyf = modyf - 2
		
		if math.random(1000) < 30 + modyf*3 then
--			Game:Print("walkto n")
			actor:WalkTo(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy + FRand(0.7, 1.3), brain.r_closestEnemy._groundz)
--		else
--			if math.random(100) < 3 and brain._distToNearestEnemy > 4 then
--				Game:Print("rotateton")
--				--actor:Stop()
--				--actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
--				actor:WalkTo(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy + FRand(0.7, 1.3), brain.r_closestEnemy._groundz)
--			end
		end

	if not actor._isWalking then
		Patrol(actor, brain, false, true)
	end

end

function AiStates.ghostAttack:Evaluate(brain)
	if brain.r_closestEnemy then
		-- do damage
		local actor = brain._Objactor
		local aiParams = actor.AiParams
		if self.lastDamageTime + aiParams.damageFreq < brain._currentTime then
			self.lastDamageTime = brain._currentTime
			local distToEnemy = Dist3D(actor._groundx, actor._groundy, actor._groundz, brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy + 1.7, brain.r_closestEnemy._groundz)
			if distToEnemy < aiParams.damageRange then
				brain.r_closestEnemy:OnDamage(aiParams.damage, actor)
                actor:PlaySound("bodyhit")
			end
		end
		--

		if not brain._Objactor.AiParams.WalkAreaWhenAttack then
			return 0.2
		end
	end

	return 0
end

