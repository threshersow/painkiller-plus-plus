function o:CustomOnDeath()
    ENTITY.PO_EnableGravity(self._Entity, true)
end

function o:OnCreateEntity()
	ENTITY.PO_EnableGravity(self._Entity, false)
end

function o:BarfDown()
	if self._canCheckDamageBarf then
		self._canCheckDamageBarf = false
	end
	if self._canBarf then
		--self._barffx = self:BindFX("barf")
		local p = self.s_SubClass.ParticlesDefinitions.barf
		local q = Quaternion:New_FromEuler(0,math.pi/2,math.pi/2)
		AddPFX(p.pfx, p.scale, Vector:New(self:GetJointPos(p.joint)),q)
		self:PlaySound("throw_up")
		self:PlaySound("throw2")
		self._canBarf = false
		self._canCheckDamageBarf = true
	end
end

function o:BarfDamageCheck()
    if self._canCheckDamageBarf then
       	local x,y,z = self:GetJointPos("k_szyja")
		local distToPlayer = Dist2D(x,z,Player._groundx,Player._groundz)
        if distToPlayer < self.AiParams.barfRange then
			--Game:Print(">barf "..self._groundy.." "..Player._groundy)
            if self._groundy > Player._groundy and Player._groundy + self.AiParams.barfRangeY > self._groundy then
                Player:OnDamage(self.AiParams.barfDamage, self)
            end
        end	
        self._canBarf = false
    end
end

o.CustomDelete = o.CustomOnDeath
------------

o._CustomAiStates = {}
o._CustomAiStates.amputeeIdleBarf = {
	name = "amputeeIdleBarf",
}

function o._CustomAiStates.amputeeIdleBarf:OnInit(brain)
	local actor = brain._Objactor
	self._lastTimeBarf = -100
end


function o._CustomAiStates.amputeeIdleBarf:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	
	local x,y,z = actor:GetJointPos("k_szyja")
	local distToPlayer = Dist2D(x,z,Player._groundx,Player._groundz)
	if distToPlayer < aiParams.barfRange and not actor._canBarf then
		if actor._groundy > Player._groundy and Player._groundy + actor.AiParams.barfRangeY > actor._groundy then
			if self._lastTimeBarf + aiParams.delayBetweetBarfs < brain._currentTime and actor.Animation == "idle_kolana" then
				self._lastTimeBarf = brain._currentTime + FRand(0,aiParams.delayBetweetBarfs*0.2)
				actor._canBarf = true
			end 
		end
	end

end

function o._CustomAiStates.amputeeIdleBarf:OnRelease(brain)
	self.active = false
end

function o._CustomAiStates.amputeeIdleBarf:Evaluate(brain)
	return 0.1
end
