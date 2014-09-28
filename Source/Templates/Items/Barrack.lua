o.OnInitTemplate = CItem.StdOnInitTemplate

function Barrack:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
