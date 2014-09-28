o.OnInitTemplate = CItem.StdOnInitTemplate

function C4L2_Lampa:OnCreateEntity()
    MDL.SetRagdollLinearDamping(self._Entity,0.3)
    MDL.SetRagdollAngularDamping(self._Entity,0.3)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
	if self.BillBoard then
		local a
		a, self._fx = AddObject(self.BillBoard[1],self.BillBoard[2],Vector:New(self.BillBoard[4],self.BillBoard[5],self.BillBoard[6]))
		local j = MDL.GetJointIndex(self._Entity,self.BillBoard[3])
		ENTITY.RegisterChild(self._Entity, self._fx, true, j)
	end
end

