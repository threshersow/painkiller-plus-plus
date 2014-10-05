o.OnInitTemplate = CItem.StdOnInitTemplate

function deto_pack:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
