function Skeleton_Soldier:OnInitTemplate()
    self:SetAIBrain()
end

function Skeleton_Soldier:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(0, 3)
end

function Skeleton_Soldier:Ignite()
	if not self._isBurning and self.AIenabled and self.canBurn then
		if debugMarek then Game:Print(self._Name.." soldier ignite") end
		self.AIenabled = false
		self.enableAIin = 20
		self:SetIdle()
		self:PlaySound({"skeleton-burn"},22,52)
        self:BindSound(self._SoundDirectory.."Skeleton_fire-loop", 10, 50, true)

		-- podmiana dalekiego ataku na bliski
		local brain = self._AIBrain
        local aiParams = self.AiParams
		brain._goals = {}
		for i,v in aiParams.aiGoalsWhenBurn do
			table.insert(brain._goals, Clone(AiStates[v]))
		end
		brain._currentGoal = nil
		--
		
		if self.Health > 0 then
			self.Health = self._HealthMax * aiParams.burningHealthGain
			self._randomizedParams.WalkSpeed = self._randomizedParams.WalkSpeed * aiParams.burningWalkSpeedGain
			self._randomizedParams.RunSpeed = self._randomizedParams.RunSpeed * aiParams.burningWalkSpeedGain
		end
		
		self._isBurning = true
		--local tdj = self.s_SubClass.DeathJoints
		--if tdj then
			local size = self.burnPFXSize
			--for i=1,table.getn(tdj) do
            local tdj = "root"
            self:BindFX(self.burnPFX, size, tdj)
			--end
		--end
	end
end
