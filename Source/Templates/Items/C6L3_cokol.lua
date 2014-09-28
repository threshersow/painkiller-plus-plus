function o:OnInitTemplate()
    self.Update = nil
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function o:OnCreateEntity()
	--self:PO_Create(BodyTypes.FromMeshNotCentered)
	self:PO_Create(BodyTypes.FromMesh)
	--ENTITY.PO_SetPinned( self._Entity, true )
end

function o:OnDestroy()
	local parts = WORLD.GetLastExplodedEntities(entity)
    for i,v in parts do
        MESH.SetMeshGroup(v, 70)
        ENTITY.EnableCollisions(v, true, 2.0, 6.0)
    end
end
