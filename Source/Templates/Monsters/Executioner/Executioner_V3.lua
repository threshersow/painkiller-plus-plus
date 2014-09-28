function Executioner_V3:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastSliceTime = 0
	self._dontPinStake = true

	self._AIBrain._lastThrowTime = FRand(-3,1)
	if debugMarek then
		self._AIBrain._lastThrowTime = -100
	end
end

--------------------------

Executioner_V3._CustomAiStates.spikeAttack = {
	name = "spikeAttack",
	active = false,
}

function Executioner_V3._CustomAiStates.spikeAttack:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:SetAnim("atak_strzal",false)
	self.active = true
	self.mode = 0
	self.time = aiParams.spikesFlyingTime * 30
	actor._disableHits = true
	--Game:Print("spikes1")
	actor:FullStop()
	--Game.freezeUpdate = true
	--if debugMarek then WORLD.SetWorldSpeed(1/8) end
	actor._spikesThrown = 2
end

function Executioner_V3._CustomAiStates.spikeAttack:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if self.mode == 0 --[[and not actor._isRotating--]] then
		if brain.r_closestEnemy then
			actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz)
		end
		local speed = MDL.GetAnimTimeScale(actor._Entity, actor._CurAnimIndex)
		if speed == 0 then
			self.mode = 1
			actor:FullStop()
			--Game:Print("spikes2")
		else
			if actor.Animation ~= "atak_strzal" then
				self.active = false
			end
		end
	end
	if self.mode == 1 then
		self.time = self.time - 1
		if self.time < 0 or actor._spikesThrown <= 0 then
			self.mode = 2
			--Game:Print("spikes3")
			actor:SetAnim("atak_strzal_powrot",false)
		end
	end
	if self.mode == 2 and not actor._isAnimating then
		--Game:Print("spikes4")
		self.active = false
	end
	
	brain._lastThrowTime = brain._currentTime
end

function Executioner_V3._CustomAiStates.spikeAttack:OnRelease(brain)
	local actor = brain._Objactor
	brain._lastThrowTime = brain._lastThrowTime + FRand(0,1)
	actor._disableHits = false
	self.active = false
	--Game:Print("spikes end")
end

function Executioner_V3._CustomAiStates.spikeAttack:Evaluate(brain)
	if self.active then
		return 0.81
	else
        if brain.r_closestEnemy then
		    local actor = brain._Objactor
			local aiParams = actor.AiParams
            if brain._lastThrowTime + aiParams.minDelayBetweenThrow < brain._currentTime then
				--if aiParams.throwAmmo > 0 then
					if brain._distToNearestEnemy < aiParams.throwRangeMax and brain._distToNearestEnemy > aiParams.throwRangeMin then
						--if math.random(100) < (10 - brain.r_closestEnemy._velocity) * 4 then
							return 0.61
						--end
					end
				--end
			end
		end
	end
	return 0.0
end

