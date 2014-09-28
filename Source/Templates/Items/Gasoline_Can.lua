o.OnInitTemplate = CItem.StdOnInitTemplate

function Gasoline_Can:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
