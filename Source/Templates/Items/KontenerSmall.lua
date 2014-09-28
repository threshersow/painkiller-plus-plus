o.OnInitTemplate = CItem.StdOnInitTemplate

function KontenerSmall:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
