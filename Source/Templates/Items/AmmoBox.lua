o.OnInitTemplate = CItem.StdOnInitTemplate

function AmmoBox:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
