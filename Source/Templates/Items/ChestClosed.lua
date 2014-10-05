o.OnInitTemplate = CItem.StdOnInitTemplate

function ChestClosed:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
