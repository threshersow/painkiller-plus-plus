function o:OnInitTemplate()
    self:SetAIBrain()
    --self._AIBrain._lastSliceTime = 0
end

function o:CustomOnDeath()
	self:ReleaseTimers()
	if self._procBind then
        GObjects:ToKill(self._procBind)
    end
end

function o:OnApply()
	if not self._procBind then
		local r = self.s_SubClass.bindRagdoll
		if r then
			local obj = CloneTemplate(r.item)
			obj:Apply()
			
			local jChild = MDL.GetJointIndex(obj._Entity, "root")
			local jHold = MDL.GetJointIndex(self._Entity, r.joint)
			MDL.SetPinnedJoint(obj._Entity, jChild, true)
			MDL.SetRagdollLinearDamping(obj._Entity, 0.6)
			MDL.SetRagdollAngularDamping(obj._Entity, 0.6)

			self._procBind = Templates["PBindJointToJoint.CProcess"]:New(self._Entity, self, jHold, jChild, obj._Entity)
			self._procBind._holdJointPos = Vector:New(r.offset.X,r.offset.Y,r.offset.Z)
			--self._procBind._holdJointDisplace = Vector:New(r.offset.X,r.offset.Y,r.offset.Z)
			--self._procBind.CopyWholeMatrix = true
			self._procBind:Tick(0, true)
			GObjects:Add(TempObjName(), self._procBind)
			obj.NotSaveable = true
			self:AddTimer("blood",1.0)
		end
	end
end

function o:blood()
	local x,y,z = self:GetJointPos(self.s_SubClass.bindRagdoll.joint)
	self:BloodFX(x,y,z)
	local v = Vector:New(FRand(-1,1),FRand(0,1),FRand(-1,1))
	v:Normalize()
	AddPFX("BodyBlood",0.2,Vector:New(x,y,z),Quaternion:New_FromNormal(v.X, v.Y, v.Z))
end
