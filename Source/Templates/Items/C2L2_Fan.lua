o.OnInitTemplate = CItem.StdOnInitTemplate

function C2L2_Fan:OnCreateEntity()
	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, self.FanRotateSpeed)
end
