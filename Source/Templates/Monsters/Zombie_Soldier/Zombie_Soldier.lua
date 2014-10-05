function Zombie_Soldier:OnInitTemplate()
    self:SetAIBrain()
end

function Zombie_Soldier:OnPrecache()
    Cache:PrecacheParticleFX("monsterweap_hitground")
end

function Zombie_Soldier:IfMissedPlaySound()
	local brain = self._AIBrain
	if brain then
		if brain._lastHitTime < brain._lastMissedTime then
			self:PlaySound("missed")
			if self.s_SubClass.hitGroundJoint then
				local x,y,z = self:GetJointPos(self.s_SubClass.hitGroundJoint)
				--[[DEBUGcx = x
				DEBUGcy = y + 0.3
				DEBUGcz = z
				DEBUGfx = x
				DEBUGfy = y - 0.8
				DEBUGfz = z--]]
				local b,d,x1,y1,z1 = WORLD.LineTraceFixedGeom(x,y+0.2,z,x,y-0.8,z)
				if b then
					local q = Quaternion:New_FromNormal(nx,ny,nz)
					AddPFX("monsterweap_hitground",0.2, Vector:New(x1,y1,z1),q)
				end
			end
		end
	end
end

function Zombie_Soldier:CustomOnDeath()
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end

function o:CustomUpdateHeadless()
	if self._headLess then
		if self._headLess == 1 then
			if not self._isAnimating or self._CurAnimTime > self.AiParams.afterBeheadIdleTime then
				self:SetAnim("dead", false)
				self._headLess = 2
				self._proc:Start()
			end
		end
		if self._headLess == 2 then
			if not self._isAnimating or self._CurAnimTime > self.AiParams.spinAnimTime then
				self:OnDamage(self.Health + 2, self)
				self._headLess = 3
			else
				if self.Animation == "dead" and self._CurAnimTime > self.AiParams.timeWhenSpinCasusesDamage then
					if math.random(100) < 15 and self._proc then
						self._proc:SetDir(Vector:New(Player._groundx - self._groundx, 0, Player._groundz - self._groundz))
					end
					local idx  = MDL.GetJointIndex(self._Entity,"miecz")	
					local x,y,z = MDL.TransformPointByJoint(self._Entity, idx, 0.3,0.0,0.0)
					local x2,y2,z2 = MDL.TransformPointByJoint(self._Entity, idx, 2.2,0.0,0.0)

					local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTrace(x,y,z, x2,y2,z2)

					if debugMarek then
						self.yaadebug1 = x
						self.yaadebug2 = y
						self.yaadebug3 = z
						self.yaadebug4 = x2
						self.yaadebug5 = y2
						self.yaadebug6 = z2
					end
					
					if e then
						local obj = EntityToObject[e]
						if obj == self then
						else
							if obj and obj.OnDamage then
								obj:OnDamage(self.AiParams.weaponDamage, self)
							end
						end
					end
				end
			end
		end
	end
end


function o:CustomUpdateZombie2()
	if self._headLess == 1 then
		if not self._isAnimating or self._CurAnimTime > self.AiParams.afterBeheadIdleTime then
			self:WalkTo(Player._groundx,Player._groundy,Player._groundz, false, nil, "dead")
			self._headLess = 2
			self._startTime = Game.currentTime
		end
	end
	if self._headLess == 2 then
		if self._startTime + self.AiParams.berserkTime < Game.currentTime then
			self:OnDamage(self.Health + 2, self)
			self._headLess = 3
		else
			if math.random(100) < 15 then
				self:WalkTo(Player._groundx,Player._groundy,Player._groundz, false, nil, "dead")
			end
			if not self._isWalking then
				self:WalkForward(FRand(3,5), false, nil, nil, "dead")
			end
		end
	end
end
