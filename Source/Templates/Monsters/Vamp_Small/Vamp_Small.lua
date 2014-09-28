function Vamp_Small:OnInitTemplate()
    self:SetAIBrain()
end

function Vamp_Small:CustomOnDeath()
	if self.enableTransformHP and self.enableTransformHP <= self.Health then
		if self._AIBrain._onFloor then
			self:PlaySound("morph")
			self:SetAnim(self.s_SubClass.Ambients[1], nil, nil, 0)
			self.throwHeart = false
			ENTITY.PO_Enable(self._Entity, false)

			local obj = GObjects:Add(TempObjName(),CloneTemplate("Vamp_Big.CActor"))
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
			GObjects:ToKill(self)
		end		
	end
end


function Vamp_Small:GetThrowItemRotation()
	local q = Quaternion:New()
	q:FromEuler( 0, -self.angle+math.pi/2, math.pi/2)			-- -self.angle - math.pi/2
	return q
end


--[[
function Vamp_Small:Throw(par3, par4)
	if self._AIBrain and self._AIBrain._enemyLastSeenTime > 0 then

		local obj = GObjects:Add(TempObjName(),CloneTemplate("Dagger.CItem"))

		self.Joint = MDL.GetJointIndex(self._Entity, par3)
	    local x,y,z = MDL.TransformPointByJoint(self._Entity,self.Joint,0,0,0)

		obj.ObjOwner = self

		obj.Pos.X = x
		obj.Pos.Y = y
		obj.Pos.Z = z

        obj.PosDest = {}
        obj.PosDest.X = v.X + x
        obj.PosDest.Z = v.Z + z
		obj.PosDest.Y = Player._groundy + FRand(1.7, 1.9)
		--Game.freezeUpdate = true
		obj.Rot:FromEuler(0, -self.angle, 0)
		obj:Apply()
		ENTITY.SetAngularVelocity(obj._Entity, 12, 0, 0) 
		obj:Synchronize()
	end
end

--]]