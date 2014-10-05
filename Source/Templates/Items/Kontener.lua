o.OnInitTemplate = CItem.StdOnInitTemplate

function Kontener:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
