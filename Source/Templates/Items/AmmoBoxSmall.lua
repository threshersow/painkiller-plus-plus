o.OnInitTemplate = CItem.StdOnInitTemplate

function AmmoBoxSmall:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
