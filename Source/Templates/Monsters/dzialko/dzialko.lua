function dzialko:OnCreateEntity()
    --ENTITY.PO_EnableGravity(self._Entity,false)
    ENTITY.PO_SetMovedByExplosions(self._Entity,false)
    ENTITY.PO_SetPinned(self._Entity,true)
    ENTITY.PO_Activate(self._Entity,true)

    self:SetAIBrain()
	self.sounds = self.s_SubClass.Sounds
	self._soundSample = SOUND3D.Create("actor/dzialko/"..self.sounds.loop)
	SOUND3D.SetPosition(self._soundSample,self.Pos.X,self.Pos.Y,self.Pos.Z)
	SOUND3D.SetHearingDistance(self._soundSample,14,42)
	SOUND3D.SetLoopCount(self._soundSample,0) 
	self._startSound = nil
	self._startStop = nil
	self._lastAngleAttackX = 0
	self._lastAngleAttackY = 0
    self._timer = 0
end

function dzialko:CustomOnDeath()
	--Game:Print("dzialko death")
	self:AddPFX("explode")
	ENTITY.PO_EnableGravity(self._Entity, true)
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
end

function dzialko:CustomDelete()
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
end

function dzialko:CustomUpdate()
	if self._timer < 3 then
		self._timer = self._timer + 1
		return
	else
		self._timer = 0
	end
	--if (math.abs(self._angleAttackX - self._lastAngleAttackX) > 0.02) or (math.abs(self._angleAttackY - self._lastAngleAttackY) > 0.02) then
	--Game:Print(self._AIBrain._diffInangleAttackY.." "..self._AIBrain._diffInangleAttackX)
	if math.abs(self._AIBrain._diffInangleAttackY) > 0.01 or math.abs(self._AIBrain._diffInangleAttackX) > 0.01 then
		--if not self._startSound then
			--self._startSound = self:PlaySoundAndStopLast("gg-rotate-start")
			--self._startStop = nil
			--Game:Print("self._angleAttackX start")
			--return
		--end
		--if not self:IsPlayingLastSound(self._startSound) then
			if not SOUND3D.IsPlaying(self._soundSample) then
				--Game:Print("self._angleAttackX start loop")
				SOUND3D.Play(self._soundSample)
				self._canStop = true
			end
		--end
	else
		if SOUND3D.IsPlaying(self._soundSample) then
			--Game:Print("self._angleAttackX stop loop")
			SOUND3D.Stop(self._soundSample)
		end

		if self._startSound then
			self._startSound = nil
		end
		if not SOUND3D.IsPlaying(self._startStop) and self._canStop then
			self._startStop = self:PlaySoundAndStopLast("gg-rotate-stop")
			--Game:Print("self._angleAttackX stop")
			self._canStop = false
			return
		end
	end
	self._lastAngleAttackX = self._angleAttackX
	self._lastAngleAttackY = self._angleAttackY

end

o._CustomAiStates = {}
------------------
o._CustomAiStates.fire = {
	name = "fire",
}

function o._CustomAiStates.fire:OnInit(brain)
	local actor = brain._Objactor
	brain._enemyLastSeenShootTarget = Vector:New(0,0,0)

end

function o._CustomAiStates.fire:OnUpdate(brain)
	local actor = brain._Objactor
	if brain._seeEnemy then
		local Joint = MDL.GetJointIndex(actor._Entity, "joint2")
		local x,y,z = MDL.TransformPointByJoint(actor._Entity, Joint, 0,0,-1)
		brain._enemyLastSeenShootTarget.X = x
		brain._enemyLastSeenShootTarget.Y = y
		brain._enemyLastSeenShootTarget.Z = z
        local rh = actor.s_SubClass.rotateHead 
		if actor._angleAttackX < rh and actor._angleAttackX > -rh and
		   actor._angleAttackY < rh and actor._angleAttackY > -rh then
			--if actor._sndStoppableNAME ~= self.sounds.start then
			--	self.startSound = actor:PlaySoundAndStopLast(self.sounds.start)
			--end
			actor:SetAnim("atak", true)
		else
			--if actor._sndStoppableNAME ~= self.sounds.stop then
			--	actor:PlaySoundAndStopLast(self.sounds.stop)
			--end
			actor:SetAnim("idle", true)
		end
	else
		--if actor._sndStoppableNAME ~= self.sounds.stop and actor._sndStoppableNAME ~= "" then
		--	actor:PlaySoundAndStopLast(self.sounds.stop)
		--end
		actor:SetAnim("idle", true)
	end
	--[[if self.startSound then
		if actor.Animation == "atak" then
			if not actor:IsPlayingLastSound(self.startSound) then
				if not SOUND3D.IsPlaying(actor._soundSample) then
					SOUND3D.Play(actor._soundSample)
				end
			end
		else
			if not actor:IsPlayingLastSound(self.startStop) then
				if SOUND3D.IsPlaying(actor._soundSample) then
					SOUND3D.Stop(actor._soundSample)
				end
			end
		end
	end--]]
end


function o._CustomAiStates.fire:Evaluate(brain)
	return 0.1
end

