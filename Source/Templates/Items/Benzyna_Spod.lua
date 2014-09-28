o.OnInitTemplate = CItem.StdOnInitTemplate

function Benzyna_Spod:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end
