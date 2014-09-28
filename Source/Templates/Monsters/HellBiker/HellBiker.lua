function HellBiker:OnInitTemplate()
    self:SetAIBrain()
	self._AIBrain._lastTimeFreak = -100
end

function HellBiker:CustomOnDeath()
    if self._soundSample then
        SOUND3D.Forget(self._soundSample)
        self._soundSample = nil
    end
    if self._shootingSound then
		local e = ENTITY.GetPtrByIndex(self._shootingSound)
		if e then
			ENTITY.Release(e)	-- pozniej fadeout
		end
		self._shootingSound = nil
	end
end
-------------

function HellBiker:OnCollision(x,y,z,nx,ny,nz,e)
	if e then
		local obj = EntityToObject[e]
		if obj and obj.OnDamage then
			if self.state == 1 then
				local rnd = FRand(self.CollisionDamage*0.8, self.CollisionDamage * 1.2)
                local v = self._AIBrain._velocity
                if v > 2 then
                    v = 2
                end

				obj:OnDamage(rnd * v, self)
				if obj._Class == "CPlayer" then
					self._AIBrain._lastTimeFreak = self._AIBrain._currentTime
					PlaySound2D("actor/"..self.Model.."/".."hellb-attack-head-hit")
				end
				
				local force = self.AiParams.hitStrength	--math.random(math.random(self.AiParams.hitStrength * 0.9, self.AiParams.hitStrength * 1.1))
				local v = Vector:New(x - self.Pos.X, 0 ,z - self.Pos.Z)
				v:Normalize()
				v.Y = 0.5
				--Game:Print("col PLAYER")
				self:OnDamage(self.Health + 2, self)
				if obj._Class == "CPlayer" then
					ENTITY.PO_SetPlayerFlying(e, 0.33)
					ENTITY.SetVelocity(e, v.X*force, v.Y*force, v.Z*force)
				end
				self.ShotCamMove = 0.015 * self._AIBrain._velocity
				self.ShotCamRotate = 0.015 * self._AIBrain._velocity
				Game._EarthQuakeProc:Add(x,y,z, 4, 8, self.ShotCamMove, self.ShotCamRotate, false)
			end
		end
	end
end

function HellBiker:CustomUpdate()
	if not self._onceSpecial then
		if self._HealthMax * self.AiParams.specialAttackHP > self.Health and ENTITY.PO_IsOnFloor(self._Entity) and self.Health > 0 then
			if self._AIBrain.r_closestEnemy and not self._enabledRD and not self._hitDelay then
				if self._AIBrain.r_lastDamageWho == Player then
					self._onceSpecial = true
					ENTITY.EnableCollisions(self._Entity, true, self.EnableCollisions, nil)
					self.doNotUseWP = true
					self:RotateToVector(self._AIBrain.r_closestEnemy.Pos.X, self._AIBrain.r_closestEnemy.Pos.Y, self._AIBrain.r_closestEnemy.Pos.Z)
					self.state = -8			-- little delay
					self._AIBrain._goals = {}
					self._hitDelay = nil
					self._AIBrain._currentGoal = nil
					self:Stop()
					self._disableHits = true
					--Game:Print("SPEICAL attack "..self.Health)
					--Game.freezeUpdate = true
				end
			end
		end
	else
		if not self._enabledRD then
			if not ENTITY.PO_IsOnFloor(self._Entity) then
				--Game:Print("NOTF - die")
				self:OnDamage(self.Health + 2, Player)
				return
			end
			if self.state < 0 then
				self.state = self.state + 1
				return
			end
			if self.state == 0 and not self._isWalking and not self:IsRotating() then
				self:WalkForward(self.AiParams.special_RunDistance, true, nil, self.AiParams.special_RunDistance, "atak2")
				self.state = 1
				--Game:Print("SPEICAL attack PLAYSOUND")
				--self._soundSample = PlaySound3D("actor/"..self.Model.."/".."hellb-attack-head",self.Pos.X,self.Pos.Y,self.Pos.Z,16,24,self)
				self._soundSample = SOUND3D.Create("actor/"..self.Model.."/".."hellb-attack-head")
			    SOUND3D.SetPosition(self._soundSample,self.Pos.X,self.Pos.Y,self.Pos.Z)    
				SOUND3D.SetHearingDistance(self._soundSample,16,24)
				SOUND3D.Play(self._soundSample)

				self._disableDeathSounds = true
				self.col = nil
				self._minTimeCol = self._AIBrain._currentTime
				return
			end

			if self.state == 1 then
				if self._soundSample and not SOUND3D.IsPlaying(self._soundSample) then
                    SOUND3D.Forget(self._soundSample)
                    self._soundSample = nil
					self._disableDeathSounds = false
				end
				if self._minTimeCol + 8/30 < self._AIBrain._currentTime then
					--Game:Print("slowdown check "..self._lastCantMoveTime.." "..self._AIBrain._currentTime)
					if self._lastCantMoveTime > 0 and self._AIBrain._currentTime < self._lastCantMoveTime + 2/30 then
						--Game:Print("COLLL - slowdown")
						self:OnDamage(self.Health + 2, Player)
						return
					end
				end
				if not self._isWalking then
					--Game:Print("NO walkin - die")
					self:OnDamage(self.Health + 2, Player)
				end
			end
		end
	end
end

function HellBiker:OnStartAnim(oldAnim)
	if oldAnim == "atak1" then
		if self._startShooting then
			self:PlaySound({"hellb-weapon-shoot-end"},16,52)
			self._startShooting = false
			if self._shootingSound then
				local e = ENTITY.GetPtrByIndex(self._shootingSound)
				if e then
					ENTITY.Release(e)	-- pozniej fadeout
				end
				self._shootingSound = nil
			end
			--if debugMarek then Game:Print("przerwany strzaly, to wybrzmiewanie") end
		end
	end
end

function HellBiker:ShootingSound(start)
	if not start then
		if self._shootingSound then
			local e = ENTITY.GetPtrByIndex(self._shootingSound)		-- potrzebne?
			if e then
				ENTITY.Release(e)
			end
			self._shootingSound = nil
		end
		self:PlaySound({"hellb-weapon-shoot-end"},16,52)
	else
		local snd
		snd, self._shootingSound = self:BindRandomSound({"hellb-weapon-shoot-14times"},16,52)
	end
	self._startShooting = start
end

