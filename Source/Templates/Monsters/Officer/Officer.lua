function Officer:OnInitTemplate()
    self:SetAIBrain()
    self._AIBrain._lastTimeRaid = FRand(-4,0)
end

--[[
function Officer:OnApply()
	
end

function Officer:OnTick()
	if not self._a then
		self._x = -0.8
		self._y = 0.4
		self._z = 0.1
	end

	local _do = false	
	local a = 0.1
	if INP.Key(Keys.RightShift) == 2 then
		a = -0.1
	end
	
	if INP.Key(Keys.K6) == 1 then
		self._x = self._x + a
		_do = true
    end
	if INP.Key(Keys.K7) == 1 then
		self._y = self._y + a
		_do = true
    end
	if INP.Key(Keys.K8) == 1 then
		self._z = self._z + a
		_do = true
    end

	if _do or not self._a then
		ENTITY.Release(self._a)
		self._a = self:BindFX("pochodnia",0.1,"gun",self._x, self._y, self._z)
		Game:Print(self._x.." "..self._y.." "..self._z)
	end
end
--]]
--[[
function Deto:CustomOnDamage(he,x,y,z,obj, damage, type)
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


function o:OnThrow(x,y,z)
	--local q = Quaternion:New()
    --Game:Print("yaw "..(yaw*180/math.pi).." pitch "..(pitch*180/math.pi))
    local v = Vector:New(x,y,z)
    v:Normalize()
	local q = Quaternion:New_FromNormalX(v.X, v.Y, v.Z)
	--Game:Print(v.X.." "..v.Y.." "..v.Z)
	--Game:Print(q.X.." "..q.Y.." "..q.Z)
    q:ToEntity(self._objTakenToThrow._Entity)
end
--]]

function o:ThrowFlare()
	local aiParams = self.AiParams
	local idx  = MDL.GetJointIndex(self._Entity,aiParams.throwItemBindTo)

	local x,y,z = MDL.TransformPointByJoint(self._Entity, idx, aiParams.throwItemBindToOffset.X,aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z)
	local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
	obj.ObjOwner = self
	obj._joint = idx
	obj.Pos.X = x
	obj.Pos.Y = y
	obj._raid = y
	obj.Pos.Z = z
	obj:Apply()
	obj:Synchronize()
	
	local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
	v:Normalize()
	
	local x1,y1,z1 = x,y,z
	local x2,y2,z2 = x1 + v.X, y1 + v.Y, z1 + v.Z
	v = Vector:New(x2 - x1, y2 - y1, z2 - z1)
	v:Normalize()
	v.Y = 10
	v:MulByFloat(aiParams.flareVelUP)
	ENTITY.SetVelocity(obj._Entity,v.X,v.Y,v.Z)
end


o._CustomAiStates = {}
o._CustomAiStates.callRaid = {
	name = "callRaid",
}


function o._CustomAiStates.callRaid:OnInit(brain)
	local actor = brain._Objactor
	-- tutaj trace do gory nad graczem?
	--if b then
	--	return
	--end
	actor:Stop()
	self.active = true
	actor._disableHits = true
	actor:SetAnim("raca", false)
end

function o._CustomAiStates.callRaid:OnUpdate(brain)
	local actor = brain._Objactor
	if actor.Animation ~= "raca" or not actor._isAnimating then
		self.active = false
		brain._lastTimeRaid = brain._currentTime + FRand(0,actor.AiParams.timeBetweenRaids*0.3)
	end
end

function o._CustomAiStates.callRaid:OnRelease(brain)
	local actor = brain._Objactor
	actor._disableHits = false
end

function o._CustomAiStates.callRaid:Evaluate(brain)
	if self.active then
		return 0.65
	end
	local actor = brain._Objactor
	if brain.r_closestEnemy and not actor._state ~= "ATTACKING" then
		if brain._lastTimeRaid + actor.AiParams.timeBetweenRaids < brain._currentTime then
			if brain._distToNearestEnemy > actor.AiParams.minDistToPlayerRaid then
				--Game:Print((brain._lastTimeRaid + actor.AiParams.timeBetweenRaids).." !!!! "..brain._currentTime)
			    return 0.7
			end
        end
	end
	return 0
end

