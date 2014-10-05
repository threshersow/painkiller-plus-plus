o.OnInitTemplate = CItem.StdOnInitTemplate

function Paczka_gazety:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
