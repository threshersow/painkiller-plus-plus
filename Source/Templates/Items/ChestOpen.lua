o.OnInitTemplate = CItem.StdOnInitTemplate

function ChestOpen:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
