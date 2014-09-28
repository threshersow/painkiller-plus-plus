function o:OnInitTemplate()
    self:SetAIBrain()
    --self._AIBrain._lastSliceTime = 0
end


function o:OnCreateEntity()
	self:BindFX("smoke")
	--self:BindFX("pochodnia",0.1,"www333",0,0.4,0.7)
end

function o:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
				local idx  = MDL.GetJointIndex(self._Entity,self.s_SubClass.hitGroundJoint)
				--local x,y,z = self:GetJointPos(self.s_SubClass.hitGroundJoint)
				local x,y,z = MDL.TransformPointByJoint(self._Entity, idx,0,0.4,0.7)

				--[[if debugMarek then
					self.yzdebug1 = x
					self.yzdebug2 = y+0.2
					self.yzdebug3 = z
					self.yzdebug4 = x
					self.yzdebug5 = y-0.8
					self.yzdebug6 = z
				end--]]

				local b,d,x1,y1,z1,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(x,y+0.2,z,x,y-0.8,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("BodyBlood",0.2, Vector:New(x1,y1,z1),q)	-- FX_gib_blood

					if e then
						local b = {'bloodSmall','bloodSmall2','bloodSmall3'}
						ENTITY.SpawnDecal(e,b[math.random(1,3)],x,y,z,nx,ny,nz,1)
					end
				end
			end
		end
	end
end

------------------

function o:Flame()
	if not self._flameFX then
		local s = self.s_SubClass.ParticlesDefinitions.atak
		
        local idx  = MDL.GetJointIndex(self._Entity,s.joint)
        local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
        local q = Clone(Quaternion)
        q:FromEuler(0,-self.angle+math.pi/2,0)

	    self._flameFX = AddPFX(s.pfx, s.scale, Vector:New(x2,y2,z2), q)
	else
		if debugMarek then Game:Print("flame started???") end
	end
end

function o:OnTick()
end


function o:CheckDamageFromFlame()
	local angle = self.angle - 0.08
	
	for gg=1,3 do
		local v = Vector:New(math.sin(angle), 0, math.cos(angle))
		angle = angle + 0.08
		v:Normalize()
		if gg == 2 then
			v:MulByFloat(self.AiParams.flameRange)
		else
			v:MulByFloat(self.AiParams.flameRange*0.9)
		end
		
		local s = self.s_SubClass.ParticlesDefinitions.atak
		
		local idx  = MDL.GetJointIndex(self._Entity,s.joint)
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
		y2 = y2 - 0.2
		if debugMarek then
			if gg == 1 then
				self.yadebug1 = x2
				self.yadebug2 = y2
				self.yadebug3 = z2
				self.yadebug4 = x2 + v.X
				self.yadebug5 = y2 
				self.yadebug6 = z2 + v.Z
			end
			if gg == 2 then
				self.yaadebug1 = x2
				self.yaadebug2 = y2
				self.yaadebug3 = z2
				self.yaadebug4 = x2 + v.X
				self.yaadebug5 = y2 
				self.yaadebug6 = z2 + v.Z
			end
			if gg == 3 then
				self.yaaadebug1 = x2
				self.yaaadebug2 = y2
				self.yaaadebug3 = z2
				self.yaaadebug4 = x2 + v.X
				self.yaaadebug5 = y2 
				self.yaaadebug6 = z2 + v.Z
			end
		end
		local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x2,y2,z2, x2+v.X,y2,z2+v.Z)
		if e then
			--Game:Print("flame col")
			local obj = EntityToObject[e]
			if obj and obj.OnDamage then
				if obj ~= self then
					obj:OnDamage(self.AiParams.flameDamage*FRand(0.5,1.0), self)
					break
				end
			end
		end
	end
end    

function o:OnTick()
	if self._flameFX then
		--local idx  = MDL.GetJointIndex(self._Entity,"joint22")
		--Game:Print("PBindPFXToJoint:itck "..idx)
		local s = self.s_SubClass.ParticlesDefinitions.atak
	
		local idx  = MDL.GetJointIndex(self._Entity,s.joint)
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
		
        local q = Clone(Quaternion)
        q:FromEuler(0,-self.angle+math.pi/2+FRand(-0.04,0.04),0)
		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x2,y2,z2) 
	end
end



function o:EndFlame()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
end

function o:CustomOnDeath()
	self:EndFlame()
end
