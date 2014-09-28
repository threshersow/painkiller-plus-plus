o.OnInitTemplate = CItem.StdOnInitTemplate

function beczka_met:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
