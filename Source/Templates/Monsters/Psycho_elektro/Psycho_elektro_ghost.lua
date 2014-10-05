function Psycho_elektro_ghost:OnCreateEntity()
	self._time = self.LifeTime
	ENTITY.RemoveRagdoll(self._Entity)
end

Psycho_elektro_ghost.CustomUpdate = nil


function Psycho_elektro_ghost:OnTick(delta)
	self._time = self._time - delta
	if self._time < 0 then
		GObjects:ToKill(self)
	end
end
