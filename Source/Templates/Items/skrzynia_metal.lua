o.OnInitTemplate = CItem.StdOnInitTemplate

function skrzynia_metal:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
end

