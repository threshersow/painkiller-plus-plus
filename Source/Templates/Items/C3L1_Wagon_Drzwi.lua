o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L1_Wagon_Drzwi:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
    ENTITY.PO_SetPinned(self._Entity,true)
end

function C3L1_Wagon_Drzwi:OnDamage(damage, obj, attack_type, x, y, z , nx ,ny, nz )           
    ENTITY.PO_SetPinned(self._Entity,false)    
    CItem.OnDamage(self,damage)
end
