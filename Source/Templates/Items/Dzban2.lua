o.OnInitTemplate = CItem.StdOnInitTemplate

function Dzban2:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end