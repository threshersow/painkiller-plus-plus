function drzwidrewno:OnInitTemplate()
    self.Update = nil
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function drzwidrewno:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMeshNotCentered)
	ENTITY.PO_SetPinned( self._Entity, true )
end
