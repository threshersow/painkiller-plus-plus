o.OnInitTemplate = CItem.StdOnInitTemplate


function kabina:OnCreateEntity()
    ENTITY.EnableNetworkSynchronization(self._Entity)
	self:PO_Create(BodyTypes.FromMesh)
end
