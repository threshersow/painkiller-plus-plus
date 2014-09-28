o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L3_Podstawka:OnCreateEntity()
    self:PO_Create( BodyTypes.FromMesh, nil, ECollisionGroups.HCGNormalNCWithSelf)
    ENTITY.PO_SetPinned( self._Entity, true )
end
