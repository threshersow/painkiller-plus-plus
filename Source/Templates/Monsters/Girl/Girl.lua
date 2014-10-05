function o:OnInitTemplate()
    self:SetAIBrain()
end


function o:GirlBurn()
	if not self._burning then
		local p = Templates["PBurningObject.CProcess"]:New(self, 99999) 
        p:Init()
        GObjects:Add(TempObjName(),p)
        self._burnProc = p
        self.disableFreeze = true
		--Game:Print("podpalanie")
	else
		--Game:Print("juz sie jara")
	end
end

function o:CustomOnDamage(he,x,y,z,obj, damage, type)
	if type == AttackTypes.Fire then
		return true
	end
	if type == AttackTypes.FlameThrower then
		self:GirlBurn()
		return true
	end
end

o._CustomAiStates = {}


o._CustomAiStates.GirlBurn = {
	name = "GirlBurn",
	delay = 30,
}


function o._CustomAiStates.GirlBurn:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	self._mode = 0
    
    if not self._once then
        self._once = actor:PlaySoundAndStopLast("onAttackOnce", nil, nil, true)
        self._doitonce = true
    end
end

function o._CustomAiStates.GirlBurn:OnUpdate(brain)
	local actor = brain._Objactor
    local aiParams = actor.AiParams
    
    if self._doitonce then
        if actor:IsPlayingLastSound() then
            return
        else
            self._doitonce = nil
        end
    end
	
	if self._mode ~= 1 then
		if not actor._burnProc then
			if self.delay > 0 then
				if actor._burning then
					self.delay = 0
					return
				end
				self.delay = self.delay - 1
				if math.random(100) < 4 then
					if math.random(100) < 80 and not actor._isWalking then
						actor:RotateToVector(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz,true,FRand(15,20))
					else
						if not aiParams.GuardStill then
							actor:WalkTo(brain.r_closestEnemy._groundx + FRand(-6,6), brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz + FRand(-6,6),false,FRand(4,6))
						end
					end
				end
			else
				actor:Stop()
				actor:SetAnim("atak",false)
				actor._disableHits = true
				self._mode = 1
			end
			return
		else
			if brain._distToNearestEnemy < aiParams.attackRange then
				actor:Stop()
				--Game:Print("podpalanie")
				brain.r_closestEnemy:OnDamage(aiParams.weaponDamage,self,AttackTypes.AIClose)
				actor:PlayRandomSound2D("damage")

                actor.disableFreeze = nil
				GObjects:ToKill(actor._burnProc)
				actor._burnProc = nil
				self.delay = aiParams.delayBetweenAttacks * FRand(0.8,1.1)
				--Game.freezeUpdate = true
			else
				if not actor._isWalking or math.random(100) < 5 then
					actor:WalkTo(brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz,true,FRand(15,20))
				end
			end
		end
	else
		if not actor._isAnimating or actor.Animation ~= "atak" then
			actor._disableHits = false
			Game:Print("actor._girlBurning = true")
			self._mode = 0
		end
	end
end

function o._CustomAiStates.GirlBurn:OnRelease(brain)
	local actor = brain._Objactor
	actor._disableHits = false
end

function o._CustomAiStates.GirlBurn:Evaluate(brain)
	local actor = brain._Objactor
	if brain._seeEnemy then
		return 0.8
	end
	if self.delay > 0 then
		self.delay = self.delay - 1
	end
	return 0.0
end
