o.OnInitTemplate = CItem.StdOnInitTemplate

function doors_opactwo:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end

