o.OnInitTemplate = CItem.StdOnInitTemplate

function wazka:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end