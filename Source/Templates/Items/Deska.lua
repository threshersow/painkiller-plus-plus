o.OnInitTemplate = CItem.StdOnInitTemplate

function Deska:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end
