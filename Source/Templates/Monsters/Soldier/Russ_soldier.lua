function o:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastThrowTime = FRand(-1,1)

--[[	self._x = -1
	self._y = -0.8
	self._z = 0.5--]]
end


--[[function o:OnTick()
	local plus = 0.1
	local update = false
	if INP.Key(Keys.RightShift) == 2 then
		plus = -0.1
	end
	if INP.Key(Keys.K6) == 1 then
		update = true
		self._x = self._x + plus
	end
	if INP.Key(Keys.K7) == 1 then
		update = true
		self._y = self._y + plus
	end
	if INP.Key(Keys.K8) == 1 then
		update = true	
		self._z = self._z + plus
	end

	if update or not self._pfx then
		ENTITY.Release(self._pfx)
		self._pfx = self:BindFX("pochodnia",0.1,self.AiParams.weaponBindPos,self._x,self._y,self._z)
	end
	
	Game:Print(self._x.." "..self._y.." "..self._z)
end
--]]