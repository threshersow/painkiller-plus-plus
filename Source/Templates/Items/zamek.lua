function o:OnInitTemplate()
    self.Update = nil
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function o:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMeshNotCentered)
	ENTITY.PO_SetPinned( self._Entity, true )
	ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.Noncolliding)
end
