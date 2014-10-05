o.OnInitTemplate = CItem.StdOnInitTemplate

function Katafalk:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
