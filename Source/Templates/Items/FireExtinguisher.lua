o.OnInitTemplate = CItem.StdOnInitTemplate

function FireExtinguisher:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
    ENTITY.PO_SetPinned(self._Entity,true)
end

function FireExtinguisher:OnDamage(damage, obj, attack_type, x, y, z , nx ,ny, nz )           
    ENTITY.PO_SetPinned(self._Entity,false)    
    CItem.OnDamage(self,damage)
end
