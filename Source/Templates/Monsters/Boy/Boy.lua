function o:OnPrecache()
	Cache:PrecacheParticleFX(self.transformIntoBigVampFX)
	Cache:PrecacheActor("BreakBoyTranfsormed.CActor")
end

function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:CustomOnDeath()
	if self.enableTransformHP and self.enableTransformHP <= self.Health then
		if self._AIBrain._onFloor then
			self:PlaySound("transform")
			self:SetAnim("idle", nil, nil, 0)
			self.throwHeart = false
			ENTITY.PO_Enable(self._Entity, false)

			local obj = GObjects:Add(TempObjName(),CloneTemplate("BreakBoyTranfsormed.CActor"))
			obj.Pos.X = self.Pos.X
			obj.Pos.Y = self.Pos.Y
			obj.Pos.Z = self.Pos.Z
			obj.angle = self.angle
			obj._angleDest = self._angleDest
			obj:Apply()
			obj:Synchronize()

			local tdj = obj.s_SubClass.DeathJoints
			if tdj then
				local size = obj._SphereSize * 0.4
				for i=1,table.getn(tdj) do
					--local x,y,z = obj:GetJointPos(tdj[i])
					--AddPFX(self.transformIntoBigVampFX, size ,Vector:New(x,y,z))
					obj:BindFX(self.transformIntoBigVampFX, size, tdj[i])
				end
			end
			Game.BodyCountTotal = Game.BodyCountTotal - 1
			
			if self.s_SubClass.GibEmitters then
				for i,v in self.s_SubClass.GibEmitters do
					local gibFX = v[2]
					self:BindFX(gibFX,0.3,v[1], nil,nil,nil, v[3])
				end
			end
			
			GObjects:ToKill(self)
			
			--Game:Print("transform")

		end		
	end
end

