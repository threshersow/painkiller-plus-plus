o.OnInitTemplate = CItem.StdOnInitTemplate

function Benzyna_Kolek:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end
