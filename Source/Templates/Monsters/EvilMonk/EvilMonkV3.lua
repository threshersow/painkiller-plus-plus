function EvilMonkV3:OnInitTemplate()
    self:SetAIBrain()
end


function EvilMonkV3:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(-5, 1) 
    if debugMarek then
		self._AIBrain._lastThrowTime = -100
    end
	if self.flame_FX then
		self:Flame2()
	end

    self._soundSample = SOUND3D.Create("actor/evilmonkv3/evil_blowfire-loop")
	SOUND3D.SetHearingDistance(self._soundSample,14,42)
    SOUND3D.SetLoopCount(self._soundSample,0) 
    SOUND3D.SetVolume(self._soundSample, 0.0)

	
	local l = self.s_SubClass.Light
	if l then
		if Game._numberOfDynLigths < 3 then
			Game._numberOfDynLigths = Game._numberOfDynLigths + 1
			local obj = CloneTemplate(l.template)
			obj.Pos:Set(1.1,-0.6,-0.2)
			obj:Apply()
			ENTITY.RegisterChild(self._Entity,obj._Entity,true,MDL.GetJointIndex(self._Entity, l.joint))
			self._bindedLight = obj
		end
	end
	l = self.s_SubClass.BillBoard
	if l then
		local obj = CloneTemplate(l.template)
		obj.Pos:Set(1.1,-0.6,-0.2)
		obj:Apply()
		ENTITY.RegisterChild(self._Entity,obj._Entity,true,MDL.GetJointIndex(self._Entity, l.joint))
		self._bindedBill = obj
	end

end

function EvilMonkV3:Flame2()
	if not self._Flame2 then
		self._Flame2 = self:BindFX(self.flame_FX,0.3,"axeL",1.1,-0.6,-0.2)	--1.05,-0.6,0.0)
	end
end

function EvilMonkV3:CustomUpdate()
	if self.flame_FX and self._flameFX and self.Animation ~= "atak1" then
		self:FlameEnd()
		--Game:Print("flame end, bo end anim")
	end
end

function EvilMonkV3:IgniteBomb()
	if self._objTakenToThrow then
		self._objTakenToThrow._snd  = self._objTakenToThrow:BindSound("actor/evilmonkv3/fuse_burning-loop",5,26,true)
        self._objTakenToThrow:BindFX("EM_lont", 0.1)
	end
end

function EvilMonkV3:CheckDamageFromFlame()
	local idx  = MDL.GetJointIndex(self._Entity,"axeL")
	local idx2  = MDL.GetJointIndex(self._Entity,"k_szyja")
	local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx2, 0.0,0.0,0.0)
	local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx, 0.8,-0.8,0.0)
	
	local v = Vector:New(x3 - x2, 0, z3 - z2)
	v:Normalize()
	v:MulByFloat(self.AiParams.flameDamageRange)
	
	if debugMarek then
		self.d1 = x3
		self.d2 = y2
		self.d3 = z3
		self.d4 = x3+v.X
		self.d5 = y2
		self.d6 = z3+v.Z
	end
	local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x3,y2,z3, x3+v.X,y2,z3+v.Z)

	if e then
		--Game:Print("flame col")
		local obj = EntityToObject[e]
		if obj then
			if obj.Ignite then
				obj:Ignite()
			else
				if obj.OnDamage then
					--if debugMarek then Game:Print("flame col with "..obj._Name) end
					obj:OnDamage(self.flameDamage, self)
					if obj._Class == "CPlayer" then
						self._AIBrain._lastHitTime = self._AIBrain._currentTime
					end
				end
			end
		end
	end

end

function EvilMonkV3:Flame()
	if not self._flameFX then
		local idx  = MDL.GetJointIndex(self._Entity,"axeL")
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 0.6,-0.6,0.0)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx, 0.7,-0.8,0.0)
		local v2 = Vector:New(x3 - x2, y3 - y2, z3 - z2)
		v2:Normalize()
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)

		--[[if debugMarek then
			self.yaadebug1 = x2
			self.yaadebug2 = y2
			self.yaadebug3 = z2
			self.yaadebug4 = x3
			self.yaadebug5 = y3
			self.yaadebug6 = z3
		end--]]

		self._flameFX = AddPFX(self.flamerFX, 0.4, Vector:New(x2,y2,z2), q)
		if self._flameProc then
			Game.freezeUpdate = true
			if debugMarek then Game:Print("self._flameProc juz istnieje") end
		end
		self._flameProc = true
		--self:PlaySound({"evil_blowfire-start"})
		SOUND3D.Play(self._soundSample)
		SOUND3D.SetVolume(self._soundSample, 100.0, 0.3)
		SOUND3D.SetPosition(self._soundSample,self._groundx,self._groundy,self._groundz)
		if self._Flame2 then
			PARTICLE.Die(self._Flame2)
			self._Flame2 = nil
		end
		
		--ENTITY.RegisterChild(self._Entity,self._flameFX)
		--Game:Print("flame start")
	else
		if debugMarek then Game:Print("flame started???") end
	end
end

function EvilMonkV3:FlameEnd()
	--Game:Print("flame end")
	if self._flameFX then
		--ENTITY.Release(self._flameFX)
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
		SOUND3D.SetVolume(self._soundSample, 0.0)
		SOUND3D.Stop(self._soundSample)
		self:PlaySound({"evil_blowfire-stop"})
	end

	self._flameProc = nil

	if not self._Flame2 and self.flame_FX then
		self:Flame2()
	end
end

--[[function EvilMonkV3:CustomUpdate()
	if self.flame_FX and self._flameFX and self.Animation ~= "atak1" then
		self:FlameEnd()
	end
end
--]]

function EvilMonkV3:CustomDelete()
	if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
	Game._numberOfDynLigths = Game._numberOfDynLigths - 1
end


function EvilMonkV3:CustomOnDeath()
    if self._flameFX then
		PARTICLE.Die(self._flameFX)
		self._flameFX = nil
	end
	self._flameProc = nil

	--if self._Flame2 then
	--	PARTICLE.Die(self._Flame2)
	--	self._Flame2 = nil
	--end
	
	self:Flame2()
	
	--self:PlaySound({"$/actor/maso/maso-weapon-explode"})
	if self._soundSample then
		SOUND3D.Delete(self._soundSample)
		self._soundSample = nil
	end
end

function EvilMonkV3:CustomOnRagdollCollision(x,y,z,nx,ny,nz,j)
	if j == 21 then			-- gaszenie pochodni
		if self._bindedLight then
			--ENTITY.UnregisterAllChildren(self._Entity)		-- dodac typ
			GObjects:ToKill(self._bindedLight)
			self._bindedLight = nil
			local q = Quaternion:New_FromNormal(nx,ny,nz)
			AddPFX("torch_hitground", 0.2, Vector:New(x,y,z),q)
		end
		if self._bindedBill then
			--ENTITY.UnregisterAllChildren(self._Entity)
			GObjects:ToKill(self._bindedBill)
			self._bindedBill = nil
		end
		if self._Flame2 then
			PARTICLE.Die(self._Flame2)
			self._Flame2 = nil
		end

	end
end

function EvilMonkV3:OnTick()
	if self._flameFX and self._flameProc then
		local idx  = MDL.GetJointIndex(self._Entity,"axeL")
		local idx2  = MDL.GetJointIndex(self._Entity,"k_szyja")

		--Game:Print("PBindPFXToJoint:itck "..idx)
		local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx2, 0.0,0.0,0.0)
		local x3,y3,z3 = MDL.TransformPointByJoint(self._Entity, idx, 0.8,-0.8,0.0)
		local v2 = Vector:New(x3 - x2, 0, z3 - z2)
		v2:Normalize()
		
		local q = Clone(Quaternion)
		q:FromNormalX(v2.X, v2.Y, v2.Z)
		q:ToEntity(self._flameFX)
		ENTITY.SetPosition(self._flameFX,x3,y2,z3) 
	end

	if self._bindedLight then
		local l = Templates[self.s_SubClass.Light.template]
		local rnd = FRand(0.85, 1.0)
		local i = l.Intensity
		LIGHT.SetIntensity(self._bindedLight._Entity, i * rnd)
		local f = l.StartFalloff * rnd
		local radius = l.Range * rnd
		LIGHT.SetFalloff(self._bindedLight._Entity,f,radius)
	end

end
