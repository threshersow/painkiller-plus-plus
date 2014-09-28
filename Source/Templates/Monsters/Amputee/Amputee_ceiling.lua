function Amputee_ceiling:OnInitTemplate()
    self:SetAIBrain()
end


function Amputee_ceiling:OnCreateEntity()
--	ENTITY.PO_SetGravity(self._Entity, 0,50,0)

end


function Amputee_ceiling:CustomUpdate()
	if self._DontCheckFloors then
		local dist = Dist3D(self._groundx, self._groundy, self._groundz, Player._groundx,Player._groundy,Player._groundz)
		if dist < 6 then		-- pozniej trace, zeby nie wykrywal pietro nizej
			local dist2 = Dist3D(self._groundx, 0, self._groundz, Player._groundx,0,Player._groundz)
			if dist2 < 2 then
				--[[Game:Print(self._Name.." dist to player < 2")
				self.CreatePO = true
				self._DontCheckFloors = false
				self.Animation = "idle_kolana"
				self.s_SubClass = Clone(Templates["Amputee.CActor"].s_SubClass)
				self._AIBrain._goals = {}
				self.AiParams.aiGoals = {"amputeeIdle", "amputeeAttack",}
				self._AIBrain._lastTimeAttack = 0
				self:Apply()--]]
				self:OnDamage(self.Health + 2, self)
				
				--[[if math.random(100) < 50 then
					local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(self._groundx, self._groundy, self._groundz, self._groundx, self._groundy - 15.0, self._groundz)
					if d and e then
						local obj = EntityToObject[e]
						if obj then
							Game:Print(self._Name.." obj podemna "..obj._Name)
						end
					end
				end--]]
			end
		end
	end
end
