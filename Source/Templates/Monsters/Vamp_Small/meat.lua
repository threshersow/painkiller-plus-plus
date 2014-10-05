function meat:OnPrecache()
    Cache:PrecacheItem("VampBlood.CItem")    
end

function meat:OnCreateEntity()
	MDL.EnableRagdoll(self._Entity,true,RagdollNonColliding)
	for i,v in self.RagdollCollisions.Bones do
		local j = MDL.GetJointIndex(self._Entity, v)
		ENTITY.EnableCollisionsToRagdoll(self._Entity, j, self.RagdollCollisions.MinTime, self.RagdollCollisions.MinStren)
	end
	self._disableDamage = false
end

function meat:OnCollision(x,y,z,nx,ny,nz,e,he)
	--[[if e then
		local obj = EntityToObject[e]
		if not obj then
			obj = "noobj"
        else
            obj = obj._Name
		end
		if self._disableDamage then
			Game:Print(self._Name.." meat col e DD "..obj)
		else
			Game:Print(self._Name.." meat col e "..obj)
		end
	else
		if self._disableDamage then
			Game:Print(self._Name.." meat col no e DD ")
		else
			Game:Print(self._Name.." meat col no e ")
		end
	end--]]
	if math.random(100) < 50 then
		local a = MDL.GetJointFromHavokBody(self._Entity, he)
		if a and a ~= -1 then
			local ke = AddItem(self.fx,0.3,Vector:New(x,y + 0.01,z),true)
			--ENTITY.PO_SetCollisionGroup(ke, ECollisionGroups.InsideItems)
		end
	end

	local snd = false
	if e and not self._disableDamage then
		local obj = EntityToObject[e]
		if obj then
			if obj.OnDamage then
				local rnd = FRand(self.CollisionDamage*0.8, self.CollisionDamage*1.2)
				if obj == Player then
					PlaySound2D("actor/vamp_small/vamp_meathit")
					snd = true
				end
				obj:OnDamage(rnd, self.ObjOwner)
			end
		end
	end
	if not snd then
		PlaySound3D("impacts/meat-splash"..math.random(1,5),x,y,z,12,40)
	end
	if not self._disableDamage then
		ENTITY.PO_SetLinearDamping(self._Entity,0.6) 
		ENTITY.PO_SetAngularDamping(self._Entity,2.0)
		self._disableDamage = true
	end
end

function meat:Update()
	if self._throwed then
		self._throwed = self._throwed - 1
		if self._throwed < 0 then
			MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.RagdollNonColliding)
			self:BindSound("actor/vamp_small/vamp_stone-swish",4,28,false)
			self._throwed = nil
		end
	end

	if math.random(100) < 3 then
		local idx  = MDL.GetJointIndex(self._Entity, "root")
		local x,y,z = MDL.GetJointPos(self._Entity, idx)
		local ke = AddItem(self.fx,0.3,Vector:New(x,y,z),true)
		--ENTITY.PO_SetCollisionGroup(ke, ECollisionGroups.InsideItems)
	end


	if not MDL.IsPinnedJoint(self._Entity, self._pinnedJoint) then
		--Game:Print("not pinned")
	    if self.TimeToLive then
			if self.TimeToLive > 0 then
				self.TimeToLive = self.TimeToLive - 1
			else
				GObjects:ToKill(self)
				--Game:Print("not pinned...kill")
			end
		end
	end
end
