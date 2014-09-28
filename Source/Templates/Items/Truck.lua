o.OnInitTemplate = CItem.StdOnInitTemplate

function Truck:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
