o.OnInitTemplate = CItem.StdOnInitTemplate

function Vase:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
