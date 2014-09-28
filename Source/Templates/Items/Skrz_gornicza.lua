o.OnInitTemplate = CItem.StdOnInitTemplate

function Skrz_gornicza:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
