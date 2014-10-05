o.OnInitTemplate = CItem.StdOnInitTemplate

function C3L4_katapulta:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.8)
    MDL.SetRagdollAngularDamping(self._Entity,0.8)
end

