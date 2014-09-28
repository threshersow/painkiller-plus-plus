function Samurai:OnInitTemplate()
    self:SetAIBrain()
end

function Samurai:OnCreateEntity()
    self._AIBrain._lastThrowTime = FRand(-3, 3)
end


function Samurai:BindTrailSword2(name, joint1, joint2, joint3)
	if self._trailSword2 then
		Game:Print(self._Name.."  bylu JUZ TRAIL")
		ENTITY.Release(self._trailSword2)
	end
	self._trailSword2 = self:BindTrail(name, joint1, joint2, joint3)
end

function Samurai:EndTrailSword2()
	if self._trailSword2 then
		ENTITY.Release(self._trailSword2)
		self._trailSword2 = nil
	end
end
