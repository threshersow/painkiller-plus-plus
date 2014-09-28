function pentakl:OnCreateEntity()
	self._angler = 0
	self:BindFX("pentaklp",0.3)
end
--============================================================================
function pentakl:OnTake(player)
    if ENTITY.IsDrawEnabled(self._Entity) then
        self.Client_OnTake(player.ClientID,player._Entity,self._Entity,"pentakl")
    else
		return true
    end
end
--============================================================================
function pentakl:Tick(delta)
	self._angler = self._angler + delta * 1.5
	local q = Quaternion:New_FromEuler(0,self._angler,0)
	ENTITY.SetRotationQ(self._Entity, q.W, q.X, q.Y, q.Z)
end
