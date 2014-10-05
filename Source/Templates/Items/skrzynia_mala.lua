o.OnInitTemplate = CItem.StdOnInitTemplate

function skrzynia_mala:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
