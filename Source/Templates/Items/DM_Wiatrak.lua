o.OnInitTemplate = CItem.StdOnInitTemplate

function DM_Wiatrak:OnCreateEntity()
	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, self.FanRotateSpeed)
end
