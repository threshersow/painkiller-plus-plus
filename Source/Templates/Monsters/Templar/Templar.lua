function Templar:OnInitTemplate()
    self:SetAIBrain()
    --self._AIBrain._lastSliceTime = 0
end


function Templar:CustomOnDamage(he,x,y,z,obj, damage, type)
    if type == AttackTypes.Demon then
        return false
    end

    if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        local jName = MDL.GetJointName(e,j)
        if jName == "shield" then
            if type == AttackTypes.Shotgun or type == AttackTypes.MiniGun or type == AttackTypes.Painkiller then
				self:PlaySound({"$/actor/maso/maso_hit_impact1","$/actor/maso/maso_hit_impact2"},22,52)
            end
			return true
		end
	else
		if type == AttackTypes.Physics then
			return false
		end
		if x and type == AttackTypes.Rocket then
			local x1,y1,z1 = self:GetJointPos("root")
			local dist = Dist3D(x,y,z,x1,y1,z1)
			Game:Print("odleglosc wybuchu od jointa : "..dist.." "..damage)
			if dist < 1.5 then
				damage = damage * (15/10 - dist)*10/15
				return false, damage
			end
		end
	end
	return false
end

--[[function Templar:GetThrowItemRotation()
	local q = Quaternion:New()
	q:FromEuler( 0, -self.angle, 0)
	return q
end--]]

function Templar:OnThrow(x,y,z)
	--local q = Quaternion:New()
    --Game:Print("yaw "..(yaw*180/math.pi).." pitch "..(pitch*180/math.pi))
    local v = Vector:New(x,y,z)
    v:Normalize()
	local q = Quaternion:New_FromNormalX(v.X, v.Y, v.Z)
	--Game:Print(v.X.." "..v.Y.." "..v.Z)
	--Game:Print(q.X.." "..q.Y.." "..q.Z)
    q:ToEntity(self._objTakenToThrow._Entity)
end
