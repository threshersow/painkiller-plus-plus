o.OnInitTemplate = CItem.StdOnInitTemplate

function Stojak_2:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
