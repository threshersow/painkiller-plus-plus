o.OnInitTemplate = CItem.StdOnInitTemplate

function C6L1_drabinka:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.99)
    MDL.SetRagdollAngularDamping(self._Entity,0.99)
   
end

