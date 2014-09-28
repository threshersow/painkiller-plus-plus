function BarrelBig_MP:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function BarrelBig_MP:OnCreateEntity()
    self:PO_Create(BodyTypes.FromMesh)
    ENTITY.EnableCollisions(self._Entity, true, 0.2, self.Destroy.MinSpeedOnCollision, 0.2)
    self.OnCollision = CItem.StdOnCollision
end

--============================================================================
function BarrelBig_MP:OnRespawn(entity)
    local x,y,z = ENTITY.GetPosition(entity)
    AddObject("FX_ItemRespawn.CActor",1.5,Vector:New(x,y,z),nil,true) 
end
-------------------------------------------------------------------------------
Network:RegisterMethod("BarrelBig_MP.OnRespawn", NCallOn.AllClients, NMode.Reliable, "e")
