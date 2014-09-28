o.Pinned = true

o.OnInitTemplate = CItem.StdOnInitTemplate

function dziura:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.Barrier)
end
