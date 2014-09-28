o.OnInitTemplate = CItem.StdOnInitTemplate

function Bankomat:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
