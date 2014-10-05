function Spider:OnInitTemplate()
	self:SetAIBrain()
	self._todeathTimer = self.AiParams.timeToLive + math.random(0,30)
end


function Spider:CustomUpdate()
	if not ENTITY.PO_Exist(self._Entity) then
		return
	end
	if self._todeathTimer then
		self._todeathTimer = self._todeathTimer - 1
		if self._todeathTimer < 0 then
			self:OnDamage(self.Health + 2, self)
			self._todeathTimer = nil
		end
	end

	if math.random(1000) < 24 then
        if self._AIBrain then
            local enemy = self._AIBrain.r_closestEnemy
            if enemy then
                self:Stop()
                self:RotateToVector(enemy._groundx,enemy._groundy,enemy._groundz)
            end
        end
    end

end



function Spider:SetIdle()
--    if debugMarek then Game:Print(self._Name.." spider wants idle") end
end


