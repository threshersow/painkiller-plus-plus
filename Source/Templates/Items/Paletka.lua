o.OnInitTemplate = CItem.StdOnInitTemplate


function Paletka:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
