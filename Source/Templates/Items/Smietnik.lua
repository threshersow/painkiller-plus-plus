o.OnInitTemplate = CItem.StdOnInitTemplate

function Smietnik:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end

