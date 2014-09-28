o.OnInitTemplate = CItem.StdOnInitTemplate

function kupka:OnCreateEntity()
	self:PO_Create( BodyTypes.FromMesh, nil, ECollisionGroups.HCGNormalNCWithSelf)
	--self._burning = true
end
