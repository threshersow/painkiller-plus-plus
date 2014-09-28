
--============================================================================
-- Actor class (with model and pathfinding)
--============================================================================
CActor = 
{
	_notIsWalkingTimerAmount = 3,	-- czas po ktorym wylacza animacje chodzenia, gdy _isWalking jest flase
	CollisionDetect = 0.4,		-- jesli o tyle spadnie predkosc potwora to wykrywa kolizje
    Model = "raven",
	
    Scale = 1,
	_checkRadius = 0.2,
    AIenabled = true,
    enableAIin = nil,
    _DontCheckFloors = false,
    
    Health = 100,
	onlyWPmove = false,			-- if true, actor will walk only to WayPoints,
	walkArea = nil,
	WalkSpeed = 1.0,
	RunSpeed = 1.0,
	RotateSpeed = 10,			-- degrees per 1/30 sec,
	CreatePO = false,
	throwHeart = false,
	NeverRun = false,
	NeverWalk = false,
	NeverMove = false,
	DeathTimer = 100,
	shadow = 0,
	smoothFly = 1.0,			-- max zmiana kata w czasie (pitch), zeby za szybko nie zmienial kata latania (tylko gora/dol)
	
	_randomizedParams = {
		WalkSpeed = nil,
		FlySpeed = nil,
		RunSpeed = nil,
		RotateSpeed = nil,
	},
	
-- prive    
    _SoundDirectory = "",
    _CurAnimIndex = 0,
    _CurAnimLength = 0,
    _CurAnimTime = 0,
    _LastAnimTime = -1,
    _Path = nil,
    _Class = "CActor",


-- rotating
	angle = 0,
	_angleDest = 0,
	_distToAngle = 0,

	_angleVel = 0,
	_lastVel = 0,
	_lastAngle = 0,
--
	_rotatingWithAnim = nil,

-- walking
	_isWalking = nil,
	_Point = Vector:New(0,0,0),
	_Speed = 0.2,
	_displacement = nil,
	_lastCantMoveTime = -100,
	_lastlastCantMoveTime = -100,
	_destx = nil,
	_desty = nil,
	_destz = nil,
	_forceMove = nil,

	_shouldMove = 0,
	_butMove = 0,
	_distStart = 0,
	_distToEnd = 0,
	_runAltAnim = nil,

	_lastPitch = nil,
-- position
    Pos = Vector:New(0,0,0),
	_groundx = 0,
	_groundy = 0,
	_groundz = 0,

-- animation
    Animation = "idle",
    --_AnimationEvents = {},
	_isAnimating = nil,
	_noAnimTimer = 1,

--
    _AIBrain = nil,
	_lastEventCheck = 1,
	_died = nil,
	_notIsWalkingTimer = nil,
	_lastDamageTime = -100,
	_hitDelay = false,
	_state = "IDLE",
	_angleAttackX = 0,
	_angleAttackY = 0,
	_NonCollidableWithOtherRagDolls = false,
	_OrygHealth = -1,
	doNotUseWP = false,
	state = nil,
    
    _disableHits = nil,
    _disableDeathSounds = nil,
    _lastHitAnim = nil,
	_forceWalkAnim = nil,

	_sndHitId = nil,
	_sndStoppableID_CBinded = nil,
	_sndStoppableID_CBindedName = nil,
	
	_enabledRD = false,
	_raggDollPrecomputedCollData = {},
	_lastBlood = 0,

	_lastD = 0,
    s_SubClass = {		-- ###
        SoundsDefinitions = {},
	},

	IsBoss = false,
}
Inherit(CActor,CObject)

--============================================================================
function CActor:RestoreFromSave()
    if self._AIBrain then
        for i,o in self._AIBrain._goals do
            if AiStates[o.name] then
                InheritFunctionsAndStatics(o,AiStates[o.name])
            else
                if self._CustomAiStates and self._CustomAiStates[o.name] then
                    InheritFunctionsAndStatics(o,self._CustomAiStates[o.name])
                else
					DoFile(path.."Classes/Ai/"..o.name..".state")
					if not AiStates[o.name] then
						MsgBox(self._Name.." rfs%ERROR: no goal "..o.name)
					else
						InheritFunctionsAndStatics(o,AiStates[o.name])
					end
                end
            end            
        end
    end
	if self.s_SubClass.xchgTextures then
		for i,v in self.s_SubClass.xchgTextures do
			MDL.SetTexture(self._Entity, v[1], v[2])
		end
	end

    self._CurAnimLength = MDL.GetAnimLength(self._Entity, self._CurAnimIndex)
end
--============================================================================
function CActor:Delete()
	if self.CustomDelete then
		self:CustomDelete()
	end
	if self._objWaterImpactMain then
		ENTITY.UnregisterChild(self._Entity, self._objWaterImpactMain._Entity)
		GObjects:ToKill(self._objWaterImpactMain)
		self._objWaterImpactMain = nil
	end

	if self._proc then
		if debugMarek then Game:Print(self._Name.." _proc was not killed!") Game.freezeUpdate = true end
		GObjects:ToKill(self._proc)
		self._proc = nil
	end
	if self._trail then
		if debugMarek then Game:Print(self._Name.." trail was not killed!") Game.freezeUpdate = true end
		ENTITY.Release(self._trail)
		self._trail = nil
	end
	if self._trails then
		for i,v in self._trails do
			ENTITY.Release(v)
		end
	end
	if self._procBind then
		-- czy trzeba odbindowac?
		ENTITY.Release(self._procBind._targetEntity)
		--self._procBind._ToKill = true
		self._procBind = nil
	end

    PATH.Release(self._Path)
    ENTITY.Release(self._Entity)
    self._Entity = nil
    self._Path = nil
end
--============================================================================
function CActor:PreUpdate()
	local aiParams = self.AiParams
	if aiParams then
		local br = self._AIBrain
		if debugMarek and Game.freezeUpdate then
			return
		end
		if not self._died then
			if br and br.PreUpdate and self.AIenabled and not self._hitDelay then
				br:PreUpdate()		-- visibility update only
			end
		end
	end
end

function CActor:Update()
	local aiParams = self.AiParams
	if aiParams then
		local br = self._AIBrain
		
		if debug then
			if Game.freezeUpdate and not self._animStopped then
				self._animStopped = MDL.GetAnimTimeScale(self._Entity, self._CurAnimIndex)
				MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0)
			end
			if not Game.freezeUpdate and self._animStopped then
				MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, self._animStopped)
				self._animStopped = nil
			end
			if Game.freezeUpdate then
				return
			end
		end

		local brUpd = false
		if self.enableAIin then
			self.enableAIin = self.enableAIin - 1
			if self.enableAIin < 0 then
				self.AIenabled = true
				self.enableAIin = nil
				ENTITY.PO_SetFlying(self._Entity, false)
				--Game:Print("AI ENABLED... timer")
			end
		end
		if not self._died then
			if br and br.OnUpdate then
				if not self._hitDelay then
					if self.AIenabled then
						br:OnUpdate()
						brUpd = true
						if not self._isWalking then --and not self:IsRotating() then
							if self._notIsWalkingTimer then
								self._notIsWalkingTimer = self._notIsWalkingTimer - 1
								--if debugMarek then
								--	 Game:Print("=self._notIsWalkingTimer "..self._notIsWalkingTimer)
								--end
								if self._notIsWalkingTimer <= 0 then
									self._notIsWalkingTimer = nil
									if self.Animation == "walk" or self.Animation == "run" or self.Animation == self._forceWalkAnim or self.Animation == self._runAltAnim then
										--if debugMarek then Game:Print("not walk, but walk anim "..self._AIBrain._currentTime) end
										--Game.freezeUpdate = true
										self:SetIdle()
									end
								end
							end
						else
							self._notIsWalkingTimer = nil
						end
						if not self._isAnimating then			-- jesli sie nie animuje, to wlacz idleS
							--if debugMarek then Game:Print("self._isAnimating "..self._noAnimTimer) end
							self._noAnimTimer = self._noAnimTimer + 1
							if self._noAnimTimer > 2 then
								--if debugAnim then Game:Print("self:SetIdle()!! NO ANIM! "..self._noAnimTimer) end
								if self.disableNoAnimDetection then
									self._state = "NOANIM"
									self._noAnimTimer = 0
								else
									self:SetIdle()
								end
							end
						else
							self._noAnimTimer = 0
						end
					end
				else
					if self._hitDelay > 0 then
						self._hitDelay = self._hitDelay - 1
						if self._hitDelay <= 0 then
							self._hitDelay = nil
						end
					end
					if not self._isAnimating or self.Animation ~= self._lastHitAnim then
						self._hitDelay = nil
					end
				end
			end
		end

		if not brUpd then
			self._angleAttackX = 0
			self._angleAttackY = 0
		end
		
		if not self._died then
			-- get Events
			local animSpeed = MDL.GetAnimTimeScale(self._Entity, self._CurAnimIndex)
			if animSpeed > 0 then
				if self.Animation and self._isAnimating and self._AnimationEvents then
					local i = self._lastEventCheck
					local curAnimTime = self._CurAnimTime		-- tweak, zeby nie gubil eventow na koncu aniacji
					--Game:Print(self._Name.." : "..self.Animation..", curAnimTime"..curAnimTime..", total:"..self._CurAnimLength.." "..table.getn(self._AnimationEvents).." "..i)

					while self._AnimationEvents[i] do
						local ev = self._AnimationEvents[i]
						if ev[1] > curAnimTime or self._died then	
							break
						end
						if ev[1] <= curAnimTime and ev[2] then
							--if debugMarek and not self.AIenabled then
							--	Game:Print(self._Name.." wywoalanie eventa dla ai wylaczonego "..ev[2].." "..MDL.GetAnimTimeScale(self._Entity, self._CurAnimIndex).." "..self.Animation)
							--Game:Print(self._Name.." eventa "..ev[2].." "..ev[1].." time="..self._CurAnimTime)
							--if not self[ev[2]] then
							--	MsgBox("NIE MA EVENTU!!!!!!! "..ev[2].." "..self.Model.." "..self.Animation)
							--	break
							--else
							--	if type(self[ev[2]]) ~= "function" then
							--		MsgBox("NIE MA EVENTU, NIE FUNKCJA!!!!!!! "..ev[2].." "..self.Model.." "..self.Animation)
							--		break
							--	end
							--end
							self[ev[2]](self,ev[3], ev[4], ev[5], ev[6], ev[7], ev[8], ev[9])		-- ### pozniej dowolna liczba parametrow
						end
						i = i + 1
					end
					self._lastEventCheck = i
				end
			end
		end    


		--
		if self._died then
			self:OnDeathUpdate()
		else
			if self.CustomUpdate then
				self:CustomUpdate()
			end
		end
	end
    if self.TimeToDelete then
		if self.TimeToDelete > 0 then
			self.TimeToDelete = self.TimeToDelete - 1
		else
			GObjects:ToKill(self)
		end
	end

end

-------------
--function CActor:Particle(par3, par4)
--	local Joint = MDL.GetJointIndex(self._Entity, par4)
--	local x,y,z = MDL.TransformPointByJoint(self._Entity,Joint,0,0,0)
--	self:AddPFX(par3,0.5,Vector:New(x,y,z))
--end

function CActor:WeaponFire(par3, par4, par5)
	self._AIBrain:WeaponFire(par3, par4, par5)
end

function CActor:damage(par3, par4, damageSound)
	local br = self._AIBrain
	if br and br.r_closestEnemy then
		local aiParams = self.AiParams
		local dist = Dist3D(self._groundx, self._groundy, self._groundz, br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz)
		local angleAttack = math.atan2(br.r_closestEnemy._groundx - self._groundx, br.r_closestEnemy._groundz - self._groundz)
		local aDist = AngDist(self.angle, angleAttack)
		
		local angleRange = aiParams.attackRangeAngle
		if not angleRange then
			--if debugMarek then Game:Print(self._Name.." nie ma aiParams.attackRangeAngle!!") end
			angleRange = 120
		end
		local weaponRange = aiParams.weaponRange
		if not weaponRange then
			weaponRange = aiParams.attackRange
		end
		if dist <= weaponRange and math.abs(aDist) < angleRange*math.pi/180 then
			if damageSound then
				PlaySound2D(self._SoundDirectory..damageSound)
			else
				if self.s_SubClass.SoundsDefinitions.damage then
					self:PlayRandomSound2D("damage")
				end
			end
			if br.r_closestEnemy.OnDamage then
				local x,y,z = br.r_closestEnemy.Pos.X+FRand(-0.5,0.5),br.r_closestEnemy.Pos.Y+FRand(-0.5,0.5),br.r_closestEnemy.Pos.Z+FRand(-0.5,0.5)
				local v = Vector:New(FRand(-1,1),FRand(0,1),FRand(-1,1))
				v:Normalize()
				local nx,ny,nz = v.X,v.Y,v.Z
				if br.r_closestEnemy._Class == "CActor" then
					local j = br.r_closestEnemy:GetAnyJoint()
					x,y,z = MDL.GetJointPos(br.r_closestEnemy._Entity, j)
				end
				br.r_closestEnemy:OnDamage(aiParams.weaponDamage,self,AttackTypes.AIClose,x,y,z,nx,ny,nz)
			end
			if par3 and par4 then
				local v = Vector:New(br.r_closestEnemy._groundx - self._groundx, 0,  br.r_closestEnemy._groundz - self._groundz)
				v:Normalize()
				v.X = v.X * FRand(0.9, 1.1)
				v.Y = FRand(0.9, 1.1)
				v.Z = v.Z * FRand(0.9, 1.1)

				if br.r_closestEnemy._Class == "CPlayer" then
					ENTITY.PO_SetPlayerFlying(e_other, 0.3)
					--Game:Print("PLAYER PO_HIT = "..par3.." "..par4)
					ENTITY.SetVelocity(br.r_closestEnemy._Entity, v.X*par3, v.Y*par4, v.Z*par3)
				end
				--ENTITY.PO_Hit(br.r_closestEnemy._Entity, br.r_closestEnemy._groundx, br.r_closestEnemy.Pos.Y, br.r_closestEnemy._groundz, v.X*par3, v.Y*par4, v.Z*par3)

			end
			br._lastHitTime = br._currentTime
		else
			br._lastMissedTime = br._currentTime
		end
	end
end
	
--============================================================================
function CActor:OnClone(old)
	--self.Pos = Clone(self.Pos)        
    if old == CActor then 
        self.Pos = OppositeToCamera() 
    else
        self.Pos.X = old.Pos.X - 0.5
        self.Pos.Z = old.Pos.Z - 0.5
    end

    self._Entity = nil
    self._Path = nil
    
    local x,y,z = CAM.GetAng() 
	self.angle = -x * 3.14/180
	self._angleDest = self.angle
	self._lastAngle = self.angle
end
--============================================================================
function CActor:Apply(old)
    if not old or old.Model ~= self.Model or old.Scale ~= self.Scale then 
        ENTITY.Release(self._Entity)
		self._Entity = ENTITY.Create(ETypes.Model,self.Model,self._Name..":Script",self.Scale*0.1)
		WORLD.AddEntity(self._Entity,not self.Visible)
		EntityToObject[self._Entity] = self
        
        if self._AIBrain then
            ENTITY.EnableNetworkSynchronization(self._Entity)
        end
        
        if self.CreatePO then
            self:PO_Create()
            self._SphereSize = ENTITY.PO_GetMaxSphereRay(self._Entity)
            ENTITY.EnableDeathZoneTest(self._Entity,true)
        else
			self._SphereSize = 0.8
        end
        self._checkRadius = 0.5 * self._SphereSize

        if self.Synchronize then self:Synchronize() end
        if self._Synchronize then self:_Synchronize() end
        
		if self.s_SubClass.bindFX then
       		for i,v in self.s_SubClass.bindFX do
       			if self.s_SubClass.bindFXkeepScale then
       				self:BindFX(v[1], v[2]*self.Scale*self.s_SubClass.bindFXkeepScale, v[3], v[4], v[5], v[6])
       			else
					self:BindFX(v[1], v[2], v[3], v[4], v[5], v[6])
				end
			end
		end
		local t = self.s_SubClass.Trails
		if t then
			self._trails = {}
			for i,v in t do
				local e = ENTITY.Create(ETypes.Trail,v.name,"trailName")
				ENTITY.AttachTrailToBones(self._Entity,e,unpack(v.joints))
				WORLD.AddEntity(e)
				table.insert(self._trails, e)
			end
		end
		local l = self.s_SubClass.BindLight
		if l then
			local obj = CloneTemplate(l.template)
		    obj.Pos:Set(0,0,0)
		    obj:Apply()
		    ENTITY.RegisterChild(self._Entity,obj._Entity,true,MDL.GetJointIndex(self._Entity, l.joint))
		end

        if self.waterImpJoint and not self._objWaterImpactMain then		-- pozniej nie tu
			local e = self._Entity
			local j  = MDL.GetJointIndex(e,self.waterImpJoint)
			local x,y,z = MDL.GetJointPos(e,j)

   			local ke,obj = AddItem("StoneX.CItem",nil,Vector:New(x,y,z),true)
			obj.ObjOwner = self
			ENTITY.ComputeChildMatrix(ke,e,j)
			ENTITY.RegisterChild(e,ke,true,j)
						
			obj.speedUp = 0
			obj.speedDown = 0
			obj._no = 3
			obj.impAmplitude = self.waterImpAmplitude
			obj._amp = obj.impAmplitude
			obj.impPeriod = self.waterImpPeriod
			obj.impRange = self.waterImpRange
			obj.impSpeed = self.waterImpSpeed

			self._objWaterImpactMain = obj
        end

        --[[if self.BindRagdoll then
			local b = self.BindRagdoll
			local obj = CloneTemplate(b[2])
			if b[3] and obj then
				obj:Apply()
				local jChild = MDL.GetJointIndex(obj._Entity, b[3])
				--Game:Print("bind "..jChild.." "..b[3])
				MDL.SetPinnedJoint(obj._Entity, jChild, true)
				if b[7] then
	   				MDL.SetRagdollLinearDamping(obj._Entity, b[7])
					MDL.SetRagdollAngularDamping(obj._Entity, b[7])
				end

				self._procBind = Templates["PBindJointToJoint.CProcess"]:New(self._Entity, self, b[1], jChild, obj._Entity)
				--self._procBind._holdJointPos = aiParams.holdJointDisplaceSword      
				self._procBind._holdJointPos = Vector:New(b[4], b[5], b[6])
				self._procBind.CopyWholeMatrix = true
				self._procBind:Tick(0, true)
				GObjects:Add(TempObjName(), self._procBind)
				obj.NotSaveable = true
			end
        end--]]
        if self.s_SubClass.xchgTextures then
			for i,v in self.s_SubClass.xchgTextures do
				MDL.SetTexture(self._Entity, v[1], v[2])
			end
		end

		self._AnimEVENTS = {}
	
		if self.s_SubClass.Animations then
			for i, v in self.s_SubClass.Animations do
				self._AnimEVENTS[i] = {}
				if v[3] then		-- sa eventy
					for ii,vv in v[3] do
						table.insert(self._AnimEVENTS[i], vv)
						--Game:Print(self._Name.. " add "..vv[2])
					end
				end
			end
		end

		if self.s_SubClass.SoundsDefinitionsBindings then
			for i,v in self.s_SubClass.SoundsDefinitionsBindings do
				if table.getn(v) ~= 0 then
					if self._AnimEVENTS[i] then
						for ii,vv in v do
							table.insert(self._AnimEVENTS[i],vv)
							--Game:Print(self._Name.. " aDd "..vv[2])
						end
					else
						Game:Print(self._Name.." SoundsDefinitionsBindings nie ma "..i)
					end
				end
			end
		end
	    
		self:SortEvents()

		if self.OnCreateEntity then self:OnCreateEntity() end
		
		if Game.FearCard then self.Health = self.Health * 0.9 end
    end

	ENTITY.PO_Move(self._Entity,0,0,0)
	MDL.CreateShadowMap(self._Entity, self.shadow)
    
    if self.havokInfluenceInMonsterMovement then
		ENTITY.PO_SetMonsterMovementConst(self._Entity, self.havokInfluenceInMonsterMovement, self._DontCheckFloors)
    else
		ENTITY.PO_SetMonsterMovementConst(self._Entity, havokInfluenceInMonsterMovement, self._DontCheckFloors)
    end

	ENTITY.PO_SetMovedByExplosions(self._Entity, false)
	
	local brain = self._AIBrain
	if brain then
		brain:OnApply()
		brain._GuardAng = ENTITY.GetOrientation(self._Entity)
		local aiParams = self.AiParams
		if aiParams.alwaysSee then
			--Game:Print(self._Name.." always see")
			ENTITY.PO_SetSightParams(self._Entity, 150, 150, 360)
		else
			ENTITY.PO_SetSightParams(self._Entity, aiParams.viewDistance, aiParams.viewDistance360, aiParams.viewAngle, aiParams.viewAnglePitch);
		end
		for i,v in aiParams.aiGoals do
			if not brain:AddState(v) then
				Game:Print(v.." state not found")
			end
		end
	end
	
    self:ApplySpecular()
    self:ApplyFresnel()

   	self:ForceAnim(self.Animation,not self.AnimationLoop)

   	if debugMarek and Game.freezeUpdate and self._CurAnimIndex then
		self._animStopped = MDL.GetAnimTimeScale(self._Entity, self._CurAnimIndex)
		MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0)
	end

    
    self._groundx,self._groundy,self._groundz = ENTITY.PO_GetPawnFloorPos(self._Entity)
    self._angleDest = self.angle
    self._lastAngle = self.angle
    if Game.Difficulty == 0 and not self._HealthMax then
		if self.enableGibWhenHPBelow then
			self._enableGibWhenHPBonusHP = self.Health * 0.25
		end
		self.Health = self.Health * 0.75
    end
    self._HealthMax = self.Health
    self._HealthAfterDeath = 0
	self._SoundDirectory = "actor/"..self.Model.."/"
	
	if self.s_SubClass.SoundDir then
		self._SoundDirectory = "actor/"..self.s_SubClass.SoundDir.."/"
	end
	if self.OnApply then self:OnApply() end
end
--============================================================================
function CActor:SortEvents()
	function c(a,b)
		if a[1] < b[1] then
			return true
		else
			return false
		end
	end

	
	for i, v in self._AnimEVENTS do
		table.sort(v,c)
	end
--[[	
	for i, v in self._AnimEVENTS do
		for i2,v2 in v do
			Game:Print(self._Name.." "..i.." "..v2[1].." "..v2[2])
		end
	end
	]]
	c = nil
end
--============================================================================
function CActor:SetAIBrain()
	self._AIBrain = Clone(CAiBrain)
	self._AIBrain:OnInit(self)
	self._OrygHealth = self._Health
	if not self._randomizedParams.WalkSpeed then
		local r = 0.15
		if self.randomizeWalks then
			r = self.randomizeWalks
		end
        if self.FlySpeed then
            self._randomizedParams.FlySpeed = FRand(self.FlySpeed * (1 - r), self.FlySpeed * (1 + r))
        end
		self._randomizedParams.WalkSpeed = FRand(self.WalkSpeed * (1 - r), self.WalkSpeed * (1 + r))
		self._randomizedParams.RunSpeed = FRand(self.RunSpeed * (1 - r), self.RunSpeed * (1 + r))
		self._randomizedParams.RotateSpeed = FRand(self.RotateSpeed * (1 - r), self.RotateSpeed * (1 + r))
		--Game:Print("randomize params "..self._Name)
	end
	--Game:Print(self._randomizedParams.WalkSpeed.." "..self._randomizedParams.RunSpeed.." "..self._randomizedParams.RotateSpeed)
end
--============================================================================
function CActor:ForceAnim(anim,loop,speed, blendTime)
    self._isAnimating = false
    return self:SetAnim(anim,loop,speed,blendTime)
end
--============================================================================
--[[function CActor:SeesObject(obj)
    return ENTITY.SeesPlayer(self._Entity,Player._Entity)
    --return ENTITY.SeesEntity(self._Entity,obj._Entity)
    --return ENTITY.SeesPoint(self._Entity,obj.Pos.X,obj.Pos.Y,obj.Pos.Z)
end--]]
--============================================================================
function CActor:SetAnim(anim,loop,animSpeed, blendTime)
    if self._isAnimating and anim == self.Animation and self._animLoop == loop then      -- and not force
		--Game:Print(self._Name.." Skip anim "..anim)
		return true
	end

	if self._enabledRD then
		--Game:Print(self._Name.." CANNOT SetAnim - ragdoll enabled")
		return false
	end
	self._noAnimTimer = 0
	self:EndTrailSword()
	if self.EndTrailSword2 then
		self:EndTrailSword2()
	end

    if self.OnSetAnim then self:OnSetAnim(anim) end
    
    self._CurAnimTime = 0
    self._CurAnimIndex = -1

	local blend = blendTime
	local speed = animSpeed
	
    if self.s_SubClass.Animations and self.s_SubClass.Animations[anim] then 
		if not speed then
			speed = self.s_SubClass.Animations[anim][1]
		end
		if not blend then
			blend = self.s_SubClass.Animations[anim][4]
		end
    end

    if not blend then
        blend = 0.201
    end
	if not speed then
		speed = 1.0
	end

    self._HasMovingCurve = false
    self._moveWithAnimation = false
    local mcurve = 0
    if self.s_SubClass.Animations and self.s_SubClass.Animations[anim] then
        -- reset movement curve
        mcurve = self.s_SubClass.Animations[anim][2]
        if type(mcurve) == "boolean" then
            if mcurve == true then
                mcurve = MovingCurve.ETransZ
            else
                mcurve = 0
            end
        end
        if mcurve ~= 0 then
			self._HasMovingCurve = true
        end
        self._AnimationEvents = self._AnimEVENTS[anim]
        
        if self.s_SubClass.Animations[anim][5] then
			self._moveWithAnimation = true
			--Game:Print("MWANIM "..(self.angle * 180/math.pi))
			self._oldAngle = self.angle
		end
    end    
    
    ---- RANDOMIZE ANIMSPEED 3% ----
    if self._AIBrain then
		speed = speed * FRand(0.97, 1.03)
	end
    --------------------------------
    if anim == "" then
        return false
    end
    local anm = MDL.SetAnim(self._Entity, anim, loop, speed, blend, mcurve, self._HasMovingCurveRot)

    if anm < 0 then
        --if debugMarek then Game:Print(self._Name.." nie ma animacji:"..anim) end
		return false
	end

	local lastLoop = "true"
	if not self._animLoop then
		lastLoop = "false"
	end

	local Loop = "true"
	if not loop then
		Loop = "false"
	end

	--if debugAnim then Game:Print(self._Name.." >Set anim: "..anim.." "..", blend "..blend..", old anim "..self.Animation.." "..self._LastAnimTime) end

--[[	for i,v in self._AnimationSounds do
		SOUND3D.SetVolume(v[1], 0, 0.3)
		SOUND3D.Forget(v[1])
		Game:Print("anim end: faded sound "..v[2])
	end
	self._AnimationSounds = {}--]]
	
    self._CurAnimIndex = anm
    self._CurAnimLength = MDL.GetAnimLength(self._Entity, anm)        
    self._LastAnimTime = 0
    
	self:ZeroEventsTime()

	self._animLoop = loop
	self._isAnimating = true
	if self.OnStartAnim then self:OnStartAnim(self.Animation) end
	self.Animation = anim
	return true
end
--============================================================================
--function CActor:GetAnimLength()
--    return self._CurAnimLength
--end
--============================================================================
--function CActor:GetAnimTime()
--    return MDL.GetAnimTime(self._Entity,self._CurAnimIndex)    
--end
--============================================================================
--function CActor:GetAnimMovement(delta)
--    return MDL.GetAnimMovement(self._Entity,self._CurAnimIndex,delta)
--end
--============================================================================
function CActor:Synchronize()
    -- synchronization with  C++ object
	if not ENTITY.PO_Exist(self._Entity) then
        ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
        if self.Rot then
            self.Rot:ToEntity(self._Entity) 
        else
            ENTITY.SetOrientation(self._Entity, self.angle)
        end
    else
        self.Pos.X,self.Pos.Y,self.Pos.Z = ENTITY.GetPosition(self._Entity)
        self.angle = ENTITY.GetOrientation(self._Entity);
    end
end
--============================================================================
function CActor:ZeroEventsTime()
	self._lastEventCheck = 1
end
--============================================================================
function CActor:Tick(delta)
	if debugMarek then
		if Game.freezeUpdate then
			ENTITY.PO_Move(self._Entity,0,0,0)
			return
		end
	end

	if MonsterAcceleration and self._walkAnimSpeed then
		if self._isWalking and not self._flying then
			self._walkAnimSpeed = self._walkAnimSpeed + delta * 1/MonsterAcceleration * self._walkAnimSpeedMax
			if self._walkAnimSpeed > self._walkAnimSpeedMax then
				self._walkAnimSpeed = self._walkAnimSpeedMax
			end
			if self._HasMovingCurve and not self._frozen then
				self:SetAnimSpeed(self._walkAnimSpeed)
			end
		else
			-- pozniej spadek po delayu 1/10sec
			if not (self.Animation == "walk" or self.Animation == "run" or self.Animation == self._forceWalkAnim or self.Animation == self._runAltAnim) then
				self._walkAnimSpeed = self._walkAnimSpeed - delta * 1/MonsterAcceleration * self._walkAnimSpeedMax
				if self._walkAnimSpeed < 0.1 * self._walkAnimSpeedMax then
					self._walkAnimSpeed = 0.1 * self._walkAnimSpeedMax
				end
			end
		end
	end
	
	if not self._enabledRD and not self._gibbed then
		self._CurAnimTime = MDL.GetAnimTime(self._Entity,self._CurAnimIndex)
	    
		if self._isAnimating and (self._CurAnimTime < self._LastAnimTime or self._CurAnimTime == self._CurAnimLength) then
			self:ZeroEventsTime()
			--if debugMarek then Game:Print(self._Name.." > Not animating "..(Game.currentTime/30)) end
			if self._animationBeforeHit then
				if not self.AIenabled and not self._died then
					self:SetAnim(self._animationBeforeHit, true)		-- narazie nie zapamietuje czy true
				end
				self._animationBeforeHit = nil
			end

			if self.OnFinishAnim then self:OnFinishAnim(self.Animation) end
			if not self._animLoop then
				self._isAnimating = nil
				--self._isWalking = nil			-- ????????
				self._state = "IDLE"			-- ????????
				--if debugAnim then Game:Print(self._Name.." koniec animacji "..self.Animation.." self._CurAnimTime= "..self._CurAnimTime.." self._LastAnimTime= "..self._LastAnimTime.." self._CurAnimLength = "..self._CurAnimLength) end
			end
		end
	end
	
	if self.AiParams then
		if not self._died then			-- and not self.enabledRD 
			self._groundx,self._groundy,self._groundz = ENTITY.PO_GetPawnFloorPos(self._Entity)
			if self._rotatingWithAnim then
				self:UpdateRotateWithAnim(delta)
			else
				self._isRotating = self:IsRotating()
				if self._isRotating then
					self:UpdateRotate(delta)
				else
					self._lastVel = 0
				end
			end
			if self._isWalking and not self._enabledRD then
				if self._flying then
					self:UpdateFlying(delta)
				else
					self:UpdateWalking(delta)
				end
			else
				if --[[self._HasMovingCurve--]] --[[and not self._notIsWalkingTimer or--]] self._moveWithAnimation then
					self:MoveWithAnimation(delta)
				else
					
					if self.maxWalkAcc then
                        if self._v_vel and self._v_vel:Len() > 0.005 then
                            --Game:Print("hamowanie "..self._v_vel:Len())
                            self._v_vel:MulByFloat(0.8)
							local d2 = 1 / delta
                            ENTITY.PO_Move(self._Entity,self._v_vel.X*d2, self._v_vel.Y*d2, self._v_vel.Z*d2)
                        else
                            ENTITY.PO_Move(self._Entity,0,0,0)
                        end
						
					else
						ENTITY.PO_Move(self._Entity,0,0,0)
					end
				end

			--[[else
				if self.flyingInertia and self._lastmvx then
					local b,d = WORLD.LineTrace(self._groundx, self._groundy, self._groundz, self._groundx, self._groundy - 2.0, self._groundz)	-- moze nie co update?
					if not d then
						if not self._timerMove then
							self._timerMove = 6
						end
						Game:Print("f")
						self._timerMove = self._timerMove - 1

						self._lastmvx = self._lastmvx * 0.5
						self._lastmvy = self._lastmvy * 0.5
						self._lastmvz = self._lastmvz * 0.5
						
						ENTITY.SetVelocity(self._Entity,self._lastmvx, self._lastmvy, self._lastmvz)
						
						--local x,y,z,vel = ENTITY.GetVelocity(self._Entity)
						--Game:Print(" vel2 = " ..vel)

						
						if self._timerMove < 0 then
							self._timerMove = nil
							self._lastmvx = nil
						end
					else
						self._timerMove = nil
						self._lastmvx = nil
					end
				end--]]
			end

			local headParams = self.s_SubClass
			if headParams.rotateHead and self.AIenabled and not self._disableRotateHead then

				self._AIBrain:RotateHead(delta)
                local joint = MDL.GetJointIndex(self._Entity, headParams.rotateHeadBone)
                
				if headParams.rotateHeadRight and headParams.rotateHeadLeft then		-- custom rotate
					local v = {0, self._angleAttackX, self._angleAttackY}
					if headParams.rotateHeadCoordsAdd then
						v[1] = v[1] + headParams.rotateHeadCoordsAdd.X
						v[2] = v[2] + headParams.rotateHeadCoordsAdd.Y
						v[3] = v[3] + headParams.rotateHeadCoordsAdd.Z
					end
					if self._angleAttackX > 0 then
                        MDL.ApplyJointRotation(self._Entity, joint, v[headParams.rotateHeadCoords.X] * headParams.rotateHeadRight.X, v[headParams.rotateHeadCoords.Y] * headParams.rotateHeadRight.Y, v[headParams.rotateHeadCoords.Z] * headParams.rotateHeadRight.Z)
					else
						--MDL.SetHeadTrackRot(self._Entity, v[headParams.rotateHeadCoords.X] * headParams.rotateHeadLeft.X,  v[headParams.rotateHeadCoords.Y] * headParams.rotateHeadLeft.Y, v[headParams.rotateHeadCoords.Z] * headParams.rotateHeadLeft.Z)
                        MDL.ApplyJointRotation(self._Entity, joint, v[headParams.rotateHeadCoords.X] * headParams.rotateHeadLeft.X,  v[headParams.rotateHeadCoords.Y] * headParams.rotateHeadLeft.Y, v[headParams.rotateHeadCoords.Z] * headParams.rotateHeadLeft.Z)
					end
				else														-- default
					--MDL.SetHeadTrackRot(self._Entity, -self._angleAttackX, self._angleAttackY, 0)
                    MDL.ApplyJointRotation(self._Entity, joint, -self._angleAttackX, self._angleAttackY, 0)
				end
			end
			if self.OnTick then self:OnTick(delta) end
		end
	end

	--------------------
    self._LastAnimTime = self._CurAnimTime
end

--============================================================================
function CActor:UpdateFlying(delta)
	local x,y,z = self._groundx,self._groundy,self._groundz
	local vel = Dist3D(x,y,z, self._lastgroundx,self._lastgroundy,self._lastgroundz)
	self._butMove = self._butMove + vel
	self._distStart = self._distStart + vel
	self._lastgroundx,self._lastgroundy,self._lastgroundz = x,y,z

	if self._walkMaxDist then
		self._walkTotalMove = self._walkTotalMove + vel
		if self._walkTotalMove > self._walkMaxDist then
			--if debugMarek then Game:Print("max distance reached "..self._walkTotalMove) end
			self:Stop()
			return
		end
	end


	if self._flyWithAngle then
		local distToEnd = Dist3D(x,y,z, self._destx,self._desty,self._destz)		-- pozniej + step
		if (self._lastDistToEnd < distToEnd and distToEnd < 1.0) or distToEnd < 0.05 or self._distStart > self._distToEnd * 3 then
			--if debugMarek then Game:Print("koniec latania1 "..self._lastDistToEnd.." "..distToEnd) end
			self._isWalking = nil
			self._flying = nil
			self._notIsWalkingTimer = self._notIsWalkingTimerAmount
			return
		end
		self._lastDistToEnd = distToEnd
		self:RotateToVector(self._destx,self._desty,self._destz)
	else
		if self._distStart > (self._distToEnd - 0.02) then
			--if debugMarek then Game:Print("koniec latania2") end
			if not self._disableInitialRotate then
				self:RotateTo(self._destAngle*180/math.pi)
			end
			self._isWalking = nil
			self._flying = nil
			self._notIsWalkingTimer = self._notIsWalkingTimerAmount
			return
		end
		if Dist3D(x,y,z,self._destx,self._desty,self._destz) < 0.01 then		-- do punktu docelowego
			--if debugMarek then Game:Print("koniec latania3") end
			self._isWalking = nil
			self._flying = nil
			self._notIsWalkingTimer = self._notIsWalkingTimerAmount
			return
		end
	end
	local Step = Vector:New(self._destx - x, self._desty - y, self._destz - z)
	local mvx,mvy,mvz
	
	if self._flyWithAngle then
		local maxDeltaY = self.smoothFly * 180/math.pi * delta
		
		Step:Normalize()
		
		local pitch =  math.atan2(Step.Y, math.sqrt((Step.X)*(Step.X)+(Step.Z)*(Step.Z)))
		local a = 1.0
		if self.flyEmulateGravityEffect then
			if pitch < 0 then
				a = 1.0 - pitch / self.flyEmulateGravityEffect
			end
		end

		if self._lastPitch then
			local deltaY = math.abs(self._lastPitch - pitch)*180/math.pi
			--Game:Print("pitch = "..(pitch*180/math.pi).." "..(self._lastPitch*180/math.pi).." deltaY = "..deltaY..", maxDeltaY="..maxDeltaY)

			if pitch > self._lastPitch and deltaY > maxDeltaY then
				--Game:Print(" limit "..(self._lastPitch + maxDeltaY))
				pitch = self._lastPitch + maxDeltaY*math.pi/180
				--Game.freezeUpdate = true
			end
			
			if pitch < self._lastPitch and deltaY > maxDeltaY then
				--Game:Print(" limit2 "..(self._lastPitch - maxDeltaY))
				pitch = self._lastPitch - maxDeltaY*math.pi/180
				--Game.freezeUpdate = true
			end
		end
				
		self._lastPitch = pitch

		mvx,mvy,mvz = VectorRotate(1,0,0, 0, 0, -pitch)
		--Game:Print("1 = "..mvx.." "..mvy.." "..mvz)
		mvx,mvy,mvz = VectorRotate(mvx,mvy,mvz, 0, -self.angle+math.pi/2, 0)
		--Game:Print("2 = "..mvx.." "..mvy.." "..mvz)
		
		--[[
		if debugMarek then
			self.yaadebug1 = x
			self.yaadebug2 = y
			self.yaadebug3 = z
			self.yaadebug4 = x + mvx
			self.yaadebug5 = y + mvy
			self.yaadebug6 = z + mvz
		end--]]
		
		local mul = self._Speed * delta * a
		mvx = mvx * mul
		mvy = mvy * mul
		mvz = mvz * mul

		local d = math.sqrt(mvx*mvx+mvy*mvy+mvz*mvz)
		self._shouldMove = self._shouldMove + d
	else
		local v = Vector:New(Step.X, Step.Y, Step.Z)
		v:Normalize()
		mvx = v.X * delta * self._Speed
		mvy = v.Y * delta * self._Speed
		mvz = v.Z * delta * self._Speed
		local d = math.sqrt(mvx*mvx+mvy*mvy+mvz*mvz)
		self._shouldMove = self._shouldMove + d
	end

	if not ENTITY.PO_Exist(self._Entity) then
		self.Pos.X = self.Pos.X + mvx
		self.Pos.Y = self.Pos.Y + mvy
		self.Pos.Z = self.Pos.Z + mvz
	else 
		local d = 1 / delta
		ENTITY.SetVelocity(self._Entity,mvx * d, mvy * d, mvz * d)
	end
	
	

	local br = self._AIBrain	
	if br and self.AIenabled and self.checkColInFlight then
		if self._lastCheck and self._lastCheck ~= br._currentTime then
			--Game:Print((self._lastCheck*30).." "..(br._currentTime*30).." |  was= "..self._butMove.." teor="..self._shouldMove)
			if self._lastShouldMove then
				if self._butMove < self._shouldMove * self.checkColInFlight and self._butMove < self._lastbutMove and self._shouldMove > 0.01 then
					--if debugMarek then Game:Print("F Obstacle "..(br._currentTime*30).." "..(self._lastCantMoveTime*30).." "..(self._lastlastCantMoveTime*30).."  "..self._butMove.."  should: "..self._shouldMove) end
					if (br._currentTime < self._lastCantMoveTime + 2/30)  then
						if debugMarek then Game:Print(self._Name.." Obstacle -> idle") end
						--ENTITY.PO_Move(self._Entity,mvx * 2 / delta, mvy * 2 / delta, mvz * 2 / delta)
						self:Stop()
					else
						--if debugMarek then Game:Print(self._Name.." Obstacle?? "..br._currentTime.." "..self._lastCantMoveTime) end
					end
					self._lastCantMoveTime = br._currentTime
				end
			end
			
			self._lastShouldMove = self._shouldMove
			self._lastbutMove = self._butMove
			self._shouldMove = 0
			self._butMove = 0
		end
		self._lastCheck = br._currentTime
	end

end


function CActor:MoveWithAnimation(delta)
	local mvx,mvy,mvz
	local x,y,z = MDL.GetAnimMovement(self._Entity,self._CurAnimIndex,delta)	--self:GetAnimMovement(delta)
	if self._overrideMovingCurve then
		x = x * self._overrideMovingCurve
		y = y * self._overrideMovingCurve
		z = z * self._overrideMovingCurve
	end
	if self._moveWithAnimationDoNotUpdateAngle then
		--Game:Print("rw oldangle "..(self._oldAngle*180/math.pi))
		mvx = math.cos(-self._oldAngle)*x - math.sin(-self._oldAngle)*z
		mvy = 0.0
		mvz = math.sin(-self._oldAngle)*x + math.cos(-self._oldAngle)*z
	else
		mvx = math.cos(-self.angle)*x - math.sin(-self.angle)*z
		mvy = 0.0
		mvz = math.sin(-self.angle)*x + math.cos(-self.angle)*z
	end

	if not ENTITY.PO_Exist(self._Entity) then
		self.Pos.X = self.Pos.X + mvx
		self.Pos.Y = self.Pos.Y + mvy
		self.Pos.Z = self.Pos.Z + mvz
	else 
		local d = 1 / delta
		--[[if debugMarek then
			self._debugPOMOVEx,self._debugPOMOVEy, self._debugPOMOVEz = mvx * d, mvy * d, mvz * d
		end--]]

		ENTITY.PO_Move(self._Entity,mvx * d, mvy * d, mvz * d)
	end
end


function CActor:UpdateWalking(delta)
	if math.abs(self._distToAngle) > 60 * 3.14/180 and not self.disbleRotWhenStartWalk and not self._walkWithAngle then
		ENTITY.PO_Move(self._Entity,0,0,0)
		--if debugMarek then Game:Print(self._Name.." BIG ANGLE to move 0,0,0") end
		return
	end
	
	if self._walkWithAngle and not self._isRotating and not self._panzer then
		--if debugMarek then Game:Print("koniec obracania, stop walk") end
		self:SetIdle()
		return
	end
	local x,y,z = self._groundx,self._groundy,self._groundz
	local vel = Dist2D(x,z, self._lastgroundx,self._lastgroundz)		-- vel
	self._butMove = self._butMove + vel
	
	--Game:Print("uw = "..self._AIBrain._currentTime)
	--Game.freezeUpdate = true
	if self._walkMaxDist then
		self._walkTotalMove = self._walkTotalMove + vel
		if self._walkTotalMove > self._walkMaxDist then
			--if debugMarek then Game:Print("max distance reached "..self._walkTotalMove) end
			self:SetIdle()
			return
		end
	end
	if not self._isAnimating then
		self:Stop()
		--if debugMarek then Game:Print("stop bo nie anim") end
		return
	end

	self._distStart = self._distStart + vel
	self._lastgroundx,self._lastgroundy,self._lastgroundz = x,y,z

	--Game:Print("from= "..self._distStart.." end="..self._distToEnd)
	--if self.xxxx then
	--	self.xxxx = nil
	--	Game:Print("dist to st "..self._distStart.."self._distToEnd "..self._distToEnd)
	--	Game.freezeUpdate = true
	--end
	if self._forceMove then
		if self._distStart > (self._distToEnd - 0.05) then
			--[[ Game.freezeUpdate = true
			if self._moveBackward then
				self:RotateTo(self._destAngle*180/math.pi + math.pi)
				Game:Print("FINISHED walking BACK "..self.angle..)
			else
				Game:Print("FINISHED walking")
				self:RotateTo(self._destAngle*180/math.pi)
			end--]]
			--if debugMarek then Game:Print(self._Name.." FINISHED walking") end
			self._isWalking = nil
			self._notIsWalkingTimer =  self._notIsWalkingTimerAmount
			return
		end
	else
		if self._distStart > (self._distToEnd - 0.05) then
			if not self:NextPoint() then
				--if debugMarek then Game:Print(self._Name.." next point false!") end
				self._isWalking = nil
				self._notIsWalkingTimer =  self._notIsWalkingTimerAmount
				return
			end
		end
	end

	local l
	local Step = {}
	if self._forceMove then
		l = Dist2D(x,z,self._destx,self._destz)		-- do punktu docelowego
		if l < 0.01 then
			--if debugMarek then Game:Print(self._Name.." za maly move 1 - stop") end
			self._isWalking = nil
			self._notIsWalkingTimer =  self._notIsWalkingTimerAmount
			return
		end
		Step.X = self._destx - x
		Step.Y = self._desty - y
		Step.Z = self._destz - z
	else
		l = Dist2D(x,z,self._Point.X,self._Point.Z)   -- do nastepnego way-pointa
		if l < 0.01 then
			if not self:NextPoint() then					-- ####################
				--if debugMarek then 
				--	Game:Print("next point false!")
				--	Game.freezeUpdate = true
				--end
				self._isWalking = nil
				self._notIsWalkingTimer =  self._notIsWalkingTimerAmount
			end
			--Game:Print("next point ok!")
			--if debugMarek then Game:Print(self._Name.." za maly move 2") end
			return
		end
		Step.X = self._Point.X - x
		Step.Y = self._Point.Y - y
		Step.Z = self._Point.Z - z
	end

	local mvx,mvy,mvz
	
	if self._HasMovingCurve then
		local x,y,z = MDL.GetAnimMovement(self._Entity,self._CurAnimIndex,delta)	--self:GetAnimMovement(delta)
		local ang
		if self._walkWithAngle then
			ang = -self.angle
		else
			ang = -math.atan2(Step.X, Step.Z)
		end
		
		--[[if debugMarek then
			self._debugSTEPx = Step.X
			self._debugSTEPz = Step.Z
		end--]]
		if self._moveBackward then
			x = -x
			--y = -y
			z = -z
		end
		if self._overrideMovingCurve then
			x = x * self._overrideMovingCurve
			--y = y * self._overrideMovingCurve
			z = z * self._overrideMovingCurve
		end
		mvy = 0
		if not self._moveWithAnimation then
			mvx = math.cos(ang)*x - math.sin(ang)*z
			mvz = math.sin(ang)*x + math.cos(ang)*z
		else
			local angle = -self.angle
			mvx = math.cos(angle)*x - math.sin(angle)*z
			mvz = math.sin(angle)*x + math.cos(angle)*z
		end

		local d = math.sqrt(x*x+z*z)

		if Lev.AI_walkUp then
			mvy = d * Lev.AI_walkUp			-- troche do gory zeby latwiej przechodzil przez przeszkody
			--Game:Print("move up "..mvx.." "..mvy.." "..mvz)
		end

		
		if not self.doNotDampMovementIfLastStepPassesDestination then		-- dla malych krokow pozwoli uniknac szarpniec w chodzeniu, b
			if self._distStart + d > self._distToEnd + 0.2 then
				--Game.freezeUpdate = true
				local mul = 1 - (d - (self._distToEnd - self._distStart))/d
				--Game:Print("self._distStart + d > self._distToEnd "..self._distStart.."  "..self._distToEnd.."  "..d.." -> "..(mul*d))
				--Game:Print("mul = "..mul)
				mvx = mvx * mul
				mvz = mvz * mul
				d = d * mul
				--self.xxxx = 1
			end
		end


		self._shouldMove = self._shouldMove + d

	else
		local v = Vector:New(Step.X, 0, Step.Z)
		v:Normalize()
		mvx = v.X * delta * self._Speed
		mvy = 0
		mvz = v.Z * delta * self._Speed		
		
		local d = math.sqrt(mvx*mvx+mvz*mvz)
		if self.maxWalkAcc then
	
			--Game:Print("d = "..d)
			if d > self._lastD + self.maxWalkAcc*delta then		-- ograniczenie przyspieszenia
				d = (self._lastD/delta + self.maxWalkAcc)*delta
				--Game:Print("new d = "..d.." should = "..math.sqrt(mvx*mvx+mvz*mvz))
				local v = Vector:New(mvx,mvy,mvz)
				v:Normalize()
				v:MulByFloat(d)
				mvx = v.X
				mvy = v.Y
				mvz = v.Z
			end
			self._lastD = d

			if not self._v_vel then
				self._v_vel = Vector:New(0,0,0)
			end

			self._v_vel.X = mvx
			self._v_vel.Y = mvy
			self._v_vel.Z = mvz
		end

		if Lev.AI_walkUp then
			--Game:Print("move up")
			mvy = d * Lev.AI_walkUp			-- troche do gory zeby latwiej przechodzil przez przeszkody
		end

		self._shouldMove = self._shouldMove + d
		--Game:Print("self._shouldMove = "..self._shouldMove)
	end


	if not ENTITY.PO_Exist(self._Entity) then
		self.Pos.X = self.Pos.X + mvx
		self.Pos.Y = self.Pos.Y + mvy
		self.Pos.Z = self.Pos.Z + mvz
	else 
		local d = 1 / delta
		--if mvy < 0 then
		--	mvy = 0
		--end


		--[[local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
		v:Normalize()
		local length = 1
		local fx = v.X*length + self._groundx
		local fz = v.Z*length + self._groundz

		DEBUGfx = dx	DEBUGfy = self._groundy	DEBUGfz = fz
		DEBUGcx = self._groundx	DEBUGcy = self._groundy	DEBUGcz = self._groundz

		local b = WORLD.LineTraceFixedGeom(self._groundx, self._groundy, self._groundz, fx,self._groundy, fz)
		if b then
			mvy = math.sqrt((mvx*mvx) + (mvz*mvz)) * 1.0	-- narazie ###
			--Game:Print("!")
		end--]]
		
		--Game:Print("PO_MOVE 2 "..(math.sqrt(mvx*mvx+mvy*mvy+mvz*mvz)))
		--Game:Print("PO_MOVE"..(mvx * d).." "..(mvy * d).." "..(mvz * d))
		--[[if debugMarek then
			self._debugPOMOVEx,self._debugPOMOVEy, self._debugPOMOVEz = mvx * d, mvy * d, mvz * d
		end--]]

		ENTITY.PO_Move(self._Entity,mvx * d, mvy * d, mvz * d)
	end


	if self._AIBrain and self.AIenabled then
		local br = self._AIBrain
		if self._lastCheck and self._lastCheck ~= br._currentTime then
			--Game:Print((self._lastCheck*30).." "..(br._currentTime*30).." |  was= "..self._butMove.." teor="..self._shouldMove)
			if self._lastShouldMove then
				if self._butMove < self._lastShouldMove * self.CollisionDetect and self._butMove < self._lastbutMove and self._lastShouldMove > 0.01 then
					--if debugMarek then Game:Print("Obstacle "..(br._currentTime*30).." "..(self._lastCantMoveTime*30).." "..(self._lastlastCantMoveTime*30).."  "..self._butMove.."  should: "..self._shouldMove) end
					if (br._currentTime < self._lastCantMoveTime + 2/30) and
					   (br._currentTime < self._lastlastCantMoveTime + 3/30) then
						--if debugMarek then Game:Print(self._Name.." Obstacle -> idle") end
						--ENTITY.PO_Move(self._Entity,mvx * 2 / delta, mvy * 2 / delta, mvz * 2 / delta)
						self:Stop()
					end
					self._lastlastCantMoveTime = self._lastCantMoveTime			-- hardcore
					self._lastCantMoveTime = br._currentTime
				end
			end
			
			self._lastShouldMove = self._shouldMove
			self._lastbutMove = self._butMove
			self._shouldMove = 0
			self._butMove = 0
		end
		self._lastCheck = br._currentTime
	end
end

--============================================================================
function CActor:IsRotating()
	self._distToAngle = AngDist(self.angle, self._angleDest)
	if self._distToAngle > 0.005 or self._distToAngle < -0.005 then		-- ok. 1/3 stopnia
		return 1
	end
	return nil
end

function CActor:CreateGib(newModel)
    if Tweak.GlobalData.DisableGibs and not self.notBleeding then
    	if not (self.Model == "zombieapo_v2" and self.Health > 0) then
			return false
		end
    end
	local gib = MDL.MakeGib(self._Entity, ECollisionGroups.RagdollNonColliding, newModel)
	if gib then
		--Game:Print(">> enable gib <<")
		self._CurAnimIndex = 0
		self._gibbed = true
		
		if not forceModel then
            ENTITY.RemoveRagdoll( self._Entity )		   -- added by Krystian	
            ENTITY.EnableDraw( self._Entity, false, true ) -- added by Krystian
			ENTITY.Release( self._Entity )
			self._Entity = gib
			EntityToObject[self._Entity] = self
		end

        if self.s_SubClass.xchgTextures then
			for i,v in self.s_SubClass.xchgTextures do
				MDL.SetTexture(self._Entity, v[1], v[2])
			end
		end

		local x,y,z = self:GetJointPos("root")
		if not self._disableGibSound then
			local s
            if self._frozen then 
				self:PlaySound("gibFrozen",nil,nil,nil,nil,x,y,z)
            else
				self:PlaySound("gib",nil,nil,nil,nil,x,y,z)
            end
			self._disableDeathSounds = true
		end
		if self.s_SubClass.gibFX then
			AddPFX(self.s_SubClass.gibFX,0.4,Vector:New(x,y,z))
		end
		if self.s_SubClass.GibEmitters then
			for i,v in self.s_SubClass.GibEmitters do
				local gibFX = v[2]
				if self._forceGibFX then
					gibFX = self._forceGibFX
				end
				self:BindFX(gibFX,0.3,v[1], nil,nil,nil, v[3])
			end
		end
		
		if self.s_SubClass.gibShader then
			if self._frozen then
				MDL.SetMaterial(gib, "palskinned_freeze")
			else
				MDL.SetMaterial(gib, self.s_SubClass.gibShader)
			end
		end

		if self.s_Physics.Mass then
			ENTITY.PO_SetMass(gib, self.s_Physics.Mass)
		end
		if self.s_Physics.RagdollFriction then
			MDL.SetRagdollFriction(self._Entity, self.s_Physics.RagdollFriction)
		end
	    if self.s_SubClass.CollidableRagdoll then 
		    MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.RagdollColliding)
		end
		
		if self.s_SubClass.GibExplosionStrength and self.s_SubClass.GibExplosionRange then
			if self.s_SubClass.GibExplosionDeltaY then
				y = y + self.s_SubClass.GibExplosionDeltaY
			end
			--[[[if debugMarek then
				DebugSphereX = x
				DebugSphereY = y
				DebugSphereZ = z
				DebugSphereRange = self.s_SubClass.GibExplosionRange
			end--]]
			self._Ax = x
			self._Ay = y
			self._Az = z

			MDL.SetRagdollMovedByExplosions(gib, false)
			self._enableMovedByExplosions = 2
		end
		
		local rcoll = self.s_SubClass.RagdollCollisionsGib

		if rcoll then
			for i,v in rcoll.Bones do
				local j = MDL.GetJointIndex(self._Entity, v[1])
				if j >= 0 then
					ENTITY.EnableCollisionsToRagdoll(self._Entity, j, rcoll.MinTime, rcoll.MinStren)
					self._raggDollPrecomputedCollData[j] = {v[2], v[3]}
				else
					--[[[if debugMarek then
						Game:Print(self._Name.." set ragdoll col. joint not found: "..v[1])
					end--]]
				end
			end
            self:ReplaceFunction("OnCollision","StdRagdollOnCollision")
		end
		if self.CustomOnGib then
			self:CustomOnGib()
		end
		self:ApplySpecular()
		return gib
	end
end

--============================================================================
function CActor:EnableRagdoll(enable,disable_po)
    if disable_po then
        ENTITY.PO_Enable(self._Entity,false)
    end

    if enable and MDL.IsRagdoll(self._Entity) then return end
    if not enable and not MDL.IsRagdoll(self._Entity) then return end

    local cr = ECollisionGroups.RagdollNonColliding
 
    if self.s_SubClass.CollidableRagdoll then
        cr = ECollisionGroups.RagdollColliding
	end

	local eg = self.enableGibWhenHPBelow
	if eg and self._enableGibWhenHPBonusHP then
		eg = eg + self._enableGibWhenHPBonusHP
	end
	if eg and (eg > self.Health or self._frozen or Game.Cheat_AlwaysGib) then
		if not self:CreateGib() then
			MDL.EnableRagdoll(self._Entity,enable,cr)
		end
	else
		MDL.EnableRagdoll(self._Entity,enable,cr)
	end
	
	local rcoll = self.s_SubClass.RagdollCollisions
	if not self._gibbed and rcoll then
		for i,v in rcoll.Bones do
			local j = MDL.GetJointIndex(self._Entity, v[1])
            if j >= 0 then
				ENTITY.EnableCollisionsToRagdoll(self._Entity, j, rcoll.MinTime, rcoll.MinStren)
                self._raggDollPrecomputedCollData[j] = {v[2], v[3]}
            else
				--[[[if debugMarek then
					Game:Print(self._Name.." set ragdoll col. joint not found: "..v[1])
				end--]]
            end
		end
        self:ReplaceFunction("OnCollision","StdRagdollOnCollision")
	end

	if not self._gibbed then
		if enable and self.s_Physics then
			local p = self.s_Physics
			-- dopiero po aktywacji moge pobrac i zmienic mase ragdolla
			if p.Mass then ENTITY.PO_SetMass(self._Entity, p.Mass) end
			if p.InertiaTensorMultiplier then self._inertiaTensorDelayedEnable = 15 end
			if p.RagdollFriction then
				MDL.SetRagdollFriction(self._Entity, p.RagdollFriction)
			end
		end
	end
	    
    --if enable and ENTITY.PO_Exist(self._Entity) then
    --    ENTITY.PO_Enable(self._Entity,false)
    if enable then
        --self.Animation = ""
        self._CurAnimLength = 99999
		self._enabledRD = true
    end
    --elseif self._HadPO then
    --    ENTITY.PO_Enable(self._Entity,true)
    --end
end


function CActor:StdRagdollOnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl, velocity_me, velocity_other)	--e.he
	local j = MDL.GetJointFromHavokBody(self._Entity, h_me)

	if self.CustomOnRagdollCollision then
		self:CustomOnRagdollCollision(x,y,z,nx,ny,nz,j,velocity_me,velocity_other)
	end
	
	if e_other and self.RagdollCollDamage then
		local obj = EntityToObject[e_other]
		if obj and obj.OnDamage and not obj._AIBrain then			--- velocity * INP.GetTimeMultiplier()
			--if debugMarek then Game:Print("RAGDOLL COLL - with obj dam") end
		    if velocity_me and velocity_other then
				if velocity_me + 2.0 > velocity_other then
					obj:OnDamage(self.RagdollCollDamage, self)
					if obj == Player and self.s_SubClass.SoundsDefinitions.damageByRagdoll then
						self:PlayRandomSound2D("damageByRagdoll")
					end
				else
					--Game:Print("$$$ no COL")
				end
			--else
				--Game:Print("$$$ ERROR: NIE MA velocity def")
				--Game.freezeUpdate = true
			end
		end
	end
	
	if j and j ~= -1 then
		if self._raggDollPrecomputedCollData[j] then
            local name
            if self._frozen then
				name = "frozenSplash"
			else
				name = self._raggDollPrecomputedCollData[j][1]
			end
			
			if name then
				self:PlaySound(name,nil,nil,nil,nil,x,y,z)
			end
       		if self._raggDollPrecomputedCollData[j][2] and not self._frozen and not self.notBleeding then
                self:BloodFX(x,y,z)		-- dodac cos zeby rozmazywalo np. uzaleznic od predkosci
            end
		end
	end
end


--============================================================================
function CActor:PO_Create(bodytype,bodyscale,collisionGroup)
    if not ENTITY.PO_Exist(self._Entity) then
		local phys = self.s_Physics
        if not bodytype then
            if phys then
                bodytype = phys.BodyType
                if phys.BodyScale then
					bodyscale = phys.BodyScale
				end
            else
                bodytype = BodyTypes.Fatter
            end
        end
        self:Synchronize()
        ENTITY.PO_Create(self._Entity, bodytype, bodyscale, collisionGroup)
        
        --if self.Friction then
		--	ENTITY.PO_SetFriction(self._Entity,self.Friction)
		--else
		--	ENTITY.PO_SetFriction(self._Entity,1.5)
		--end
        --if self.Mass then
		--	ENTITY.PO_SetMass(self._Entity, self.Mass)
		--end
        
        -- nie ustawiam tarcia poniewaz nie beda wchodzili po schodach
        -- tylko dla ragdoli w jest ustawiane tarcie na 2.0 w physics.cpp
        --ENTITY.PO_SetFriction(self._Entity, 2) -- default friction
		
        if phys then
            if phys.Mass then ENTITY.PO_SetMass(self._Entity, phys.Mass) end
		    if phys.Friction then ENTITY.PO_SetFriction(self._Entity, phys.Friction) end
			--if phys.AngularDamping then ENTITY.PO_SetAngularDamping(self._Entity, phys.AngularDamping) end
			--if phys.LinearDamping then ENTITY.PO_SetLinearDamping(self._Entity, phys.LinearDamping) end
			if phys.Restitution then ENTITY.PO_SetRestitution(self._Entity, phys.Restitution) end
		end        
        
        ENTITY.PO_SetMonsterType(self._Entity)
        if self.Pinned then
			ENTITY.PO_SetPinned(self._Entity,true)
			ENTITY.PO_Activate(self._Entity,true)
		end

--        self._HadPO = true
    end
end
--============================================================================
--function CActor:MakeProjectile(type,lifetime,mass)
--    if ENTITY.PO_Exist(self._Entity) then
--        ENTITY.MakeProjectile(self._Entity, type, lifetime, mass)
--    end
--end
--============================================================================

function CActor:RotateTo(ang)
	if not self._rotatingWithAnim then
		self._angleDest = math.mod(ang * math.pi/180, math.pi*2)
		self._isRotating = true
	end
end

function CActor:Rotate(ang)
	if not self._rotatingWithAnim then
		self._angleDest = math.mod(self.angle + ang * math.pi/180, math.pi*2)
		self._isRotating = true
	end
end


function CActor:RotateToVector(tx,ty,tz)
	--[[[if debugMarek then
		if Dist3D(tx,0,tz,self._groundx,0,self._groundz) < 0.01 then
			self._isRotating = true
			--Game.freezeUpdate = true
			--Game:Print("RTV: "..tx.." "..self._groundx)
			return
		end
	end--]]
	if not self._rotatingWithAnim then
		self._angleDest = math.atan2(tx - self._groundx, tz - self._groundz)
		self._isRotating = true
	end
end

function CActor:FlyForward(dist, ang, up, animName,disableInitialRotate, maxDist)
	local xd,yd,zd = self._groundx,self._groundy,self._groundz
	if up then
		yd = yd + up
	end
	local angle = self._angleDest	-- czy angle
	if ang then
		angle = math.mod(angle + ang * math.pi/180, math.pi * 2)
	end
	if dist < 0 then				-- do tylu
		angle = angle + math.pi
		dist = -dist
	end

	local v = Vector:New(math.sin(angle), 0, math.cos(angle))
	v:Normalize()
	return self:FlyTo(xd + v.X*dist, yd, zd + v.Z*dist,nil,animName,disableInitialRotate, maxDist)
end	

function CActor:FlyTo(destx,desty,destz, Run, animName, disableInitialRotate, maxDist)
	local x,y,z = self._groundx,self._groundy,self._groundz
	
	self._disableInitialRotate = disableInitialRotate
	local d1 = Dist3D(x,y,z,destx,desty,destz)
    if d1 < 0.04 then		-- dest to close
		return false
    end
    if self._flyWithAngle then
		self._lastDistToEnd = d1
	end
	
	self._walkMaxDist = maxDist
	self._walkTotalMove = 0

   	if self.NeverMove then
		return true
	end

    local run = Run
    if self.NeverRun then
		run = false
    end

    if self.NeverWalk then
		run = true
    end

    
	self._shouldMove = 0
	self._lastShouldMove = nil
	self._lastbutMove = nil
    self._butMove = 0
    self._lastgroundx,self._lastgroundy,self._lastgroundz = self._groundx,self._groundy,self._groundz

	self._notIsWalkingTimer = nil
    self._destx = destx
    self._desty = desty
    self._destz = destz
    self._destAngle = math.atan2(destx - x, destz - z)

	self._Speed = 1.0
	local animSpeed = 1.0

	local anm = self.s_SubClass.flyWalk
	if self._randomizedParams.FlySpeed then
		self._Speed = self._randomizedParams.FlySpeed
	else
		self._Speed = self._randomizedParams.WalkSpeed
	end
	if run then
		self._Speed = self._randomizedParams.RunSpeed
		anm = self.s_SubClass.flyRun
	end

    if animName then
        anm = animName
    end
    
	if self.s_SubClass.Animations then
		if self.s_SubClass.Animations[anm] and self.s_SubClass.Animations[anm][2] then
			self._HasMovingCurve = true
			animSpeed = self.s_SubClass.Animations[anm][1] * self._Speed
		else
			animSpeed = self.s_SubClass.Animations[anm][1]
		end
	end
	
	self:SetAnim(anm, not self._doNotLoopWalkAnim, animSpeed)
	
	if not disableInitialRotate then
		self:RotateToVector(self._destx, 0, self._destz)
	end
	self._distToEnd = Dist3D(x,y,z,self._destx,self._desty,self._destz)
	self._distStart = 0
	self._forceMove = true

	self._state = "WALKING"			-- narazie
	self._isWalking = true
	self._flying = true
	return true
end

function CActor:WalkForward(dist, run, ang, maxDist, animName, useOnlyWP, walkWithAngle, moveBackward)
	local xd,yd,zd = self._groundx,self._groundy,self._groundz
	local angle = self._angleDest	-- czy angle
	if ang then
		angle = math.mod(angle + ang * math.pi/180, math.pi * 2)
	end
	if moveBackward then
		angle = angle + math.pi
	end
	local v = Vector:New(math.sin(angle), 0, math.cos(angle))
	v:Normalize()
	if self.flyingMode then
		return self:FlyTo(xd + v.X*dist, yd, zd + v.Z*dist, run)
	end
	return self:WalkTo(xd + v.X*dist, yd, zd + v.Z*dist, run, maxDist, animName, useOnlyWP, walkWithAngle, moveBackward)
end

function CActor:WalkTo(destx,desty,destz, Run, maxDist, animName, useOnlyWP, walkWithAngle, moveBackward)
	self._walkWithAngle = walkWithAngle
	self._state = "PREWALK"
	self._isWalking = nil
	
	if self.NeverMove then
		return true
	end

	if self.flyingMode then
		return self:FlyTo(destx,desty,destz, Run)
	end

	local x,y,z = self._groundx,self._groundy,self._groundz
	
	local d1 = Dist3D(x,y,z,destx,desty,destz)
    if d1 < 0.04 then		-- dest to close
		--if debugMarek then Game:Print("Walk too close") end
		return false
    end
    
    if debugMarek then
		DEBUG1, DEBUG2, DEBUG3, DEBUG4, DEBUG5, DEBUG6 = x,y,z,destx,desty,destz
	end

	--if debugMarek then Game:Print("Walk distance = "..d1) end
	self._preferWP = useOnlyWP
	
	if not self._Path then    
		self._Path = PATH.Create()
	end

    self._walkMaxDist = maxDist

    local run = Run
    if self.NeverRun then
		run = false
    end

    if self.NeverWalk then
		run = true
    end

    self._walkTotalMove = 0
	self._shouldMove = 0
	self._lastShouldMove = nil
	self._lastbutMove = nil
    self._butMove = 0
    self._lastgroundx,self._lastgroundy,self._lastgroundz = x,y,z

	

	if not self.doNotUseWP then
		PATH.GetShortest(self._Path,x,y,z,destx,desty,destz,self.s_SubClass.WPminDist,self.s_SubClass.WPmaxDist)
	end
    self._destx = destx
    self._desty = desty
    self._destz = destz
    self._destAngle = math.atan2(destx - x, destz - z)

	local mode = "walk"
    if run then
		mode = "run"
    end
   
	self._Speed = 1.0
	local animSpeed = 1.0

	if animName then
		mode = animName
	end

	if mode == "run" and self._randomizedParams.RunSpeed then
		self._Speed = self._randomizedParams.RunSpeed
	else
		if mode == "walk" and self._randomizedParams.WalkSpeed then
			self._Speed = self._randomizedParams.WalkSpeed
		end
	end

	if self._forceWalkAnim then
		mode = self._forceWalkAnim
	end

	if self.Animation ~= mode then
		-- narazie tu
		if self.s_SubClass.run and mode == "run" then
			if math.random(100) < 20 or not self.s_SubClass.Animations[mode] then			-- losowanie roznych animacji "run"
				self._runAltAnim = self.s_SubClass.run[math.random(1, table.getn(self.s_SubClass.run))]
			end
			if self._runAltAnim then
				mode = self._runAltAnim
			end
		else
			if self.s_SubClass.walk and mode == "walk" then
				if math.random(100) < 20 or not self.s_SubClass.Animations[mode] then			-- losowanie roznych animacji "run"
					self._runAltAnim = self.s_SubClass.walk[math.random(1, table.getn(self.s_SubClass.walk))]
				end
				if self._runAltAnim then
					mode = self._runAltAnim
				end
			end
		end
	end

	if self.s_SubClass.Animations[mode] then
		if self.s_SubClass.Animations[mode][2] then
			self._HasMovingCurve = true
			animSpeed = self.s_SubClass.Animations[mode][1] * self._Speed
		else
			animSpeed = self.s_SubClass.Animations[mode][1]
		end
	else
		Game:Print(self._Name.." WALK TO, anim not found? "..mode)
		Game.freezeUpdate = true
	end
	
	self._rotatingWithAnim = false
	self._moveBackward = moveBackward
	
	if not self.doNotUseWP and PATH.IsFinished(self._Path) == 0 then
        self._forceMove = nil
        self:NextPoint()
    else
    	if self.onlyWPmove then			-- first is global, second is local
			--if debugMarek then Game:Print(self._Name.." walk cancled, only wp move...") end
			return false
		end
		if not self._disableRotatingWhileWalking then
			self:RotateToVector(self._destx, 0, self._destz)
            if self._moveBackward then
				self._angleDest = self._angleDest + math.pi
            end
		end
		
		if self._preferWP then
			local v = Vector:New(self._destx - self._groundx, 0, self._destz - self._groundz)	-- sprawdzanie lekko do przodu
			v:Normalize()
			if not self:CheckYLevel(self._destx, self._desty, self._destz)
				and not self:CheckYLevel(self._destx + v.X * self._checkRadius, self._desty, self._destz + v.Z * self._checkRadius) then

				self._forceMove = false
				if self._AIBrain then
		   			self._lastCantMoveTime = self._AIBrain._currentTime
		   		end
		   		--if debugMarek then Game:Print(self._Name.." prefer wp...walk canceled") end
				--Game:Print("CHECK_Y #2")
				return false
			else
				--Game:Print("CHECK_Y #2 OK")
			end
		end
		self._distToEnd = Dist2D(x,z,self._destx,self._destz)
		self._distStart = 0
		self._forceMove = true

    end
	if self.Animation ~= mode then
		if self._moveBackward then
			animSpeed = -animSpeed
			--Game:Print(self._Name.." set anim speed "..animSpeed)
		end
		self:SetAnim(mode, not self._doNotLoopWalkAnim, animSpeed)
		self._walkAnimSpeedMax = animSpeed
		if not self._walkAnimSpeed then
			self._walkAnimSpeed = 0.1 * self._walkAnimSpeedMax
		end
		if self._walkAnimSpeed > self._walkAnimSpeedMax then
			self._walkAnimSpeed = self._walkAnimSpeedMax
		end
	end
	self._isWalking = true
	self._notIsWalkingTimer = nil
	self._state = "WALKING"
	--if debugMarek then Game:Print("walk "..self._AIBrain._currentTime.." dist = "..d1.." "..self._distStart.." "..self._distToEnd) end
	return true
end

function CActor:SetIdle(once)
	self:Stop()	
	local loop = true
	if once then
		loop = once
	end
	
	if debugAnim then Game:Print(")"..GetCallStackInfo(2)) end
	
	if not self.s_SubClass.Animations.idle or not self:SetAnim("idle", loop) then
		if self.s_SubClass.Ambients then
			--local animName = self.s_SubClass.Ambients[math.random(1,table.getn(self.s_SubClass.Ambients))]
			local animName = self.s_SubClass.Ambients[1]
			if self.s_SubClass.Animations[animName] then
				return self:SetAnim(animName, loop)
			end
		end
		return false
	else
		return true
	end
end

function CActor:CheckYLevel(x,y,z, debug)
--[[	if self.debugCheck then
		self.debugCheck = nil
	else
		self.debugCheck = 1
	end--]]
	if not ENTITY.PO_Exist(self._Entity) then
		return true
	end
	local b,d = WORLD.LineTraceFixedGeom(x, y + self._SphereSize * 3, z, x, y - self._SphereSize * 3, z)
	--local b,d,debugx,debugy,debugz = WORLD.LineTraceFixedGeom(x, y + self._SphereSize * 3, z, x, y - self._SphereSize * 3, z)
	if d and d > self._SphereSize*1.5 and d < self._SphereSize * 4.5 then
		--[[if debug then
			if self.debugCheck then
				self.debugCheckY1 = x
				self.debugCheckY2 = y + self._SphereSize * 3
				self.debugCheckY3 = z
				self.debugCheckY4 = debugx
				self.debugCheckY5 = debugy
				self.debugCheckY6 = debugz
			else
				self.d1ebugCheckY1 = x
				self.d1ebugCheckY2 = y + self._SphereSize * 3
				self.d1ebugCheckY3 = z
				self.d1ebugCheckY4 = debugx
				self.d1ebugCheckY5 = debugy
				self.d1ebugCheckY6 = debugz
			end
		end--]]
		return true
	else
		--[[if debug then
			if self.debugCheck then
				self.debugCheckY1 = x
				self.debugCheckY2 = y + self._SphereSize * 3
				self.debugCheckY3 = z
				self.debugCheckY4 = x
				self.debugCheckY5 = y - self._SphereSize * 3
				self.debugCheckY6 = z
			else
				self.d1ebugCheckY1 = x
				self.d1ebugCheckY2 = y + self._SphereSize * 3
				self.d1ebugCheckY3 = z
				self.d1ebugCheckY4 = x
				self.d1ebugCheckY5 = y - self._SphereSize * 3
				self.d1ebugCheckY6 = z
			end
		end--]]
		return false
	end
end


function CActor:NextPoint()    
    local x,y,z = self._groundx,self._groundy,self._groundz
    if PATH.IsFinished(self._Path) == 1 then				-- nie ma wiecej WP
		self._distToEnd = Dist2D(x,z,self._destx,self._destz)
		self._distStart = 0
		if not self._disableRotatingWhileWalking then
			self:RotateToVector(self._destx, 0, self._destz)
		end
        if self._moveBackward then
			self._angleDest = self._angleDest + math.pi
		end
   		if self.onlyWPmove then
   			self._lastCantMoveTime = self._AIBrain._currentTime
   			self._isWalking = nil
			return false
		else
			if self._preferWP then
				local v = Vector:New(self._destx - self._groundx, 0, self._destz - self._groundz)	-- sprawdzanie lekko do przodu
				v:Normalize()
				if not self:CheckYLevel(self._destx, self._desty, self._destz) and not self:CheckYLevel(self._destx + v.X * self._checkRadius, self._desty, self._destz + v.Z * self._checkRadius) then
					self._forceMove = false
					if self._AIBrain then
		   				self._lastCantMoveTime = self._AIBrain._currentTime
		   			end
   					self._isWalking = nil
					--Game:Print("CHECK_Y #1")
					return false
				else
					--Game:Print("CHECK_Y #1 OK")
				end
			end
			self._forceMove = true
		end
    else
        local dx,dy,dz = PATH.GetNextPoint(self._Path)
        local l = Dist3D(x,y,z,dx,dy,dz)
        if PATH.IsFinished(self._Path) == 1 then			-- nie ma wiecej WP
			local dist = Dist3D(x,y,z,self._destx,self._desty,self._destz)
			if (dist < l * 1.3) then						-- cel prawie tak blisko jak ostatni WP
				if not self.onlyWPmove then
					if not self._disableRotatingWhileWalking then
						self:RotateToVector(self._destx, 0, self._destz)
					end
					if self._moveBackward then
						self._angleDest = self._angleDest + math.pi
					end

					if not self._preferWP then
						--[[if self._displacement and self._displacement ~= 0 and self._AIBrain._seeEnemy then
							local v = Vector:New(z - self._destz, 0, self._destx - x)		-- na bok wzgl. patrzenia potwora
							v:Normalize()
							local aiParams = self.AiParams
		
							local range = self._displacement
							local limit = (dist - aiParams.attackRange) * 0.5
							if limit < 0 then
								limit = 0
							end
							
							if math.abs(range) > limit then
								range = limit
								if self._displacement < 0 then
									range = -limit
								end
							end

							--if debugDisplace then Game:Print(self._Name.." walkto displace "..range.." "..limit.." dist: "..dist) end

							local dxx = self._destx + v.X * range
							local dzz = self._destz + v.Z * range

							local dxxForTest = dx + v.X * (range + self._SphereSize)
							local dzzForTest = dz + v.Z * (range + self._SphereSize)
							local b,d,x,y,z = WORLD.LineTraceFixedGeom(dxxForTest, dy + self._SphereSize * 3, dzzForTest, dxxForTest, dy - self._SphereSize * 3, dzzForTest)
							--self.yaadebug1,self.yaadebug2,self.yaadebug3,self.yaadebug4,self.yaadebug5,self.yaadebug6 = dxxForTest, dy + self._SphereSize * 3, dzzForTest, dxxForTest, dy - self._SphereSize * 3, dzzForTest
							if d and d > self._SphereSize*1.5 and d < self._SphereSize * 4.5 then	

								local ok2 = false
								--self.yadebug1,self.yadebug2,self.yadebug3,self.yadebug4,self.yadebug5,self.yadebug6 = dx, dy + self._SphereSize * 3, dz, x,y,z
								local b,d,d1,d2,d3 = WORLD.LineTraceFixedGeom(dx, dy + self._SphereSize * 3, dz, x,y,z)
								local len = Dist3D(x,y,z, dx, dy + self._SphereSize * 3, dz)
								if not d or (d > len * 0.9) then
									ok2 = true
								end

								if ok2 then
									self._destx = dxx
									self._destz = dzz
									--Game:Print("@@displace OK1")
								--else
									--Game:Print("@@displace FAILED1")
								end

							else
								--if d then
									--Game:Print("@@displace FAILED1 "..d)
								--else
									--Game:Print("@@displace FAILED1a")
								--end
							end
						end--]]
						self._forceMove = true
						self._distToEnd = dist
						self._distStart = 0
						return true
					else
						local v = Vector:New(self._destx - self._groundx, 0, self._destz - self._groundz)	-- sprawdzanie lekko do przodu
						v:Normalize()
						if self:CheckYLevel(self._destx, self._desty, self._destz) and self:CheckYLevel(self._destx + v.X * self._checkRadius, self._desty, self._destz + v.Z * self._checkRadius) then
							self._forceMove = true
							self._distToEnd = dist
							self._distStart = 0
							--Game:Print("CHECK_Y #3 OK ")
							return true
						--else
							--Game:Print("CHECK_Y #3")
						end
					end
				end
			end
		else			-- sa jeszcze WP, to displace
		    if self._displacement and math.abs(self._displacement) > 0.15 and self._AIBrain and self._AIBrain._seeEnemy then
				local dist = Dist2D(x,z,self._destx,self._destz)
                local aiParams = self.AiParams
				local v = Vector:New(z - self._destz, 0, self._destx - x)
				v:Normalize()

				local range = self._displacement
				local limit = (dist - aiParams.attackRange) * 0.5
				if limit < 0 then
					limit = 0
				end
				
				if math.abs(range) > limit then
					--if debugMarek then
					--	Game:Print(self._Name.." walkto WP displace limit reached "..range.." "..limit)
					--end
					range = limit
					if self._displacement < 0 then
						range = -limit
					end
				end

				--if debugDisplace then 
				--	Game:Print(self._Name.." walkto WP displace "..range.." "..limit.." dist: "..dist)
				--end

				local dxx = dx + v.X * range
				local dzz = dz + v.Z * range

				local ok3 = true
				-- trace z wyliczonego WP do miejsca z displace
				
			    --ENTITY.RemoveRagdollFromIntersectionSolver(self._Entity)		-- powinno byc remove all

				--if debugDisplace then
				--	self.yaaaaadebug1,self.yaaaaadebug2,self.yaaaaadebug3,self.yaaaaadebug4,self.yaaaaadebug5,self.yaaaaadebug6 = self._groundx,self._groundy + 0.1,self._groundz, dx,dy+0.1,dz
				--	self.yadebug1,self.yadebug2,self.yadebug3,self.yadebug4,self.yadebug5,self.yadebug6 = dxx, dy+0.5, dzz, dx,dy+0.5,dz
				--	DEB1 = dxx
				--	DEB2 = dy + 0.5
				--	DEB3 = dzz
				--end

				local b,d = WORLD.LineTraceFixedGeom(dx,dy+0.5,dz,dxx, dy+0.5, dzz)

				if b then
					--if debugDisplace then 
					--	Game:Print(self._Name.." displace col "..d.." range = "..range.." "..self._SphereSize)
					--end
					if d > self._SphereSize * 2.0 then
						local sign = 1
						if self._displacement < 0 then
							sign = -1
						end
						dxx = dx + v.X * (d - self._SphereSize*2.0) * sign
						dzz = dz + v.Z * (d - self._SphereSize*2.0) * sign
						range = (d - self._SphereSize*2.0) * sign
						--if self._displacement < 0 then
						--	range = -range
						--end
						--if debugDisplace then 
						--	Game:Print("NEW range = "..range)
						--end
					else
						ok3 = false
						----Game.freezeUpdate = true
						--if debugDisplace then 
						--	Game:Print(self._Name.." displace col, za blisko")
						--end
					end
				end

--				if debugDisplace then
--					DEB4 = dxx
--					DEB5 = dy + 0.5
--					DEB6 = dzz
--				end
				
				if ok3 then
					local ok4 = true 
--					if debugDisplace then
--						self.yzdebug1,self.yzdebug2,self.yzdebug3,self.yzdebug4,self.yzdebug5,self.yzdebug6 = x,y+0.5,z,dxx, dy+0.5, dzz
--					end

					-- trace do wyliczonego miescja od aktora
					local b,d = WORLD.LineTraceFixedGeom(x,y+0.5,z,dxx, dy+0.5, dzz)
					if b then
--						if debugDisplace then
--							Game:Print(self._Name.." jest kolizja do celu!")
--						end
						ok4 = false
					else
--						if debugDisplace then
--							Game:Print(self._Name.." nie ma kolizja do celu")
--						end
						
					end

--					if debugDisplace then
--						self.yaaadebug1,self.yaaadebug2,self.yaaadebug3,self.yaaadebug4,self.yaaadebug5,self.yaaadebug6 = dxx, dy+0.5, dzz, self._destx,self._desty+0.5,self._destz
--					end
					-- trace z wyliczonego miejsca do celu (widocznosc)
					if ok4 then
						local b,d = WORLD.LineTraceFixedGeom(dxx, dy+0.5, dzz, self._destx,self._desty+0.5,self._destz)
						if b then
							ok4 = false
--							if debugDisplace then 
--								Game:Print(self._Name.." brak widocznosci z tego miejsca")
--							end
						--else
						--	Game:Print(self._Name.." OK. jest widocznosc")
						end
					end
					
					if ok4 then
						local zasieg = range + self._SphereSize
						if range < 0 then
							zasieg = range - self._SphereSize
						end
						local dxxForTest = dx + v.X * zasieg
						local dzzForTest = dz + v.Z * zasieg
						-- sprawdzanie roznicy wysokosci
						local b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(dxxForTest, dy + self._SphereSize * 3, dzzForTest, dxxForTest, dy - self._SphereSize * 3, dzzForTest)
--						if debugDisplace then
--							self.yaadebug1,self.yaadebug2,self.yaadebug3,self.yaadebug4,self.yaadebug5,self.yaadebug6 = dxxForTest, dy + self._SphereSize * 3, dzzForTest, dxxForTest, dy - self._SphereSize * 3, dzzForTest
--						end
						if e then
							local obj = EntityToObject[e]
							if obj then
								--if debugMarek then
								--	Game:Print(self._Name.." DISPLACE OBJ COL WITH "..obj._Name.." "..obj._Class)
									--Game.freezeUpdate = true
								--end
								if obj._Class == "CItem" then
									d = nil
								end
							end
						end
						if d and d > self._SphereSize*1.5 and d < self._SphereSize * 4.5 then	
							local ok2 = false
--							if debugDisplace then 
--								self.yaaaadebug1,self.yaaaadebug2,self.yaaaadebug3,self.yaaaadebug4,self.yaaaadebug5,self.yaaaadebug6 = dx, dy + self._SphereSize * 3, dz, x,y,z
--							end
							local b,d = WORLD.LineTraceFixedGeom(dx, dy + self._SphereSize * 3, dz, x,y,z)
							local len = Dist3D(x,y,z, dx, dy + self._SphereSize * 3, dz)
							if not d or (d > len * 0.9) then
								ok2 = true
							end

							if ok2 then
								dx = dxx
								dz = dzz
								--Game:Print("displace OK2")
							else
--								if debugDisplace then
--									Game:Print("displace FAILED2")
--								end
							end

						else
							--if d then
								--Game:Print("displace FAILED2 "..d)
							--else
								--Game:Print("displace FAILED2")
							--end
--							if debugDisplace then
--								Game:Print("displace FAILED3")
--							end
						end
					end
				end
				--ENTITY.AddRagdollToIntersectionSolver(self._Entity)
			end
        end
   
        if l > 0.01 then        
            self._Point:Set(dx,dy,dz)
            if not self._disableRotatingWhileWalking then
				self:RotateToVector(dx, 0, dz)
			end
            if self._moveBackward then
				self._angleDest = self._angleDest + math.pi
            end
            if debugMarek then
				self._pdebugdx2 = self._debugdx2		--- previous
				self._pdebugdy2 = self._debugdy2
				self._pdebugdz2 = self._debugdz2

				self._pdebugdx3 = self._debugdx3					-- act. WP
				self._pdebugdy3 = self._debugdy3
				self._pdebugdz3 = self._debugdz3


				self._debugdx2 = dx					-- act. WP
				self._debugdy2 = dy
				self._debugdz2 = dz

				self._debugdx3 = x					-- act. WP
				self._debugdy3 = y
				self._debugdz3 = z
			end

			self._distToEnd = Dist2D(dx, dz, x, z)
			self._distStart = 0
	    else
            self._isWalking = nil
            --Game:Print("?????? finished walking ??????")
            return false
        end
    end
    return true 
end

function CActor:Stop()
	self._state = "IDLE"
	self._isWalking = nil
	self._flying = nil
	self._lastPitch = nil
	self._notIsWalkingTimer =  self._notIsWalkingTimerAmount
	--ENTITY.PO_Move(self._Entity,0,0,0)
	--if debugMarek then Game:Print("stop") end
end

function CActor:FullStop()
	self:Stop()
	ENTITY.PO_Move(self._Entity,0,0,0)
	self._angleDest = self.angle
	self._isRotating = false
	self._NEXTangleDestAnim = nil
end


function CActor:UpdateRotate(delta)
	local ad = self._distToAngle

    --local md = math.abs(ad) -- wygaszanie
    --if md > 1 then md = 1 end   
    --if md < 0.2 then md = 0.2 end   

    local rs = 0
   
    if self._randomizedParams.RotateSpeed then
        rs = self._randomizedParams.RotateSpeed * delta * 30*3.1415/180		--	 * md
    end

	local maxAcc = 0.5
	if rs > self._lastVel + maxAcc*delta then		-- ograniczenie przyspieszenia katowego
		rs = (self._lastVel/delta + maxAcc)*delta
	end
	self._lastVel = rs

		
    if (ad > 0) then
		if ad < rs then
			self.angle = self._angleDest
		else
			self.angle = math.mod(self.angle + rs, math.pi*2)
		end
    else
		rs = -rs
		if ad > rs then
			self.angle = self._angleDest
		else
			self.angle = math.mod(self.angle + rs, math.pi*2)			
		end
    end

    ENTITY.SetOrientation(self._Entity,self.angle)
end

--============================================================================
function CActor:GetJointPos(name)
	if name then
		local idx  = MDL.GetJointIndex(self._Entity,name)
		if idx<0 then
			Game:Print(self.Model.." JOINT "..name.." not found")
			return ENTITY.GetWorldPosition(self._Entity)
		end
		return MDL.GetJointPos(self._Entity,idx)
	else
		Game:Print("!!!!!!! CActor:GetJointPos joint == nil")
		if debugMarek then Game:Print("))"..GetCallStackInfo(2)) end
		return ENTITY.GetWorldPosition(self._Entity)
	end
end        
--============================================================================
function CActor:OnDamage(damage, obj, type, x, y, z, nx, ny, nz, he,msg)			-- +pos
	if self.Immortal then return end
	if not self._died then
		if Game.Cheat_WeakEnemies then self.Health = 1 end -- cheat
		if Game.WeakEnemies and not self.IsBoss then self.Health = 1 end -- karta

        if self._frozen then damage = self.Health * 3 end

		if obj == Player then
			damage = damage * Game.DamageFactor
			if Game.StealHealth then
				local health_add = damage * 0.025
				Player.Health = Player.Health + health_add
				if Player.Health > 250 then Player.Health = 250 end
			end
		end
		
		if Game.ConfuseEnemies and obj and obj._AIBrain and obj._AIBrain._lockedEnemy == self then
			--Game:Print(self._Name.." ConfuseEnemies damage * 4 from "..obj._Name)
			damage = damage * 4
		end

        if self.CustomOnDamage then
			local skip, dmg = self:CustomOnDamage(he,x,y,z,obj, damage, type,nx,ny,nz)
			if skip then
				if type ~= AttackTypes.OutOfLevel then
					return				-- damage canceled
				end
			end
			if dmg then
				Game:Print(self._Name.." nowy damage = "..damage.." "..dmg)
				damage = dmg
			end
        end
        --if he then
        --    local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        --    if j then Game:Print(MDL.GetJointName(e,j)) end
        --end
        
        --ENTITY.PO_SetFlying(self._Entity,false)
		self.Health =  self.Health - damage
		if self._AIBrain and self.AIenabled then
			self._AIBrain._lastDamageTime = self._AIBrain._currentTime
			self._AIBrain.r_lastDamageWho = obj
		end

		if self.Health <= 0 then
			if self.CustomOnDeath then
				if self:CustomOnDeath(obj) then
					if type ~= AttackTypes.OutOfLevel then
						return			-- death canceled
					end
				end
			end

			if self._trail then
				ENTITY.Release(self._trail)
				self._trail = nil
			end
			self:EndTrailSword()
			if self.EndTrailSword2 then
				self:EndTrailSword2()
			end

			if self._objTakenToThrow then
				ENTITY.PO_Enable(self._objTakenToThrow._Entity,true)
				self._objTakenToThrow = nil
			end
			
			self:StopLastSound()
			self:StopSoundHitBinded()
			
			if self._proc then
				GObjects:ToKill(self._proc)
				self._proc = nil
			end
	        if self._procBind then
				-- czy trzeba odbindowac?
				ENTITY.Release(self._procBind._targetEntity)
				GObjects:ToKill(self._procBind)
				self._procBind = nil
			end
			if self._fx then
				PARTICLE.Die(self._fx)
				self._fx = nil
			end
			self._sndHitId = nil

            if not self.NotCountable and not self._died then 
                Game.BodyCountTotal = Game.BodyCountTotal + 1
                --Game.all[self.Model] = Game.all[self.Model] - 1
				for i,v in Actors do
					if v.Model == "preacher" and v.AiParams.immortalBodiesCounter and v.AiParams.immortalBodiesCounter >= 0 then
						v:SomeoneDied(self)
					end
                end
                if Game.IsDemon then
					Game.KilledInDemonMode = Game.KilledInDemonMode + 1
				end
            end
			self._died = true
			self._diedByAttackType = type
	        if self._pfxWhenFrozen then
				for i,v in self._pfxWhenFrozen do
					PARTICLE.Die(v)
				end
				self._pfxWhenFrozen = nil
	        end

			           
			self._deathTimer = self.DeathTimer
            if self._deathTimer > 10 then
                self._deathTimer = self._deathTimer * FRand(1.0, 1.2)
            end
			if not self._ToKill then
				self:Stop()
				self:EnableRagdoll(true,true)
				if self.s_SubClass.SoundsDefinitions.death and not self._disableDeathSounds then
					self:BindRandomSound("death",nil,nil, self:GetAnyJoint())
				end
			end
			if type == AttackTypes.Electro then
				self:Electrize()
			end

			self.Health = 0
			if self.CustomOnDeathAfterRagdoll then
				self:CustomOnDeathAfterRagdoll()
			end
		else
			--if obj then
			--	Game:Print(self._Name.." dostal < "..obj._Name)
			--end
			if Tweak.MonsterCanAttackAnotherMonsterChance and not self.disableFreeze and self._AIBrain then
				if debugMarek then
					if obj and not obj.Health then
						Game.freezeUpdate = true
						Game:Print(obj._Name.." OBIEKT BEZ HEALT")
					end
				end
				if obj and not Game.ConfuseEnemies and obj._Class == "CActor" and obj.Health and obj.Health > 0 and obj._AIBrain and not obj.disableFreeze and
					not obj.NotCountable and obj.AIenabled and self._AIBrain and not self._AIBrain._confuseEnemy and obj ~= self then
					local dist = Dist3D(self._groundx,self._groundy,self._groundz,obj._groundx,obj._groundy,obj._groundz)
					--Game:Print(self._Name.." dostal <<< od "..obj._Name.." "..dist)
					if not self.forceMonsterCanAttackAnotherMonsterChance or (self.forceMonsterCanAttackAnotherMonsterChance and FRand(0.0, 1.0) < self.forceMonsterCanAttackAnotherMonsterChance) then
						if FRand(0.0, 1.0) < Tweak.MonsterCanAttackAnotherMonsterChance then
							--Game:Print(self._Name.." ATAKUJE >>> "..obj._Name)
							local brain = self._AIBrain
							brain._confuseEnemyTimer = 30
							brain._confuseEnemy = obj
							brain._forceUpdateVisibility = true
							brain._enemyLastSeenPoint.X = obj._groundx
							brain._enemyLastSeenPoint.Y = obj._groundy
							brain._enemyLastSeenPoint.Z = obj._groundz
							self:Stop()
							--Game.freezeUpdate = true
						end
					end
				end
			end
			
			if self._AIBrain then
				self._state = "HIT"
				if obj then
					self._AIBrain._lastHitByEnemyPos = obj.Pos
				else
					if x and y and z then
						self._AIBrain._lastHitByEnemyPos = Vector:New(x,y,z)
					end
				end
				self._AIBrain._lastHitByEnemyType = type
				self._AIBrain._lastHitByEnemyTime = self._AIBrain._currentTime
				self._AIBrain._lastHitAmount = damage
			end

			local cantDo = self._hitDelay
			if self._hitDelay then
				if self._hitDelay <= 0 then
					cantDo = false
				end
			else
				self._lastHitAnim = nil
			end
			if not cantDo then
				if self.s_SubClass.SoundsDefinitions.hurt then
					if not self._hitDelaySND or (self._hitDelaySND and self._hitDelaySND + math.random(8,12) < Game.currentTime) then
						--self:PlayRandomSound3D(self.s_SubClass.Sounds.hurt, 40, 70)
						self:PlaySoundHit("hurt")
						self._hitDelaySND = Game.currentTime
					end
				end

				if self.CustomOnHit then
					self:CustomOnHit(damage)
				end

				if self.s_SubClass.Hits and not self._disableHits then
					local animName -- = self._lastHitAnim
					--if not animName then
						animName = self.s_SubClass.Hits[math.random(1,table.getn(self.s_SubClass.Hits))]
					--end
					
					if not self.AIenabled and self._isAnimating then
						self._animationBeforeHit = self.Animation
					end
					if self:ForceAnim(animName, false) then
						self._lastHitAnim = animName
						self._hitDelay = self.minimumTimeBetweenHitAnimation
						if not self._hitDelay then
							self._hitDelay = 4
						end
						if self.AIenabled then
							self:Stop()
						else
							self._hitDelay = 99999	-- az do zakonczenia animacji
						end
					end
				end
			end
        end
    else
		if type and not self._gibbed then
			self._HealthAfterDeath = self._HealthAfterDeath - damage
			--Game:Print(">>>explosion "..damage.." "..type)
			if self.enableGibWhenHPBelow and (type == AttackTypes.Explosion or type == AttackTypes.Rocket or type == AttackTypes.Grenade or type == AttackTypes.PainkillerRotor) then
				if self._HealthAfterDeath < self.enableGibWhenHPBelow then
					self:CreateGib()
					if self._gibbed then -- dodac tylko w powietrzu
						local i = self:GetAnyJoint(true)
						local x,y,z = MDL.GetJointPos(self._Entity, i)
						local b = WORLD.LineTraceFixedGeom(x,y,z,x,y - 1.5,z)
						if not b then
							local treasures = {"RingR", "RingG", "RingB"}
							local name = treasures[math.random(1,3)]
							local obj2 = GObjects:Add(TempObjName(),CloneTemplate(name..".CItem"))
							obj2.Pos.X = x + FRand(-0.2,0.2)
							obj2.Pos.Y = y
							obj2.Pos.Z = z + FRand(-0.2,0.2)
							obj2.Rot:FromEuler(FRand(-3.14,3.14), FRand(-3.14,3.14), FRand(-3.14,3.14))
							obj2:Apply()
							obj2:Synchronize()
						end
					end
				end
			end
		else
			--Game:Print("<<<explosion "..damage.." no type")
		end
	end
    if x and not self.notBleeding then
		if he and self.s_SubClass.notBleedingJoints then
	        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
	        local jName = MDL.GetJointName(e,j)
	        if self.s_SubClass.notBleedingJoints[jName] then
				--Game:Print(self._Name.." NOT BLEEDING jName : "..jName)
				return
			else
				--Game:Print(self._Name.." bleeding jName : "..jName)
			end
		end

		if self._lastBlood + 2 < Game.currentTime then
			if msg == 'EXPLOSION' then
				x = self.Pos.X
				y = self.Pos.Y
				z = self.Pos.Z
			end
			self._lastBlood = Game.currentTime
			self:BloodFX(x,y,z,nx,ny,nz)
		end
    end
end

function CActor:Electrize()
	if self._enabledRD and not self._gibbed and not self.notBleeding then
		if self._ragdollShockTime then
			--Game:Print("electrize st already set")
			if self._ragdollShockTime < 0 then
				self._shakeStr = nil
				self._ragdollShockTime = 30
				self._shakeJoint = self:GetAnyJoint()
			end
		else
			--Game:Print("electrize st not set")
			local t = Templates["DriverElectro.CWeapon"].s_SubClass
			local i = self:GetAnyJoint()
			if i >= 0 and not MDL.IsPinned(self._Entity) then
				
   				MDL.SetRagdollLinearDamping(self._Entity, 2.0)
				MDL.SetRagdollAngularDamping(self._Entity, 2.0)

				local x,y,z = MDL.GetVelocitiesFromJoint(self._Entity, i)
				if not z then
					return
				end
				self._shakeJoint = i
				self._ragdollShockTime = t.ragdollShockTime * 30
				local x1,y1,z1 = MDL.GetJointPos(self._Entity, i)
			
				local v = Vector:New(x1 - PX, y1 - PY, z1 - PZ)
				v:Normalize()
				local rnd2 = t.impulseAfterDeathY
				local rnd1 = v.X * t.impulseAfterDeathXZ
				local rnd3 = v.Z * t.impulseAfterDeathXZ
				MDL.ApplyVelocitiesToJoint(self._Entity, i, rnd1 + x, rnd2 + y, rnd3 + z)
			--else
				--Game:Print(self._Name.." elector: nie ma root")
			end
		end
	end
end

function CActor:ThrowHeart()
    if Game.Difficulty == 3 then return end
	if self.throwHeart then
		local obj
		if self.throwHeart == "red" then
			obj = GObjects:Add(TempObjName(),CloneTemplate("Energyred.CItem"))
		else
			obj = GObjects:Add(TempObjName(),CloneTemplate("Energy.CItem"))
		end

		local j = self.s_SubClass.ragdollJoint
		if not j then
			j = "root"
		end
		obj.Pos:Set(self:GetJointPos(j))
		obj.Pos.Y = obj.Pos.Y + 0.9

		obj:Apply()
	end
	--[[if self.throwHeart then
		local obj = GObjects:Add(TempObjName(),CloneTemplate("moneta_zlota.CItem"))
		if self.s_SubClass.ragdollJoint then
			obj._groundx, obj._groundy, obj._groundz = self:GetJointPos(self.s_SubClass.ragdollJoint)
			obj._groundy = self._groundy + 1.0
		else
			obj._groundx = self._groundx
			obj._groundy = self._groundy + 1.5
			obj._groundz = self._groundz
		end
		
		obj.Pos.X = obj._groundx
		obj.Pos.Y = obj._groundy
		obj.Pos.Z = obj._groundz
		obj:Apply()
		obj:Synchronize()
	end--]]
end

--============================================================================
function CActor:OnDeathUpdate()
	if self.CustomOnDeathUpdate then
		self:CustomOnDeathUpdate()
	end
	if not self._gibbed and self._ragdollShockTime then
		self._ragdollShockTime = self._ragdollShockTime - 1
		if self._ragdollShockTime > 0 then
			if self.s_SubClass.DeathJoints then
				local t = self.s_SubClass.DeathJoints
				--t = {"root","k_szyja","r_p_bark","k_zebra","r_l_bark"}
				--[[
				local rndJoint = math.random(1,table.getn(t))
				local i = MDL.GetJointIndex(self._Entity, t[rndJoint])
				local amount = 30
				local rnd1 = FRand(0.01, 0.06)
				if math.random(100) < 50 then
					rnd1 = -rnd1
				end
				local rnd2 = FRand(0.01, 0.06)
				if math.random(100) < 50 then
					rnd2 = -rnd2
				end
				local rnd3 = FRand(0.01, 0.06)
				if math.random(100) < 50 then
					rnd3 = -rnd3
				end

				if i >= 0 then
					MDL.ApplyVelocitiesToJoint(self._Entity, i, rnd1*amount, rnd2*amount, rnd3*amount)
				end
				--]]

				local t2 = Templates["DriverElectro.CWeapon"].s_SubClass
				if not self._shakeStr then
					self._shakeStr = 0.01
					self._shakeStrUp = true
					--if debugMarek then Game:Print("self._shakeJoint = "..self._shakeJoint) end
					self._electroFX = self:BindFX(t2.ragdoll_fx, t2.ragdoll_fxscale, self._shakeJoint)
					self._electroSound = self:BindSound(t2.ragdoll_sound,8,20, true, self._shakeJoint)
					--[[if debugMarek then
						local m = ENTITY.PO_GetMass(self._Entity)
						Game:Print("MASS = "..m)
					end--]]
				else
					if self._shakeStrUp then
						self._shakeStr = self._shakeStr + 0.05
						if self._shakeStr > 0.04 then
							self._shakeStrUp = false
						end
					else
						self._shakeStr = self._shakeStr - 0.05
						if self._shakeStr < -0.04 then
							self._shakeStrUp = true
							if math.random(100) < 50 then
								self._shakeJoint = self:GetAnyJoint()
							else
								local i = MDL.GetJointIndex(self._Entity, "k_szyja")
								if i >= 0 then
									self._shakeJoint = i
								end
							end
						end
					end
				end
				
				
				local i = self._shakeJoint
				--[[if math.random(100) < 50 then
					i = MDL.GetJointIndex(self._Entity, "k_szyja")
					if i < 0 then
						i = MDL.GetJointIndex(self._Entity, "root")
					end
				else
					i = MDL.GetJointIndex(self._Entity, "root")
				end--]]
				local stren = t2.ragdollShockStren
				local rnd1 = FRand(-0.01, 0.01) * stren
				local rnd3 = FRand(-0.01, 0.01) * stren
				local rnd2 = FRand(-0.05, 0.05) * stren
				
				local rnd2 = self._shakeStr * t2.ragdollShockStren
				if rnd2 < 0 then
					rnd2 = rnd2 * 2
				end
				local x,y,z = MDL.GetVelocitiesFromJoint(self._Entity, i)
				
				MDL.ApplyVelocitiesToJoint(self._Entity, i, rnd1 + x, rnd2 + y, rnd3 + z)
				--[[
				--if FRand(0,1) < t.otherJointsShockFreq then
					for i,v in t do
						local j = MDL.GetJointIndex(self._Entity, v)
						if j>= 0 then
							local rnd1 = FRand(-0.02, 0.02) * t2.ragdollShockStren
							local rnd3 = FRand(-0.02, 0.02) * t2.ragdollShockStren
							local rnd2 = FRand(-0.05, 0.05) * t2.ragdollShockStren

							local x,y,z = MDL.GetVelocitiesFromJoint(self._Entity, j)
							MDL.ApplyVelocitiesToJoint(self._Entity, j, rnd1 + x, rnd2 + y, rnd3 + z)
						else
							Game:Print("JOINT < 0 "..v)
						end
					end
				--end
				--]]
			end
		else
			if self._electroFX then
				PARTICLE.Die(self._electroFX)
				self._electroFX = nil
			end
			
			if self._electroSound then
				ENTITY.Release(self._electroSound)
				self._electroSound = nil
			end
		end
	end

	if self._enableMovedByExplosions then
		self._enableMovedByExplosions = self._enableMovedByExplosions - 1
		if self._enableMovedByExplosions <= 0 then
			local x,y,z = self._Ax, self._Ay, self._Az
			MDL.SetRagdollMovedByExplosions(self._Entity, true)
			local st = self.s_SubClass.GibExplosionStrength
			if self._forceGibExplosionStrength then
				st = self._forceGibExplosionStrength
			end
			if self._diedByAttackType == AttackTypes.Demon and self._gibbedByDemon then
				MDL.ApplyVelocitiesToAllJoints(self._Entity,self._gibbedByDemon.X*0.1,self._gibbedByDemon.Y*0.1,self._gibbedByDemon.Z*0.1)
			else
				MDL.RagdollSelfExplosion(self._Entity,x,y,z,st*FRand(0.2,0.25),self.s_SubClass.GibExplosionRange)
			end
			self._enableMovedByExplosions = nil
			self._Ax, self._Ay, self._Az = nil,nil,nil
		end
	end
	
	if self._deathTimer > 0 then
		if not Game.Cheat_KeepBodies then
			self._deathTimer = self._deathTimer - 1
		end
		if self._inertiaTensorDelayedEnable then
			self._inertiaTensorDelayedEnable = self._inertiaTensorDelayedEnable - 1
			if self._inertiaTensorDelayedEnable < 0 then
				if not self._gibbed and self._enabledRD then
					local p = self.s_Physics
					if p.InertiaTensorMultiplier then ENTITY.PO_ScaleInertiaTensor(self._Entity, p.InertiaTensorMultiplier) end
				end
				self._inertiaTensorDelayedEnable = nil
			end
		end
	else
		self._AIBrain = nil
		--if debugMarek then Game:Print("Death after ragdoll") end
		-- heart
		if self ~= Player then
			self:ThrowHeart()
		end
		--        
        if self._procBind then
			-- czy trzeba odbindowac?
	        ENTITY.Release(self._procBind._targetEntity)
			--self._procBind._ToKill = true
			self._procBind = nil
        end
        self:ExplodeBody()
		GObjects:ToKill(self,true)
		local blend = self.deathBlendTime
		if not blend then
			blend = 0.25
		end
	    ENTITY.SetTimeToDie(self._Entity,blend)
	end
end
--============================================================================
function CActor:ExplodeBody()
    -- death effect
    local tdj = self.s_SubClass.DeathJoints
    if tdj then
        local size = self._SphereSize * 0.4
        for i=1,table.getn(tdj) do
            local x,y,z = self:GetJointPos(tdj[i])
			if self.AiParams.madonnaFX and not self._gibbed then
   				local obj = GObjects:Add(TempObjName(),CloneTemplate("Raven_EscapeAfterCreate.CActor"))
				obj.Pos.X = x
				obj.Pos.Y = y
				obj.Pos.Z = z
				obj.angle = self.angle
				obj._angleDest = self._angleDest
				obj:Apply()
				if obj.TimeToLive then
					obj.TimeToLive = FRand(obj.TimeToLive * 0.9, obj.TimeToLive * 1.1)
				end
				obj:Synchronize()
			else
				if not Cfg.NoGibs then self:AddPFX("BodyExplosion", size ,Vector:New(x,y,z)) end
			end
        end
        if self.AiParams.madonnaFX then
			self:AddPFX("but", self._SphereSize * 0.6 ,Vector:New(self:GetJointPos("root")))
			if self.s_SubClass.SoundsDefinitions.OnDisapear then
				self:PlaySound("OnDisapear")
			end
		else
		    --PlaySound3D("monster_body_explosion",self.Pos.X,self.Pos.Y,self.Pos.Z,8)
		    self:PlaySound("monsterExplosion")
		end
    end        

end
--============================================================================
function CActor:ApplySpecular(other)
    if not self.s_SubClass then return end    
    MDL.ResetMaterialSpecular(self._Entity)
    local stab
    if other then
		stab = other
	else
		stab = self.s_SubClass.Specular
	end
    if stab then
        local i, o = next(stab, nil)
        while i do
            MDL.SetMaterialSpecular(self._Entity,i,o[1],o[2],o[3],o[4])
            i, o = next(stab, i)
        end
    end
end

--============================================================================    
function CActor:ApplyFresnel(other)
	if not self.s_SubClass then return end    
    local stab
    if other then
		stab = other
    else
		stab = self.s_SubClass.RefractFresnel
	end
    if stab then
        local i, o = next(stab, nil)
        while i do
            MDL.SetMaterialRefractFresnel(self._Entity,i,o.Refract,o.Fresnel,o.ReflTint.R,o.ReflTint.G,o.ReflTint.B,o.RefrTint.R,o.RefrTint.G,o.RefrTint.B)
            i, o = next(stab, i)
        end
    end
end
--============================================================================

function CActor:Trace(length, ang,fixed)
    local cx,cy,cz = self._groundx,self._groundy + self._SphereSize*2.1, self._groundz
   	local angle = self.angle
   	if ang then
   		angle = angle + ang * math.pi/180
   	end

	local v = Vector:New(math.sin(angle), 0, math.cos(angle))
	v:Normalize()

	local fx = v.X*length + cx
	local fy = v.Y*length + cy
	local fz = v.Z*length + cz

	if debugMarek then
		DEBUGcx, DEBUGcy, DEBUGcz, DEBUGfx, DEBUGfy, DEBUGfz = cx,cy,cz,fx,fy,fz
	end

	local b,d,x,y,z,nx,ny,nz,he,e
	if fixed then
		b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTraceFixedGeom(cx,cy,cz,fx,fy,fz)
	else
		ENTITY.RemoveRagdollFromIntersectionSolver(self._Entity)
		b,d,x,y,z,nx,ny,nz,he,e = WORLD.LineTrace(cx,cy,cz,fx,fy,fz)
		ENTITY.AddRagdollToIntersectionSolver(self._Entity)
	end
    return b,d,e		-- x,y,z,nx,ny,nz,he
end


function CActor:GetNearestActorDist(px,py,pz)
	local distance = -1
	for i,v in Actors do
		if v ~= self then
			local x,y,z = v.Pos:Get()
			local dist = Dist2D(x,z,px,pz)
			if (dist < distance or distance < 0) then
				distance = dist
			end
		end
	end
	return distance
end

--============================================================================
function CActor:BindFX(name,scale,joint,ox,oy,oz, rotateWithJoint, rx, ry, rz)
	local pfx
	if self.s_SubClass.ParticlesDefinitions then
		fx = self.s_SubClass.ParticlesDefinitions[name]
		if fx then
			pfx = self:AddPFX(fx.pfx,fx.scale)
			ENTITY.RegisterChild(self._Entity,pfx)
			if fx.joint then
				joint = fx.joint
			end
			local rotateWithJoint = false
			if fx.rotateWithJoint then
				rotateWithJoint = true
			end

			if not rz then
				rx = 0
				ry = 0
				rz = math.pi/2
			end
			
			if fx.rotateWithJointOffset then
				rx = fx.rotateWithJointOffset.X
				ry = fx.rotateWithJointOffset.Y
				rz = fx.rotateWithJointOffset.Z
			end

			
			if rotateWithJoint then
				PARTICLE.SetParentOffset(pfx,fx.offset.X,fx.offset.Y,fx.offset.Z,joint,nil,nil,nil,rx,ry,rz)
			else
				PARTICLE.SetParentOffset(pfx,fx.offset.X,fx.offset.Y,fx.offset.Z,joint)
			end
			return pfx
		end
	end
	
	pfx = self:AddPFX(name,scale)

    if pfx then
		ENTITY.RegisterChild(self._Entity,pfx)
        if rotateWithJoint then
		
            if rz == nil then
                PARTICLE.SetParentOffset(pfx,0,0,0,joint, nil,nil,nil, 0, 0, math.pi/2 * rotateWithJoint)
            else
                PARTICLE.SetParentOffset(pfx,ox,oy,oz,joint, nil,nil,nil, rx, ry, rz)
            end                    
        else
            PARTICLE.SetParentOffset(pfx,ox,oy,oz,joint)
		end
	end
    return pfx
end
--============================================================================
function CActor:BindTrail(name,...)
    local e = ENTITY.Create(ETypes.Trail,name,"trailName")
    ENTITY.AttachTrailToBones(self._Entity,e,unpack(arg))
    WORLD.AddEntity(e)
    return e
end
--============================================================================
function CActor:AddPFX(effect,scale,pos,rot,norm)
	if self.disablePFX then return end
	if self.s_SubClass.ParticlesDefinitions then
		local ef = self.s_SubClass.ParticlesDefinitions[effect]
		if ef then
			effect = ef.pfx
			if ef.scale then
				scale = ef.scale
			end
			if ef.joint then
				pos = Vector:New(self:GetJointPos(ef.joint))
			end
		end
	end
	return AddPFX(effect,scale,pos,rot,norm)
end

--[[function CActor:AddPFX2(effect,scale,pos,rot,norm)
	if self.disablePFX then return end
	local fx = self.s_SubClass.ParticlesDefinitions[effect]
	if fx then
		return AddPFX(fx.pfx,fx.scale,pos,rot,norm)
	end
end--]]

--============================================================================
--function CActor:BindCorona(template,joint)
--    local l = AddLight(template,1,Vector:New(0,0,0))
--    local idx = MDL.GetJointIndex(self._Entity,joint)
--    ENTITY.RegisterChild(self._Entity,l,true,idx)
--end
--============================================================================
--function CActor:UnregisterAllChildren()			-- ### do wywalenia
--    ENTITY.UnregisterAllChildren(self._Entity)    
--end
--============================================================================
function CActor:BloodFX(x,y,z,nx,ny,nz)
    -- blood
    local n = math.random(1,2) -- how many (min,max)
    for i = 1, n do
        local ke = AddItem("Blood.CItem",0.1,Vector:New(x,y,z),true)
        local vx = FRand(-3,3) -- velocity x
        local vy = FRand(3,4)  -- velocity y
        local vz = FRand(-3,3) -- velocity z
        ENTITY.SetVelocity(ke,vx,vy,vz)
    end
    if not Cfg.NoBlood then 
    if nx then
        if Tweak.GlobalData.GermanVersion then
			self:AddPFX("BodyBlood_german",0.3,Vector:New(x,y,z),Quaternion:New_FromNormal(nx,ny,nz))
        else
			self:AddPFX("BodyBlood",0.3,Vector:New(x,y,z),Quaternion:New_FromNormal(nx,ny,nz))
		end
    end
    end
end
--============================================================================
function CActor:InDeathZone(x,y,z,zone)
    if string.find(zone,"wat",1,true) then
        AddObject("FX_splash.CActor",1.5,Vector:New(x,y,z),nil,true)        
        self:PlaySound("waterSplash",nil,nil,nil,nil,x,y,z)
    end

    ENTITY.RemoveFromIntersectionSolver(self._Entity)
    local b,d,dx,dy,dz,nx,ny,nz,he,e = WORLD.LineTrace(x,y+5,z,x,y-5,z)    
--    if b and e and ENTITY.IsWater(e) then
--        ENTITY.SpawnDecal(e,'splash_big',dx,dy,dz,0,1,0)
--    end

	if debugMarek then
		Game:Print(self._Name.." out of level")
	end

    if not self._died then        
        self.Immortal = nil
        self.Health = 1
        self:OnDamage(99999,nil,AttackTypes.OutOfLevel)
        GObjects:ToKill(self)
    else
		if self._deathTimer and self._deathTimer > 1 then
			self._deathTimer = 1
		end
    end
end
--============================================================================


function CActor:PlayRandomSound2D(tableR, noRandomize)
	local name
	if type(tableR) == "table" then
		name = tableR[math.random(1, table.getn(tableR))]
	else
		local s = self.s_SubClass.SoundsDefinitions[tableR]
		if s and s.samples then
			name = s.samples[math.random(1, table.getn(s.samples))]
			if s.disablePitch then
				noRandomize = s.disablePitch
			end
		end
	end
	if name ~= "" then
		local res = string.find(name,"$/")
		local sndDir
		if res then
			name = string.gsub(name,"$/","")
			sndDir = ""
		else
			sndDir = self._SoundDirectory
		end
		PlaySound2D(sndDir..name,nil,nil,noRandomize)
	end
end

function CActor:BindRandomSound(tableR, dist1, dist2, bjoint, doNotAutodelete, loop, disablePitch)
	local name = tableR
	local dist_1 = dist1
	local dist_2 = dist2
	local joint = bjoint
	if type(tableR) == "table" then
		name = tableR[math.random(1, table.getn(tableR))]
	else
		if self.s_SubClass.SoundsDefinitions then
			local sndDef = self.s_SubClass.SoundsDefinitions[tableR]
			if sndDef then
				if sndDef.playChance then
					if FRand(0,1) > sndDef.playChance then
						return
					end
				end

				name = sndDef.samples[math.random(1, table.getn(sndDef.samples))]
				if sndDef.dist1 then
					dist_1 = sndDef.dist1
				end
				if sndDef.dist2 then
					dist_2 = sndDef.dist2
				end
				if sndDef.joint then
					joint = sndDef.joint
				end
				if sndDef.disablePitch then
					disablePitch = true
				end
				if sndDef.loop then
					loop = true
				end
			end
		end		
	end
	if name ~= "" then
		local res = string.find(name,"$/")
		local sndDir
		if res then
			name = string.gsub(name,"$/","")
			sndDir = ""
		else
			sndDir = self._SoundDirectory
		end
		local snd, idx = self:BindSound(sndDir..name, dist_1, dist_2, loop, joint,nil,nil,nil,doNotAutodelete, disablePitch)
		return snd, idx
	end
end


function CActor:GetClosestJoint(x,y,z, targetEntity)		-- narazie?
	local brain = self._AIBrain
	local dist = 9999		-- narazie
	local x1,y1,z1 = 0,0,0
	local j = -1
	--local allJoints = {"r_p_lokiec", "r_l_lokiec", "root", "k_szyja","k_zebra", "n_l_biodro", "n_p_biodro", "r_l_bark", "r_p_bark", "n_l_kolano", "n_p_kolano"}
	local allJoints = {"r_l_bark", "r_p_bark","k_szyja","root"}--"n_l_biodro", "n_p_biodro"
	for i,v in allJoints do
		local idx  = MDL.GetJointIndex(targetEntity, v)
		local x2,y2,z2 = MDL.GetJointPos(targetEntity, idx)
		local d = Dist3D(x,y,z, x2,y2,z2)
		if d < dist then
			dist = d
			j = idx
			x1 = x2
			y1 = y2
			z1 = z2
		end
	end
	return j,x1,y1,z1
end

----------------------------------------------
function CActor:PlaySoundAndStopLast(name, dist1, dist2, noRandomize)		-- nastepny grany dzwiek kasuje poprzedni (z fade out-tem)
	if SOUND3D.IsPlaying(self._sndHitId) then
		SOUND3D.SetVolume(self._sndHitId, 0, 0.2)
	end

	self._sndHitId = self:PlaySound(name, dist1, dist2, nil, noRandomize)
	self._sndHitName = name
	return self._sndHitId
end

function CActor:PlaySoundHit(name, par4, par5)			-- dla dzwiekow ktore maja byc przerwane np. paszcza, zeby nie odgrywal sie nowy, gdy jest stary. 
	if self:IsPlayingLastSound() and self._sndHitName == name then
		return
	end
	self._sndHitId = self:PlaySoundAndStopLast(name, par4, par5)
	self._sndHitName = name
	return self._sndHitId
end

function CActor:PlaySoundHitIfNotPlayingLast(name, par4, par5)
	if self:IsPlayingLastSound() then
		return
	end
	self._sndHitId = self:PlaySoundAndStopLast(name, par4, par5)
	self._sndHitName = name
	return self._sndHitId
end


function CActor:IsPlayingLastSound()
	if SOUND3D.IsPlaying(self._sndHitId) then
		return true
	end
	return false
end

function CActor:StopLastSound(idLUA)
	if idLUA then
		if self._sndHitId == idLUA then
			if SOUND3D.IsPlaying(self._sndHitId) then
				SOUND3D.SetVolume(self._sndHitId, 0, 0.2)
			end		
			return true
		else
			return false
		end
	else
		if SOUND3D.IsPlaying(self._sndHitId) then
			SOUND3D.SetVolume(self._sndHitId, 0, 0.2)
		end		
		return true
	end

	return false
end

---------------------------
function CActor:PlaySoundHitBinded(name, d1, d2, joint, loop)			-- "alastor","lucifer","witch"
	if self._sndStoppableID_CBinded and SND.IsPlaying(self._sndStoppableID_CBinded) then
		local e = ENTITY.GetPtrByIndex(self._sndStoppableID_CBinded)
		if e then
			if self._sndStoppableID_CBindedName == name then
				return
			end
			ENTITY.Release(e)
		end
	end
	snd, self._sndStoppableID_CBinded = self:BindRandomSound(name, d1, d2, joint, nil, loop)
	self._sndStoppableID_CBindedName = name
	return snd
end

function CActor:StopSoundHitBinded()			-- tylko dla dzwiekow "hit", zeby nie odgrywal sie nowy, gdy jest stary
	if self._sndStoppableID_CBinded and SND.IsPlaying(self._sndStoppableID_CBinded) then
		local e = ENTITY.GetPtrByIndex(self._sndStoppableID_CBinded)
		if e then
			ENTITY.Release(e)
		end
		self._sndStoppableID_CBinded = nil
		self._sndStoppableID_CBindedName = nil
	end
end
----------------------------------------------------



function CActor:FootFX(joint, forceSize)
    local j = MDL.GetJointIndex(self._Entity, joint)
    local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,0,0)
    local size = 0.1
    if forceSize then
		size = forceSize
    end
    self:AddPFX('but',size,Vector:New(x,y,z))
end

function CActor:LaunchFullAnimEvent(anim)    
    if not self.s_SubClass.Animations[anim] then return end    
    local animevent = self.s_SubClass.Animations[anim][3]
    for i,ev in animevent do
        self[ev[2]](self,ev[3], ev[4], ev[5])
    end
end


------------

function CActor:StopMovement()
	if self._proc then
		self._proc:Stop()
	end
end

function CActor:StartMovement()
	if self._proc then
		self._proc:Start()
	end
end


function CActor:TakeToThrow()
	local aiParams = self.AiParams
	local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
	obj.ObjOwner = self
	--obj._enabled = false
	obj:Apply()
    if obj.Synchronize then
        obj:Synchronize()
    end
	ENTITY.PO_Enable(obj._Entity,false)
	if self._objTakenToThrow then
		Game:Print(self._Name.." ERROR!!!: self._objTakenToThrow already exists")
		GObjects:ToKill(self._objTakenToThrow)
		Game.freezeUpdate = true
	end
	self._objTakenToThrow = obj
    local brain = self._AIBrain
	self:RotateToVector(brain._enemyLastSeenPoint.X,brain._enemyLastSeenPoint.Y,brain._enemyLastSeenPoint.Z)	-- ###
	if aiParams.throwItemBindToOffset then
		--self._proc = PBindToJoint:New(obj._Entity,self._Entity,aiParams.throwItemBindTo,aiParams.throwItemBindToOffset.X,aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z)
		self._proc = AddObject(Templates["PBindToJoint.CProcess"]:New(obj._Entity,self._Entity,aiParams.throwItemBindTo,aiParams.throwItemBindToOffset.X,aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z))
	else
		--self._proc = PBindToJoint:New(obj._Entity,self._Entity,aiParams.throwItemBindTo,0.0,0,0.0)
		self._proc = AddObject(Templates["PBindToJoint.CProcess"]:New(obj._Entity,self._Entity,aiParams.throwItemBindTo,0.0,0,0.0))
	end
	--GObjects:Add(TempObjName(),self._proc)
	if aiParams.hideMesh then
		MDL.SetMeshVisibility(self._Entity, aiParams.hideMesh, false)		-- narazie
	end
end


function CActor:ThrowImmid(angle, straight, joint, angleDiff, jointOffsetX,jointOffsetY,jointOffsetZ)		-- bool straight/ballistic
    local aiParams = self.AiParams
    local j = joint
    if not j then
		j = aiParams.throwItemBindTo
    end
	local idx  = MDL.GetJointIndex(self._Entity,j)
	local x,y,z
	if aiParams.throwItemBindToOffset then
		x,y,z = MDL.TransformPointByJoint(self._Entity, idx, aiParams.throwItemBindToOffset.X,aiParams.throwItemBindToOffset.Y, aiParams.throwItemBindToOffset.Z)
	else
		if jointOffsetZ then
			x,y,z = MDL.TransformPointByJoint(self._Entity, idx, jointOffsetX,jointOffsetY,jointOffsetZ)
		else
			x,y,z = MDL.TransformPointByJoint(self._Entity, idx, 0,0,0)
		end
	end

	local obj
	local e
	
	--local q = Quaternion:New_FromEuler(0, math.pi/2 - actor._angleAttackX - actor.angle, math.pi/2)
	
	local obj = GObjects:Add(TempObjName(),CloneTemplate(aiParams.ThrowableItem))
	--e, obj = AddItem(aiParams.ThrowableItem, nil, Vector:New(x,y,z),true)
	
	if self.GetThrowItemRotation then
		obj.Rot = self:GetThrowItemRotation()
	end
	
	obj.ObjOwner = self
	obj._joint = idx
	obj.Pos.X = x
	obj.Pos.Y = y
	obj.Pos.Z = z
	obj:Apply()
	obj:Synchronize()
	self._objTakenToThrow = obj
	self:ThrowTaken(angle, straight, angleDiff)
	if aiParams.hideMesh then
		MDL.SetMeshVisibility(self._Entity, aiParams.hideMesh, false)		-- narazie
	end
end

function CActor:ThrowTaken(forceYaw, straight, angleDiff)		-- bool straight(true)/ballistic(false)
	local aiParams = self.AiParams
	local angle = self.angle
	local x1,y1,z1
    if self._proc then
        GObjects:ToKill(self._proc)
        if self._objTakenToThrow then
			if self._throwModeRagdoll then
				x1,y1,z1 = self:GetJointPos(aiParams.throwItemBindTo)
			else
				x1,y1,z1 = ENTITY.GetPosition(self._objTakenToThrow._Entity)
			end
		else
			Game:Print("ERROR #1 in cactor:throwtaken "..self._Name)
			x1,y1,z1 = self._groundx,self._groundy + 1.4,self._groundz
		end
        self._proc = nil
    else
		if self._objTakenToThrow then
			if self._objTakenToThrow.Model then
				x1,y1,z1 = MDL.GetJointPos(self._objTakenToThrow._Entity, 0)
			else
				x1,y1,z1 = ENTITY.GetPosition(self._objTakenToThrow._Entity)
			end
		end
    end

    if self._objTakenToThrow then
		local entity = self._objTakenToThrow._Entity
        local brain = self._AIBrain
        
        local targetDeltaY = 1.2
        if aiParams.throwDeltaY then
			targetDeltaY = aiParams.throwDeltaY
        end
		local x2,y2,z2 = brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y + targetDeltaY, brain._enemyLastSeenPoint.Z	--Player._groundx, Player.Pos.Y, Player._groundz			-- pozniej zgodnie z obrotem
		if brain.r_closestEnemy then
			x2,y2,z2 = brain.r_closestEnemy._groundx, brain.r_closestEnemy._groundy + targetDeltaY, brain.r_closestEnemy._groundz
		end
		
		ENTITY.PO_Enable(entity,true)

		local maxAngleDiff = 30
		if aiParams.throwMaxAngleYawDiff then
			maxAngleDiff = aiParams.throwMaxAngleYawDiff
		else
			if aiParams.weapon and aiParams.weapon.maxYaw then
				maxAngleDiff = aiParams.weapon.maxYaw
			end
		end
		maxAngleDiff = maxAngleDiff * math.pi/180
		local maxAngleDiffPitch = 30
		if aiParams.throwMaxAnglePitchDiff then
			maxAngleDiffPitch = aiParams.throwMaxAnglePitchDiff
		else
			if aiParams.weapon and aiParams.weapon.maxPitch then
				maxAngleDiffPitch = aiParams.weapon.maxPitch
			end
		end
		maxAngleDiffPitch = maxAngleDiffPitch * math.pi/180
		
		self._objTakenToThrow._enabled = true
		local pitch
		local x,y,z
		local v = Vector:New(x2 - x1, y2 - y1, z2 - z1)
		v:Normalize()

		if straight then
			local recalc = false
			local angleToPlayer = math.atan2(v.X, v.Z)
				
			--[[if debugMarek then
				self.d1 = x2
				self.d2 = y2
				self.d3 = z2
				self.d4 = x1
				self.d5 = y1
				self.d6 = z1
			end--]]
			

			local aDist = AngDist(angle, angleToPlayer)
			if math.abs(aDist) > maxAngleDiff then		-- max. angle reached (wzgl. kierunku patrzenia, to przed siebie)
				--Game:Print("max angle diff reached. "..(angle*180/math.pi).." "..(angleToPlayer*180/math.pi))
				if aDist > 0 then
					recalc = true
					angle = angle + maxAngleDiff
				else
					recalc = true
					angle = angle - maxAngleDiff
				end
			else
				angle = angleToPlayer
			end
			
			if angleDiff then
				recalc = true
				angle = angle + angleDiff * math.pi/180
			end
			
			pitch =  math.atan2(y1 - y2, math.sqrt((x1 - x2)*(x1 - x2)+(z1 - z2)*(z1 - z2)))
			if pitch > maxAngleDiff then
				--Game:Print("max PITCH diff reached.")
				recalc = true
				pitch = maxAngleDiff
			end
			if pitch < -maxAngleDiff then
				--Game:Print("max -PITCH diff reached.")
				recalc = true
				pitch = -maxAngleDiff
			end

			if recalc then
				v.X,v.Y,v.Z = VectorRotate(1.0,0,0, 0, 0, pitch)
				v.X,v.Y,v.Z = VectorRotate(v.X,v.Y,v.Z, 0, -angle+math.pi/2, 0)
			end
			v:MulByFloat(aiParams.throwVelocity)
			--[[if debugMarek then
				self.yadebug1 = self._objTakenToThrow.Pos.X
				self.yadebug2 = self._objTakenToThrow.Pos.Y
				self.yadebug3 = self._objTakenToThrow.Pos.Z
				self.yadebug4 = self._objTakenToThrow.Pos.X + v.X
				self.yadebug5 = self._objTakenToThrow.Pos.Y + v.Y
				self.yadebug6 = self._objTakenToThrow.Pos.Z + v.Z
			end--]]
			
			if aiParams.throwAngularVelocitySpeed then
				local vx = -math.sin(angle)
				local vz = math.cos(angle)
				local speed = -aiParams.throwAngularVelocitySpeed * FRand(0.8, 1.2)
				ENTITY.SetAngularVelocity(entity,vz*speed,0,vx*speed)
			end

			ENTITY.SetVelocity(entity, v.X, v.Y, v.Z)

		else	-- ballistic

			local maxAngleDiffPitch = 45
			if aiParams.throwMaxAnglePitchDiff then
				maxAngleDiffPitch = aiParams.throwMaxAnglePitchDiff
			end
			maxAngleDiffPitch = maxAngleDiffPitch * math.pi/180
			
			--local distToTarget = Dist3D(x2,y2,z2, x1,y1,z1)
			local distToTarget = Dist2D(x2,z2, x1,z1)
			if distToTarget < 4 then
				distToTarget = 4
			end

			if not forceYaw then
				local angleToPlayer = math.atan2(v.X, v.Z)
				local aDist = AngDist(angle, angleToPlayer)
				if math.abs(aDist) > maxAngleDiff then		-- max. angle reached (wzgl. kierunku patrzenia, to przed siebie)
					--Game:Print("max angle diff reached")
					if aDist > 0 then
						angle = angle + maxAngleDiff
					else
						angle = angle - maxAngleDiff
					end
					v = Vector:New(math.sin(angle), 0, math.cos(angle))
					v:Normalize()
				end	
				angle = math.atan2(v.Z, v.X)
			else
				angle = forceYaw
			end

			if angleDiff then
				angle = angle + angleDiff * math.pi/180
			end
			
			if not aiParams.throwAngle and aiParams.throwVelocity then
				x,y,z = CalcThrowVectorGivenVelocity(distToTarget - aiParams.throwDistMinus, aiParams.throwVelocity, angle, (brain._enemyLastSeenPoint.Y + 1.2) - y1, maxAngleDiffPitch)
			else
				x,y,z = CalcThrowVectorGivenAngle(distToTarget - aiParams.throwDistMinus, aiParams.throwAngle, angle, (brain._enemyLastSeenPoint.Y + 1.2) - y1)
			end

			--[[if debugMarek then
				self.d1 = x1 + x
				self.d2 = y1 + y
				self.d3 = z1 + z
				self.d4 = x1
				self.d5 = y1
				self.d6 = z1
				
				
				self.yaaaadebug1 = x2
				self.yaaaadebug2 = y2
				self.yaaaadebug3 = z2
				self.yaaaadebug4 = x1
				self.yaaaadebug5 = y1
				self.yaaaadebug6 = z1
			end--]]

			if self._throwModeRagdoll then
		        MDL.SetPinnedJoint(entity, brain._JointH, false)	
		        MDL.ApplyVelocitiesToJointLinked(entity, brain._JointH, x,y,z, FRand(0,8),FRand(0,8),FRand(0,8))
			else
				if aiParams.throwAngularVelocitySpeed then
					local vx = -math.sin(angle)
					local vz = math.cos(angle)
					local speed = -aiParams.throwAngularVelocitySpeed * FRand(0.8, 1.2)
					ENTITY.SetAngularVelocity(entity,vx*speed,0,vz*speed)
				end
				if self._getVelOnly then
					self._getVelOnly.X = x
					self._getVelOnly.Y = y
					self._getVelOnly.Z = z
				else
					ENTITY.SetVelocity(entity,x,y,z)
				end
			end
		end
		if self.OnThrow then
			self:OnThrow(v.X, v.Y, v.Z, angle, pitch)
		end

	    if aiParams.escapeAfterThrowTime and aiParams.escapeAfterThrowTime > 0 then
			brain.escape = FRand(aiParams.escapeAfterThrowTime*0.8,aiParams.escapeAfterThrowTime*1.3)
		end
	else
		Game:Print(self._Name.." ERROR: ThrowTaken() no obj")
		Game.freezeUpdate = true
	end
    self._objTakenToThrow = nil
    return angle
end

function CActor:SetAnimSpeed(par1)
	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, par1)
end
----------------

function CActor:RotateToVectorWithAnim(tx,ty,tz)
	--[[[if debugMarek then
		if Dist3D(tx,0,tz,self._groundx,0,self._groundz) < 0.01 then
			Game:Print(self._Name.." RTV")
			return
		end
	end--]]
	--if debugMarek then Game:Print("))"..GetCallStackInfo(2)) end
	local angle = math.atan2(tx - self._groundx, tz - self._groundz)
	return self:RotateToWithAnim(angle * 180 / math.pi)
end


function CActor:RotateWithAnim(angle)
	--[[[if debugMarek then
		if self._rotatingWithAnim then
			Game:Print("self._rotatingWithAnim already set")
		end
	end--]]
	if self._rotatingWithAnim then	-- juz sie kreci, schedule next rotation
		--if debugMarek then Game:Print(">> RotateWithAnim Schedule "..angle.." old = "..(self.angle*180/math.pi).." adest = "..(self._angleDest*180/math.pi)) end
		self._NEXTangleDestAnim = angle
		return true
	end
	self._NEXTangleDestAnim = nil

	self:FullStop()
	local a = AngDist(self.angle, self.angle + angle * math.pi/180)

	local max = math.pi * 30/180
	if not self.s_SubClass.rotate45R then
		max = math.pi * 70/180
	end
    
	if math.abs(a) >= max then
		self._angleDestAnim = a
		self._rotatingWithAnim = true
		self._animRotName = nil
		self._isRotating = true
		--Game.freezeUpdate = true
		--Game:Print("++ "..(self.angle * 180/math.pi).." dest = "..(self.angle * 180/math.pi + angle))
		return true
	else
		--Game:Print("za maly kat "..a)
		return false
	end

end


function CActor:RotateToWithAnim(angle)
	--[[[if debugMarek then
		if self._rotatingWithAnim then
			Game:Print("self._rotatingWithAnim already set")
		end
	end--]]
	if self._rotatingWithAnim then	-- juz sie kreci, schedule next rotation
		--if debugMarek then Game:Print(">> RotateToWithAnim Schedule "..angle.." old = "..(self.angle*180/math.pi)) end
		self._NEXTangleDestAnim = angle		-- moze od razu _angleDestAnim?
		return true
	end
	self._NEXTangleDestAnim = nil

	self:FullStop()
	local a = AngDist(self.angle, angle * math.pi/180)
	--Game:Print(">> RotateToWithAnim "..(a*180/math.pi))
	--Game.freezeUpdate = true
	
	local max = math.pi * 30/180
	if not self.s_SubClass.rotate45R then
		max = math.pi * 70/180
	end
	
	if math.abs(a) >= max then
		self._angleDestAnim = a
		self._rotatingWithAnim = true
		self._isRotating = true
		self._animRotName = nil
		--Game.freezeUpdate = true
		--Game:Print("OK kat "..(a).." "..max)
		return true
	else
		--? zwykly obrot
		--Game:Print("za maly kat "..(a*math.pi/180))
		return false
	end

end

function CActor:UpdateRotateWithAnim(delta)
	--Game:Print("UpdateRotateWithAnim() "..self._angleDestAnim.. " "..self.Animation.."  animtime"..self._CurAnimTime)
	if (not self._isAnimating or self.Animation ~= self._animRotName) then
		if self._NEXTangleDestAnim then
			self._angleDestAnim = AngDist(self.angle, self._NEXTangleDestAnim * math.pi/180)
			--if debugMarek then Game:Print("Get next rot from QUEUE: "..(self._NEXTangleDestAnim).." self.angle = "..(self.angle*180/math.pi)) end
			self._NEXTangleDestAnim = nil
			--self._animRotName = nil
		--else
			--if debugMarek then Game:Print("koniec anim rot: self.angle = "..(self.angle*180/math.pi)) end
		end

		if math.abs(self._angleDestAnim) < 30*math.pi/180 then
            --if debugMarek then Game:Print("koniec rotatewithanim "..(self._angleDestAnim * 180/math.pi).." angle dest = "..(self.angle * 180/math.pi)) end
			self._animRotName = nil
			self._isRotating = false
			self._rotatingWithAnim = false
			self._angleDest = self.angle
			--Game.freezeUpdate = true
			return
		else
			if math.abs(self._angleDestAnim) >= 70*math.pi/180 and self.s_SubClass.rotate90R then
				self._rotateWithAnimgStepAngle = math.pi/2
				if self._angleDestAnim < 0 then
					self._animRotName = self.s_SubClass.rotate90R	--"rotate_right90"
				else
					self._animRotName = self.s_SubClass.rotate90L
				end
			else
				self._rotateWithAnimgStepAngle = math.pi/4
	            if self._angleDestAnim < 0 then
					self._animRotName = self.s_SubClass.rotate45R	--"rotate_right"
				else
					self._animRotName = self.s_SubClass.rotate45L	-- "rotate_left"
				end
			end
			self._HasMovingCurveRot = "ROOOT"
			if self._animRotName then
				self:SetAnim(self._animRotName,false)
			else
				self._animRotName = nil
				self._isRotating = false
				self._rotatingWithAnim = false
				self._angleDest = self.angle
				return
			end
			self._HasMovingCurveRot = nil
		end
        if (self._angleDestAnim < 0) then
            self._angleDestAnim = self._angleDestAnim + self._rotateWithAnimgStepAngle
        else
            self._angleDestAnim = self._angleDestAnim - self._rotateWithAnimgStepAngle
        end
        self._angleDest = self.angle
	else
		local add = self._rotateWithAnimgStepAngle * self._CurAnimTime / self._CurAnimLength
		if self.Animation == self.s_SubClass.rotate90R or self.Animation == self.s_SubClass.rotate45R then		-- pozniej na podst. self._rotateWithAnimgStepAngle
			self.angle = self._angleDest - add
		else
			self.angle = self._angleDest + add
		end
		self.angle =  math.mod(self.angle, math.pi*2)
		ENTITY.SetOrientation(self._Entity,self.angle)
	end
end

function CActor:StopFlying()
    if self.AIenabled then
        ENTITY.PO_SetFlying(self._Entity, false)
    end
end

function CActor:SetVel()
	--if debugMarek then WORLD.SetWorldSpeed(1/4) end
    if self.AIenabled and self._vdest and self._vdest.Z then
        ENTITY.PO_SetFlying(self._Entity, true)
        ENTITY.SetVelocity(self._Entity,self._vdest.X, self._vdest.Y, self._vdest.Z)
    end
end




function CActor:BindTrailSword(name, joint1, joint2, joint3)
	if self._trailSword then
		Game:Print(self._Name.."  bylu JUZ TRAIL")
		ENTITY.Release(self._trailSword)
	end
	self._trailSword = self:BindTrail(name, joint1, joint2, joint3)
end

function CActor:EndTrailSword()
	if self._trailSword then
		ENTITY.Release(self._trailSword)
		self._trailSword = nil
	end
end

function CActor:Freeze()
    if self._frozen then return end
    if self.disableFreeze then return end
    local s = Templates["Shotgun.CWeapon"]:GetSubClass()
    local ftime = s.FrozenTime
    if Player.HasWeaponModifier then ftime = ftime * 2 end
    AddObject(Templates["FrozenObject.CProcess"]:New(self,ftime,s.FrozenFadeInTime,s.FrozenFadeOutTime),nil,nil,nil,true) 
    if self.CustomOnFreeze then
		self:CustomOnFreeze()
		return
    end
end

function CActor:GetAnyJoint()		-- jesli ragdoll, to tylko z ragdoll-a
	local j = MDL.GetJointIndex(self._Entity, "root", true)
	if j < 0 then
		local t = {"k_ogo","k_zebra","k_head"}
		for i,v in t do
			j = MDL.GetJointIndex(self._Entity, v, true)
			if j >= 0 then
				break
			end
		end
	end
	if j < 0 then
		--if debugMarek then Game:Print(self._Name.." warning: get anyjoint false") end
		j = MDL.GetJointIndex(self._Entity, "root")
		if j < 0 then
			Game:Print(self._Name.." ERROR: get anyjoint false, no ROOT")
		end
	end
	return j
end


-------------------------------------------------------------------------------------


function CalcThrowVectorGivenVelocity(distance, velocity, angleXZ, deltaY, maxPitch)
	local gravity = Tweak.GlobalData.Gravity
	local pitch
	if not deltaY then
		pitch = gravity*distance/(2 * velocity * velocity)
	else
		pitch = deltaY/distance + gravity*distance/(2 * velocity * velocity)
	end
	
	if pitch > maxPitch then
		--Game:Print("max PITCH diff reached")
		--Game.freezeUpdate = true
		pitch = maxPitch
	end
	if pitch < -maxPitch then
		--Game:Print("max -PITCH diff reached")
		--Game.freezeUpdate = true
		pitch = -maxPitch
	end

	local x,y,z = VectorRotate(1.0,0,0, 0, 0, -pitch)
	x,y,z = VectorRotate(x,y,z, 0, angleXZ, 0)
	
	x = x * velocity
	y = y * velocity
	z = z * velocity
	return x,y,z, pitch
end


function CalcThrowVectorGivenAngle(distance, angle, angleXZ, deltaY)		-- given angle
	local gravity = Tweak.GlobalData.Gravity
	local temp
	local a = angle * math.pi/180
	if not deltaY then
		temp = distance * gravity/math.sin(2 * a)
	else
		temp = (distance * distance * gravity)/((distance * math.tan(a) - deltaY) * 2 * math.cos(a) * math.cos(a))
	end

    local force = 8
    if temp > 0 then
        force = math.sqrt(temp)
    else
        Game:Print("ERROR: force < 0 actor cant throw at desired target, with that angle1")
        temp = distance * gravity/math.sin(2 * a)
        if temp > 0 then
			force = math.sqrt(temp)
		else
			Game:Print("ERROR: force < 0 actor cant throw at desired target, with that angle2")
		end
    end

	local x,y,z = VectorRotate(1.0,0,0, 0, 0, -a)
	x,y,z = VectorRotate(x,y,z, 0, angleXZ, 0)
	
	x = x * force
	y = y * force
	z = z * force
	return x,y,z, force
end

--==============================================




--CActor.PlayRandomSound3D = CActor.PlaySound
--CActor.PlaySoundHitIfNotPlayingLast = CActor.PlaySoundHit
