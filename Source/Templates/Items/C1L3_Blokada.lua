o.OnInitTemplate = CItem.StdOnInitTemplate

function C1L3_Blokada:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
    ENTITY.EnableCollisions(self._Entity, true, 0.5, self.Destroy.MinSpeedOnCollision)
    self.OnCollision = CItem.StdOnCollision
end

