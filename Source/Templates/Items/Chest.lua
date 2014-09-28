o.OnInitTemplate = CItem.StdOnInitTemplate

function Chest:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
