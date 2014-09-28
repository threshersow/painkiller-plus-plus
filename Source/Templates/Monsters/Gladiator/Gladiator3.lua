function o:OnInitTemplate()
    self:SetAIBrain()
end

--function o:OnCreateEntity()
--	self:BindFX("pochodnia",0.1,self.s_SubClass.hitGroundJoint,0,-0.8,0)
--end


function o:OnPrecache()
    Cache:PrecacheParticleFX("monsterweap_hitground")
end

function o:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
				local idx  = MDL.GetJointIndex(self._Entity,self.s_SubClass.hitGroundJoint)
				--local x,y,z = self:GetJointPos(self.s_SubClass.hitGroundJoint)
				local x,y,z = MDL.TransformPointByJoint(self._Entity, idx,0,-0.6,0)

				--self.yzdebug1 = x
				--self.yzdebug2 = y+0.2
				--self.yzdebug3 = z
				--self.yzdebug4 = x
				--self.yzdebug5 = y-0.8
				--self.yzdebug6 = z

				local b,d,x1,y1,z1 = WORLD.LineTraceFixedGeom(x,y,z,x,y-1.0,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("monsterweap_hitground",0.2, Vector:New(x1,y1,z1),q)
				end
			end
		end
	end
end

function o:CustomOnDeath()
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end
