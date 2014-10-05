function o:OnInitTemplate()
    self:SetAIBrain()
	--[[for i,v in self.AiParams.FarAttacks do
		if v == "shot2guns" then
			self._AIBrain._weaponL = true
			self._AIBrain._weaponR = true
		end
		if v == "shotrgun" or v == "shotrgunllost" then
			self._AIBrain._weaponR = true
		end
		if v == "shotlgun" then
			self._AIBrain._weaponL = true
		end
	end--]]
end

function o:OnCreateEntity()
	local brain = self._AIBrain
    --if self.AiParams.FarAttacks[1] ==  "shotrgunllost" then
    --    MDL.SetMeshVisibility(self._Entity,"polySurfaceShape2", false)
    --end
    brain._lastThrowTime = brain._currentTime + FRand(-2,1)
end

function o:WeaponFireL(par3, par4, par5)
	--if self._AIBrain._weaponL then
		self._AIBrain._useSecondWeapon = true			-- narazie
		self._AIBrain:WeaponFire(par3, par4, par5)
		self._AIBrain._useSecondWeapon = false
	--end
end

function o:WeaponFireR(par3, par4, par5)
	--if self._AIBrain._weaponR then
		self._AIBrain:WeaponFire(par3, par4, par5)
	--end
end

--[[
function o:CustomOnHit()
	local brain = self._AIBrain
	if self._HealthMax * self.ABhp > self.Health and not brain._ABdone then
		-- ktora bron ma mu odpadac i czy moze w trakcie ataku?
		--Game:Print(self._Name.. "AB <-- traci lewy gun")
		local x,y,z = self:GetJointPos("joint22")
		AddItem("gunn.CItem",nil, Vector:New(x,y,z),true)
		brain._weaponL = false
		self.AiParams.FarAttacks = {"shotrgunllost"}
		self.AiParams.afterJumpAnim = {"shotrgunllost"}
		self.AiParams.strafe = nil
		MDL.SetMeshVisibility(self._Entity,"polySurfaceShape2", false)		-- narazie
		self:PlaySound({"sado_death1","sado_death2","sado_death3","sado_death4"})
		brain._ABdone = true
		
		if self.AiParams.canThrowApple then
			brain._lastThrowTime = brain._currentTime
			table.insert(brain._goals, Clone(AiStates.throw))
		end
		--if self._state == "ATTACKING" then			-- pozniej beda hit-y
		--	self:SetIdle()			--?
		--end
	end
end
--]]
