function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
	self._handl = self:BindFX("burningHandl")
	self._handr = self:BindFX("burningHandr")
end

function o:OnThrow()
    local brain = self._AIBrain
	brain._lastHitTime = brain._currentTime
	brain._lastMissedTime = brain._currentTime - 1
    self._playSndCol = false
end

function o:OnAttack()
	self._ataklFX = self:BindFX("atakl")
    self._atakpFX = self:BindFX("atakp")
end
