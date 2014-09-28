function Banshee:OnInitTemplate()
    self:SetAIBrain()
end



function Banshee:CustomOnDeath()
	if self._lastAttackAmbient then
		SOUND3D.Delete(self._lastAttackAmbient)
		self._lastAttackAmbient = nil
	end
	if Game._procBanshee then
		Game._procBanshee._killme = true
		Game._procBanshee = nil
	end
end

Banshee.CustomDelete = Banshee.CustomOnDeath


function Banshee:Attack()
	local br = self._AIBrain
	local aiParams = self.AiParams
	local cam = aiParams.nearAttack
	br._succesfulAttack = false
	if br and br.r_closestEnemy then
		local dist = Dist3D(self._groundx, self._groundy, self._groundz, br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz)
		local angleAttack = math.atan2(br.r_closestEnemy._groundx - self._groundx, br.r_closestEnemy._groundz - self._groundz)
		local aDist = AngDist(self.angle, angleAttack)
		
		if dist <= aiParams.attackRange and math.abs(aDist) < aiParams.attackRangeAngle*math.pi/180 then
			--[[Game._EarthQuakeProc:Add(br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz, cam.cameraShakeTime, self.StompRange, cam.cameraShake * 0.1, cam.cameraShake)
			local x,y,z = CAM.GetAng()
			br._succesfulAttack = true
			--x = math.mod(x, 360)
			--y = math.mod(y, 360)
			--z = math.mod(z, 360)
			x = x - cam.cameraMess.X * FRand(0.9, 1.1)
			y = y - cam.cameraMess.Y * FRand(0.9, 1.1)
			z = z - cam.cameraMess.Z * FRand(0.9, 1.1)
			CAM.SetAng(x,y,z)--]]
			
			self:PlayRandomSound2D("damage")
			
			if not Game._procBanshee then
				Game._procBanshee = GObjects:Add(TempObjName(),CloneTemplate("BansheeStrike.CProcess"))
				Game._procBanshee.strike = 1
			else
				Game._procBanshee.strike = 1
			end
		end	
	end
end

function Banshee:Scream()
	local aiParams = self.AiParams
	self._sndScream = self:PlaySoundAndStopLast("scream",aiParams.screamDistance,aiParams.screamDistanceMax)
end


function Banshee:CustomOnHit()
	--if Game._procBanshee and Game._procBanshee.TickCount < 0 then
	--	Game:Print("custom on hit")
	--	Game._procBanshee.TickCount = -Game._procBanshee.TickCount
	--end
	if self._sndScream then
		self:StopLastSound(self._sndScream)
		self._sndScream = nil
	end
end

--[[function Banshee:Bzzz()
	local aiParams = self.AiParams
	Player._soundSample = SOUND2D.Create(self.s_SubClass.Sounds.bzzz)
	SOUND2D.SetLoopCount(Player._soundSample, 30)
    local dist = Dist3D(Player._groundx, Player._groundy, Player._groundz, self._groundx, self._groundy, self._groundz)
	if dist < aiParams.screamDistance then
		Player._deaf = aiParams.PlayerDeafTime
		Player._deafDownTo = aiParams.lowPass
		Player._deafDeafOut = aiParams.PlayerDeafOut
		SOUND.GlobalSetLowPass(aiParams.lowPass)
		SOUND2D.SetLowPass(Player._soundSample, 1.0)			-- pozniej w zaleznosci od dlugosci 
	end
	SOUND2D.Play(Player._soundSample)
end--]]

o._CustomAiStates = {}
--------------------------
o._CustomAiStates.bansheeAttack = {
	name = "bansheeAttack",
	lastTimeCiach = -100,
	lastTimeOnAttackAmbient = 0,
}

function o._CustomAiStates.bansheeAttack:OnInit(brain)
	local actor = brain._Objactor
	self.mode = 0
end

function o._CustomAiStates.bansheeAttack:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	if actor.s_SubClass.SoundsDefinitions.attackAmbient then
		if self.lastTimeOnAttackAmbient + aiParams.soundAmbientDelay < brain._currentTime and math.random(100) < 3 then
			actor._lastAttackAmbient = actor:PlaySoundHit("attackAmbient")
			if actor._lastAttackAmbient then
				self.lastTimeOnAttackAmbient = brain._currentTime
			end
		end
	end

	
	--if brain.r_closestEnemy then
		if brain._distToNearestEnemy < aiParams.screamDistanceMax then
			if FRand(0.0, 1.0) < aiParams.screamFreq and self.mode ~= 1 and self.mode ~= 2 then
				Game:Print("scream")
				actor:Stop()
				actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
				actor:SetAnim("atak1", false)
				actor._state = "ATTACKING"			
				self.mode = 1
			end
		end
		if self.mode == 5 then
			if not actor._isWalking then
				self.mode = 0
			else
				if brain._distToNearestEnemy < aiParams.attackRange then
					actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
					self.mode = 0
				end
			end
		end
		if self.mode == 1 then
			if not actor._isAnimating then
				self.mode = 0
				actor._state = "IDLE"
				Game:Print("koniec atak1")
				
				--Game._procBanshee = nil
			else
				if math.random(100) < 45 then
					actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz)
				end
				if actor.Animation == "atak1" and actor._sndScream then
					if actor:IsPlayingLastSound(actor._sndScream) then
						local dist = Dist3D(Player._groundx, Player._groundy, Player._groundz, actor._groundx, actor._groundy, actor._groundz)
						
						if dist <= aiParams.screamDistanceMax then
							if not Game._procBanshee then
								Game._procBanshee = GObjects:Add(TempObjName(),CloneTemplate("BansheeStrike.CProcess"))
								Game._procBanshee:Add(1)
							else
								if dist < aiParams.screamDistance then
									Game._procBanshee:Add(1)
								else
									Game._procBanshee:Add(1 - (dist - aiParams.screamDistance)/(aiParams.screamDistanceMax - aiParams.screamDistance) + 0.1)
									--Game:Print("up : "..Game._procBanshee.Up)
								end
							end
						end
					end
				end
			end
		end
		if self.mode == 0 and brain.r_closestEnemy then
			if brain._distToNearestEnemy < aiParams.attackRange then
				Game:Print("banshee atak")
				--Game.freezeUpdate = true
				actor:WalkForward(2, true, 25, 3, "atak2")
				self.mode = 2
			else
				if not actor._isWalking or (actor._isWalking and math.random(100) < 15) then
					-- zeby szla troche z lewej
					local v = Vector:New(actor._groundz - brain.r_closestEnemy._groundz, 0, brain.r_closestEnemy._groundx - actor._groundx)
					v:Normalize()
					local dxx = brain.r_closestEnemy._groundx - v.X * 0.2
					local dzz = brain.r_closestEnemy._groundz - v.Z * 0.2
					
					--
					actor:WalkTo(dxx, brain.r_closestEnemy._groundy, dzz, true)
				end
			end
		end
		if self.mode == 2 then
			if not actor._isWalking then
				--GObjects:ToKill(Game._procBanshee)
				--if brain._succesfulAttack then
				--	Game:Print("banshee end atak - escape")
				--	brain.escape = math.random(70,100)
				--	self.mode = 0
				--else
					Game:Print("banshee end atak - forward")
					actor:WalkForward(math.random(4,9), true, math.random(0, 20), 10)
					self.mode = 5
					
				--end
			end
		end
	--end
end

function o._CustomAiStates.bansheeAttack:OnRelease(brain)
	local actor = brain._Objactor
	--Game:Print("BANSHEE release")
end


function o._CustomAiStates.bansheeAttack:Evaluate(brain)
	if brain.r_closestEnemy or brain._Objactor._state == "ATTACKING" then
		return 0.5
	end
	return 0.0
end
