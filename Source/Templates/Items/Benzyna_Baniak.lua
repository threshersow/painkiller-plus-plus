o.OnInitTemplate = CItem.StdOnInitTemplate

function Benzyna_Baniak:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
	self._burning = true
end
