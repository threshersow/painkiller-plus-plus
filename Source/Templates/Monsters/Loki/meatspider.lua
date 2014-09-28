function meatspider:OnPrecache()
	Cache:PrecacheItem(self.fxbl)
end

function meatspider:OnCreateEntity()
	MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollSpecial)
end

function meatspider:OnUpdate()
	if math.random(100) < 3 then
		local idx  = MDL.GetJointIndex(self._Entity, "root")
		local x,y,z = MDL.GetJointPos(self._Entity, idx)
		local ke = AddItem(self.fxbl,0.3,Vector:New(x,y,z),true)
		ENTITY.PO_SetCollisionGroup(ke, ECollisionGroups.InsideItems)
	end
end
