o.OnInitTemplate = CItem.StdOnInitTemplate

function Benzyna_Bok:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end
