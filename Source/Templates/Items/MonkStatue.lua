o.OnInitTemplate = CItem.StdOnInitTemplate

function MonkStatue:OnCreateEntity()
	self:PO_Create(BodyTypes.FromMesh)
end

function MonkStatue:CustomOnDeath()
	if self._pffx then
		PARTICLE.Die(self._pffx)
		self._pffx = nil
	end
end


--[[function MonkStatue:Render()
	if not self.Immortal and self.Health > 0 then
		local x,y,z = 0,self.Pos.Y + 5 + FRand(-0.2, 0.2),0
		if Alastor_001 then
			x,y,z = Alastor_001:GetJointPos("k_zebra")
			y = y + FRand(-0.2, 0.2)
		end
		R3D.DrawSprite1DOF(x,y,z,self.Pos.X,self.Pos.Y + 5,self.Pos.Z,0.8,R3D.RGB(255,255,255),"particles/trailpainkiller") 
	end
end
--]]