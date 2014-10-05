o.OnInitTemplate = CItem.StdOnInitTemplate

function Pudlo_karton:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
