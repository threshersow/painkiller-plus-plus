o.OnInitTemplate = CItem.StdOnInitTemplate

function BarrelBig:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end