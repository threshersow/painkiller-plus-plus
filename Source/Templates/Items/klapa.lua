--function klapa:OnInitTemplate()
  --  self.Update = nil
  --  self._Synchronize = self.Synchronize
  --  self.Synchronize = nil
--end

--function klapa:OnCreateEntity()
--	self:PO_Create(BodyTypes.FromMeshNotCentered)
--	ENTITY.PO_SetPinned( self._Entity, true )
--end
o.OnInitTemplate = CItem.StdOnInitTemplate

function klapa:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end 