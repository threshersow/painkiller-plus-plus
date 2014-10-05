function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
    self:Flame2()
end

function o:Flame2()
	if not self._Flame2 then
		self._Flame2 = self:BindFX("burningHand")
	end
end

function o:CustomUpdate()
	if self._flameFX and not (self.Animation == "atak2" or self.Animation == "atak_fly") then
		self:FlameEnd()
	else
		if self._flameFX then
		end
	end
	if self.TimeToLive then
		self.TimeToLive = self.TimeToLive - 1
		if self.TimeToLive < 0 then
			self.TimeToLive = nil
			self:OnDamage(self.Health + 2, self)
		end
	end
end


function o:Flame()
	if not self._flameFX then
        local idx  = MDL.GetJointIndex(self._Entity,"k_glowa")
        local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
        local q = Clone(Quaternion)
        q:FromEuler(0,-self.angle+math.pi/2,0)

	    self._flameFX = AddPFX("flamethr", 0.4, Vector:New(x2,y2,z2), q)
	else
		if debugMarek then Game:Print("flame started???") end
	end
end


function o:CheckDamageFromFlame()
	local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v:Normalize()
	v:MulByFloat(self.AiParams.flameRange)
	local idx  = MDL.GetJointIndex(self._Entity,"k_glowa")
    local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
    y2 = y2 - 0.2
	if debugMarek then
		self.d1 = x2
		self.d2 = y2
		self.d3 = z2
		self.d4 = x2 + v.X
		self.d5 = y2 
		self.d6 = z2 + v.Z
	end

	local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x2,y2,z2, x2+v.X,y2,z2+v.Z)
	if e then
		Game:Print("flame col")
		
		local obj = EntityToObject[e]
		if obj and obj.OnDamage then
            if obj ~= self then
                obj:OnDamage(self.AiParams.flameDamage, self)
            else
                Game:Print("col with self")
            end
		end
	end
end    

function o:CustomOnDamage(he,x,y,z,obj, damage, type,nx,ny,nz)
	if obj and obj == self then
		return true
	end
end

function o:OnTick()
	if self._flameFX then
        local idx  = MDL.GetJointIndex(self._Entity,"k_glowa")
        local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
        local q = Clone(Quaternion)
        q:FromEuler(0,-self.angle+math.pi/2,0)

		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x2,y2,z2) 
	end
end

function o:CustomOnDeathAfterRagdoll()
	self:FlameEnd()
	if self._Flame2 then
		PARTICLE.Die(self._Flame2)
	end
end

function o:FlameEnd()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end

	if not self._Flame2 then
		self:Flame2()
	end
end
