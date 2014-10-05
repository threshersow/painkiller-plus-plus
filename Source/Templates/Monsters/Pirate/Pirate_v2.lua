function o:OnInitTemplate()
    self:SetAIBrain()
end


function o:BindTrailSword2(name, joint1, joint2, joint3)
	if self._trailSword2 then
		--Game:Print(self._Name.."  bylu JUZ TRAIL")
		ENTITY.Release(self._trailSword2)
	end
	self._trailSword2 = self:BindTrail(name, joint1, joint2, joint3)
end

function o:EndTrailSword2()
	if self._trailSword2 then
		ENTITY.Release(self._trailSword2)
		self._trailSword2 = nil
	end
end
