o.OnInitTemplate = CItem.StdOnInitTemplate

function RFTGasContainer:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
    ENTITY.EnableCollisions(self._Entity, true, 0.25, self.Destroy.MinSpeedOnCollision*0.5)
    ENTITY.PO_SetAngularDamping(self._Entity,4.0)
    self.OnCollision = CItem.StdOnCollision
end
