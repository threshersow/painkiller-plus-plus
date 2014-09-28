function Beast:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastRollTime = FRand(-3,0)
end


function Beast:CustomOnDeath()
    if self._rollPFX then
		PARTICLE.Die(self._rollPFX)
		self._rollPFX = nil
    end

    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end



function Beast:RotateTo(ang, disableRotWithAnim)
	if self._isWalking or disableRotWithAnim or not self:RotateToWithAnim(ang) then
		if not self._rotatingWithAnim then
			self._angleDest = math.mod(ang * math.pi/180, math.pi*2)
			self._isRotating = true
		end
	end
end

function Beast:Rotate(ang, disableRotWithAnim)
--	    Game:Print(GetCallStackInfo(2))
	if self._isWalking or disableRotWithAnim or not self:RotateWithAnim(ang) then
		if not self._rotatingWithAnim then
			self._angleDest = math.mod(self.angle + ang * math.pi/180, math.pi*2)
			self._isRotating = true
		end
	end
end

function Beast:RotateToVector(tx,ty,tz, disableRotWithAnim)
    if debugMarek then
        if Dist3D(tx,0,tz,self._groundx,0,self._groundz) < 0.01 then
            self._isRotating = true
            return
        end
    end

    if self._isWalking or disableRotWithAnim or not self:RotateToVectorWithAnim(tx,ty,tz) then
		if not self._rotatingWithAnim then
			self._angleDest = math.atan2(tx - self._groundx, tz - self._groundz)
			self._isRotating = true
		end
    end
end


--[[function Beast:RotateWithWalk()
	local angDest = AngDist(self.angle, self._angleDest)
	local angDest2 = AngDist(self.angle, self._angleDest + math.pi)
	if debugMarek then Game:Print("ROTATE "..(angDest*180/math.pi)) end
	--Game.freezeUpdate = true
    self._canMoveBackward = false
	if math.abs(angDest2) < math.abs(angDest) then
		--self._moveBackward = true
	end
	self._walkWithAngle = true
	-- pozniej z wyl. uzycia WP
	self.doNotUseWP = true
	if self._moveBackward then
		self:WalkForward(-3.0, false,nil,nil,nil,nil,true)
	else
		self:WalkForward(3.0, false,nil,nil,nil,nil,true)
	end
	self.doNotUseWP = false
end--]]






----------------------
Beast._CustomAiStates = {}

Beast._CustomAiStates.beastRoll = {
	name = "beastRoll",
}

function Beast._CustomAiStates.beastRoll:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor:Stop()

	self._throwed = true
	self.active = true
	self.mode = 0
	self.damaged = false
	actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, true)
	actor:SetAnim(aiParams.rollAnimPrepare, false)
	if debugMarek then
		Game:Print("start prepare roll")
	end
end

function Beast._CustomAiStates.beastRoll:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if self.mode == 0 then
		if not actor._isAnimating or actor.Animation ~= aiParams.rollAnimPrepare then
			actor._disableHits = true
			-- tu trace, czy nie trafi w sciane
			actor:SetAnim(aiParams.rollAnim, true)
			
			actor._moveSnd = actor:BindSound(actor._SoundDirectory.."beast-roll-loop", 10, 50, true)
			actor._rollPFX = actor:BindFX("turlanie")
			self._moveSndPtr = SND.GetSound3DPtr(self._moveSnd)
			SOUND3D.SetVolume(self._moveSndPtr, 0, 0)
			SOUND3D.SetVolume(self._moveSndPtr, 100, 0.1)
			
			actor._moveWithAnimation = true
			self.mode = 1
			
			actor._proc = Templates["PMove.CProcess"]:New(actor, aiParams.rollSpeed * 3.0)
			-- mam skakac przed siebie... a nie w strone wroga
			actor:RotateToVector(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z, true)
			actor._proc:SetDir(Vector:New(brain._enemyLastSeenPoint.X - actor._groundx, 0, brain._enemyLastSeenPoint.Z - actor._groundz))
			self._oldPos = Clone(actor.Pos)
			self._distToGet = Dist2D(self._oldPos.X, self._oldPos.Z, brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Z) + 4.0
			if self._distToGet < 8 then
				self._distToGet	= 8
			end
			GObjects:Add(TempObjName(), actor._proc)
			actor.state = "ROLL"
			self.dist = 0
			self.lastPosX = actor._groundx
			self.lastPosZ = actor._groundz

		end
	else
		self.dist = self.dist + Dist2D(actor._groundx, actor._groundz, self.lastPosX, self.lastPosZ)
		self.lastPosX = actor._groundx
		self.lastPosZ = actor._groundz
		--local dist = Dist3D(self._oldPos.X, self._oldPos.Y, self._oldPos.Z, actor._groundx, actor._groundy, actor._groundz)
		if self.dist > self._distToGet then
			if debugMarek then Game:Print("zaieg pokonany") end
			actor._animLoop = false
		end
		if not actor._isAnimating or actor.Animation ~= aiParams.rollAnim then
			self.active = false
			if debugMarek then Game:Print("koniec "..actor.Animation) end
			--[[if actor._proc then
				GObjects:ToKill(actor._proc)
				actor._proc = nil
			end--]]
		else
			if brain.r_closestEnemy and brain._distToNearestEnemy < 2.0 and not self.damaged then
				--actor:SetIdle()
				actor._animLoop = false
				if debugMarek then Game:Print("bang") end
				self.damaged = true
				brain.r_closestEnemy:OnDamage(aiParams.rollDamage)
				PlaySound2D("actor/beast/beast_roll-hit")
				return
			end
			actor:RotateToVector(Player._groundx, Player._groundy, Player._groundz, true)
			actor._proc:SetDir(Vector:New(Player._groundx - actor._groundx, 0, Player._groundz - actor._groundz))
		end
	end
	brain._lastRollTime = brain._currentTime
end

function Beast._CustomAiStates.beastRoll:OnRelease(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	actor._moveWithAnimation = nil
	brain._lastRollTime = brain._lastRollTime + FRand(0,1)
	self.active = false
    actor._disableHits = nil
    if actor._rollPFX then
		PARTICLE.Die(actor._rollPFX)
		actor._rollPFX = nil
    end

    if actor._moveSnd then
        if debugMarek then Game:Print("snd roll release") end
		SOUND3D.SetVolume(self._moveSndPtr, 0, 0.3)
		ENTITY.SetTimeToDie(actor._moveSnd, 0.3)
		actor._moveSnd = nil
	end
    if actor._proc then
		GObjects:ToKill(actor._proc)
		actor._proc = nil
	end
end

function Beast._CustomAiStates.beastRoll:Evaluate(brain)
	if self.active then
		return 0.69
	else
        if brain.r_closestEnemy then
		    local actor = brain._Objactor
			local aiParams = actor.AiParams
            if brain._lastRollTime + aiParams.minDelayBetweenRoll < brain._currentTime and not actor._rotatingWithAnim then
				if brain._distToNearestEnemy < aiParams.rollRangeMax and brain._distToNearestEnemy > aiParams.rollRangeMin then
					--if math.random(100) < (8 - brain.r_closestEnemy._velocity) * 5 then
					--Game:Print("roll "..brain._distToNearestEnemy)
					return 0.54
					--end
				end
			end
		end
	end
	return 0
end

