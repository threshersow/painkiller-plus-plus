o.OnInitTemplate = CItem.StdOnInitTemplate

function klatkaCol:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
