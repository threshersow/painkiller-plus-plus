o.OnInitTemplate = CItem.StdOnInitTemplate

function BarrelSmall:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end
