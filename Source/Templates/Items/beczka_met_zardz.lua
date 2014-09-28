o.OnInitTemplate = CItem.StdOnInitTemplate

function beczka_met_zardz:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end