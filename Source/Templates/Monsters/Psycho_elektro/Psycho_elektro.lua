function Psycho_elektro:OnInitTemplate()
    self:SetAIBrain()
end

function Psycho_elektro:CustomUpdate()
	if not self._tied and self.AIenabled then
		local utHp = self.AiParams.untieHp
		if self._HealthMax * utHp > self.Health or self._AIBrain._seeEnemy then
			self.s_SubClass = Clone(self.s_SubClass)
			self.s_SubClass.walk = {"walk_rozwiazany",}
			self.s_SubClass.Ambients = {"idle_rozwiazany",}
			self.s_SubClass.NearAttacks = {"atak_rozwiazany",}
			self:SetIdle()
			self.AIenabled = false
			self.enableAIin = 30
			self._tied = true
			self:PlaySound("rozw")
		end
	end
end
