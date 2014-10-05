o.OnInitTemplate = CItem.StdOnInitTemplate

function Coffin:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
