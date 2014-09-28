o.OnInitTemplate = CItem.StdOnInitTemplate

function o:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end

