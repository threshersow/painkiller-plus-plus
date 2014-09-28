function BarrelSmall_MP:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function BarrelSmall_MP:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
    ENTITY.EnableCollisions(self._Entity, true, 0.2, self.Destroy.MinSpeedOnCollision, 0.2)
    self.OnCollision = CItem.StdOnCollision
end
