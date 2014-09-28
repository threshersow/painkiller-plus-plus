function o:OnCreateEntity()
    local brain = self._AIBrain
	brain._lastPfxTime = brain._currentTime
    self._PosPoisonTime = 0
	ENTITY.PO_EnableGravity(self._Entity, false)
end

