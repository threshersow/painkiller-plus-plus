o.OnInitTemplate = CItem.StdOnInitTemplate

function Automat:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
