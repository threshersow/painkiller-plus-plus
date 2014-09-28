o.OnInitTemplate = CItem.StdOnInitTemplate

function Skrz_Dynamite:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end
