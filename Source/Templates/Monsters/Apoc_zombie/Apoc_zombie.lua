function o:CustomUpdate()
	if self._AIBrain.r_closestEnemy then
		if self._changeAnimIn > 6 then
			self._changeAnimIn = FRand(4.0, 6.0)
		end
	end
	
	if self._lastTimeChangeAnim + self._changeAnimIn < self._AIBrain._currentTime and not self._isWalking and not self._notIsWalkingTimer then
		self._changeAnimIn = FRand(15.0, 25.0)	-- sec.
		self._lastTimeChangeAnim = self._AIBrain._currentTime
		--Game:Print("*losowanie")
	    
        if self._AIBrain.r_closestEnemy then
            if FRand(0.0, 1.0) < self.AiParams.runChance then
                self._forceWalkAnim = "run"
                --Game:Print("*losowanie run")
                return
            else
				if math.random(100) < 50 then
					if self._forceWalkAnim == "run" or math.random(100) < 50 then
						self._animMode = math.random(1,6)
					end
					self._forceWalkAnim = self.s_SubClass.walkList[self._animMode]
				end
				return
            end
        end
        self._animMode = math.random(1,6)
		self._forceWalkAnim = self.s_SubClass.walkList[self._animMode]
	end
end



