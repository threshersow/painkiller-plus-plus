function o:OnInitTemplate()
    self:SetAIBrain()
end

function o:OnCreateEntity()
--	self._AIBrain._lastThrowTime = FRand(-2, 2)
--	self:BindFX("pochodnia",0.1,self.AiParams.weaponBindPos,self.AiParams.weaponBindPosShift.X,self.AiParams.weaponBindPosShift.Y,self.AiParams.weaponBindPosShift.Z)
--	self:BindFX("pochodnia",0.1,self.AiParams.secondWeaponBindPos,self.AiParams.secondWeaponBindPosShift.X,self.AiParams.secondWeaponBindPosShift.Y,self.AiParams.secondWeaponBindPosShift.Z)
end

function o:CustomOnDamage(he,x,y,z,obj)
	if obj == self then
		return true
	end
end



function o:Fire()
    local brain = self._AIBrain
	local x2,y2,z2 = brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z	--Player._groundx, Player.Pos.Y, Player._groundz			-- pozniej zgodnie z obrotem
	if brain.r_closestEnemy then
		x2,y2,z2 = brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy, brain.r_closestEnemy._groundz
	end
	self._target_x = x2
	self._target_y = y2
	self._target_z = z2

	local aiParams = self.AiParams
	local gun = aiParams.weapon
	
	local idx  = MDL.GetJointIndex(self._Entity,aiParams.throwItemBindTo)
	local srcx2,srcy2,srcz2 = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
	local srcx,srcy,srcz = MDL.TransformPointByJoint(self._Entity, idx, aiParams.throwItemBindToOffset.X,aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z)
	
	--local v2 = Vector:New(srcx-srcx2,srcy-srcy2,srcz-srcz2)
	local v2 = Vector:New(srcx2-srcx,srcy2-srcy,srcz2-srcz)
	v2:Normalize()
	local q = Quaternion:New_FromNormal(v2.X, v2.Y, v2.Z)
	
	if gun.fireParticle then
		AddPFX(gun.fireParticle, gun.fireParticleSize, Vector:New(srcx,srcy,srcz), q)
	end
	
	local dist = Dist3D(x2,y2,z2,self._groundx,self._groundy,self._groundz)
	if dist < 10 then
		dist = 10
	end
	if dist > 40 then
		dist = 40
	end
	
	self:AddTimer("Xplode", dist * 0.04)
end


function o:Xplode()
	local x,y,z = self._target_x,self._target_y,self._target_z
	if z then
		-- special FX
		SOUND.Play3D("actor/maso/maso_grenade-explosion",x,y,z,12)
		AddPFX("Grenade",0.4,Vector:New(x,y,z))            

		WORLD.Explosion2(x,y,z,self.ExplosionStrength,self.ExplosionRange,self._Entity,AttackTypes.Grenade,self.ExplosionDamage)
	    
		-- physical parts
		local n = math.random(4,6) -- how many (min,max)
		local scales = {0.6, 0.8}
		for i = 1, n do
			local scale = scales[math.random(1,2)]
			local ke = AddItem("KamykWybuch.CItem",scale,Vector:New(x,y+0.5+i/10,z))
			local vx = FRand(-27,37) -- velocity x
			local vy = FRand(22,34)  -- velocity y
			local vz = FRand(-27,37) -- velocity z
			ENTITY.SetVelocity(ke,vx,vy,vz)
			ENTITY.SetTimeToDie(ke,FRand(1,2)) -- lifetime (min,max)
		end
	    
		-- light
		AddAction({{"Light:a[1],a[2],a[3],200,200,100, 8, 10 , 1, 0.02,0.1,0.02"}},nil,nil,x,y+1.5,z)
		if Game._EarthQuakeProc then
			Game._EarthQuakeProc:Add(x,y,z, 5, 18, 0.18, 0.18, false)
		end
	end
	self._targetx = nil
	self:ReleaseTimers()
end
