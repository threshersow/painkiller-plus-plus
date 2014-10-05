function Vamp:OnInitTemplate()
    self:SetAIBrain()
end

function Vamp:CustomOnDamage(he,x,y,z,obj, damage, type)
	if type == AttackTypes.Step then
		--Game:Print("AttackTypes.Step canceled")
		return true
	end
end


function Vamp:CustomOnDeath()
	Game.MegaBossHealth = nil
	Game.MegaBossHealthMax = nil
    if self._proc then
        GObjects:ToKill(self._proc)
        self._proc = nil
    end
end


function Vamp:Eq()
	Game._EarthQuakeProc:Add(self._groundx, self._groundy, self._groundz, 100, self.StompRange, self.CameraMov, self.CameraRot, 2.5, 20)
end

function Vamp:Stomp(joint)
	if Game._EarthQuakeProc then
		Game._EarthQuakeProc:Add(self._groundx, self._groundy, self._groundz, self.StompTimeOut, self.StompRange, self.CameraMov, self.CameraRot, 1.0)
	end
	local x,y,z = self:GetJointPos(joint)		
	WORLD.Explosion2(x,y,z, self.AiParams.explosionWhenWalkStreng, self.AiParams.explosionWhenWalkRange, nil, AttackTypes.Step, self.AiParams.explosionWhenWalkDamage)
    AddPFX('butbig',1.0,Vector:New(x,y,z))
end



function Vamp:OnCreateEntity()
	Game.MegaBossHealthMax = self.Health
	Game.MegaBossHealth = self.Health
    self._bloody = true
end


function Vamp:CustomUpdate()
	Game.MegaBossHealth = self.Health
    
    -- blood
    if not self._died and self._bloody and math.random(5) == 1 then -- jak czesto
        local j = MDL.GetJointIndex(self._Entity, "k_szyja")
        local x,y,z = MDL.TransformPointByJoint(self._Entity, j,0,1,0)
        
        local ke = AddItem("VampBlood.CItem",1.5,Vector:New(x,y,z),true)

        local a = self.angle + FRand(-0.0,0.0) -- jaki rozrzut na boki
        local vx = math.sin(a) * FRand(2,3) -- jak daleko
        local vy = 0			           -- jak wysoko
        local vz = math.cos(a) * FRand(2,3) -- jak daleko

        ENTITY.SetVelocity(ke,vx,vy,vz)
    end
end

function Vamp:CustomDelete()
	if self._objStone then
		GObjects:ToKill(self._objStone)
		self._objStone = nil
	end
	Game.MegaBossHealth = nil
	Game.MegaBossHealthMax = nil
	local x,y,z = self:GetJointPos("root")
	AddPFX("AlastorSpawnFX", 3.5, Vector:New(x,y,z))
	PlaySound2D("misc/fontain-blowupmetheor")
end




-----------------------------------------------
Vamp._CustomAiStates = {}

Vamp._CustomAiStates.attackVamp = {
	name = "attackVamp",
	lastWalkPoint = nil,
}

function Vamp._CustomAiStates.attackVamp:OnInit(brain)
end

function Vamp._CustomAiStates.attackVamp:OnUpdate(brain)
	local actor = brain._Objactor
	if not actor._isRotating then
		local tabl = actor.AiParams.actionsWhenNoEnemy
		if brain._seeEnemy then
			tabl = actor.AiParams.actionsWhenEnemy
		end
		local total = 0
		for i,v in tabl do
			total = total + v[2]
		end

		local rnd = FRand(total)
		total = 0
		for i,v in tabl do
			total = total + v[2]
			if total >= rnd then
				brain._submode = v[1]
				break
			end
		end
		if debugMarek then
			if not brain._submode then
				if debugMarek then Game:Print("VAMP no submode!") end
				Game.freezeUpdate = true
			else
				if debugMarek then Game:Print("VAMP submode = "..brain._submode) end
			end
		end
	end
end

function Vamp._CustomAiStates.attackVamp:Evaluate(brain)
	return 0.1
end

------------------------------------------------
Vamp._CustomAiStates.animVamp = {
	name = "animVamp",
	active = false,
}

function Vamp._CustomAiStates.animVamp:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	if math.random(100) < 35 and brain._enemyLastSeenTime > 0 then
		actor:RotateToVectorWithAnim(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
	end
	self.mode = 0
	self.active = true
	brain._submode = nil
	self.timer = math.random(60,120)
end

function Vamp._CustomAiStates.animVamp:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		local animName = actor.s_SubClass.Ambients[math.random(1,table.getn(actor.s_SubClass.Ambients))]
		if not actor:SetAnim(animName, false) then
			self.active = nil
		end
		self.mode = 1
	end
	
	if self.mode == 1 then
		if not actor._isAnimating then
			self.active = nil
		end
		if self.timer then
			self.timer = self.timer - 1
			if self.timer < 0 then
				self.timer = nil
				self.active = nil
			end
		end
	end
end

function Vamp._CustomAiStates.animVamp:OnRelease(brain)
	self.active = nil
end

function Vamp._CustomAiStates.animVamp:Evaluate(brain)
	if self.active or brain._submode == "idle" then
		return 0.5
	end
	return 0
end

--------------------------
Vamp._CustomAiStates.walkVamp = {
	name = "walkVamp",
	active = false,
}

function Vamp._CustomAiStates.walkVamp:OnInit(brain)
	local actor = brain._Objactor
	brain._submode = nil
	self.mode = 0
	if brain._walkArea then
		local rnd = math.random(1, table.getn(brain._walkArea.Points))
		actor:RotateToVectorWithAnim(brain._walkArea.Points[rnd].X, brain._walkArea.Points[rnd].Y, brain._walkArea.Points[rnd].Z, false)
		self.active = true
		self.rnd = rnd
	end
end

function Vamp._CustomAiStates.walkVamp:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		local rnd = self.rnd
		actor:WalkTo(brain._walkArea.Points[rnd].X, brain._walkArea.Points[rnd].Y, brain._walkArea.Points[rnd].Z, false)
		self.timerWalk = math.random(200,400)
		self.mode = 1
	end
	if self.mode == 1 then
		if self.timerWalk then
			self.timerWalk = self.timerWalk - 1
			if self.timerWalk < 0 then
				actor:Stop()
				--if debugMarek then Game:Print("vamp stoped by timer") end
				self.active = nil
			end
		end
		
		if not actor._isWalking then
			self.active = nil
		end
	end
end

function Vamp._CustomAiStates.walkVamp:OnRelease(brain)
	self.active = nil
end

function Vamp._CustomAiStates.walkVamp:Evaluate(brain)
	if self.active or brain._submode == "walk" then
		return 0.5
	end
	return 0
end

--------------------------
Vamp._CustomAiStates.throwVamp = {
	name = "throwVamp",
	active = false,
}

function Vamp._CustomAiStates.throwVamp:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	brain._submode = nil
	self.active = true
	self.submode = 0
	actor:RotateToVectorWithAnim(brain._enemyLastSeenPoint.X, brain._enemyLastSeenPoint.Y, brain._enemyLastSeenPoint.Z)
end


function Vamp._CustomAiStates.throwVamp:OnUpdate(brain)
	local actor = brain._Objactor
	if self.submode == 0 then
		if not actor._isRotating then
			actor:SetAnim('take_stone',false)
			self.submode = 1
		end
	end
	if self.submode == 1 then
		if not actor._isAnimating then
			actor:SetAnim('throw_stone',false)
			self.submode = 2
		end
	end
	if self.submode == 2 then
		if not actor._isAnimating or actor.Animation ~= "throw_stone" then
			self.active = false
		end
	end	
end

function Vamp._CustomAiStates.throwVamp:OnRelease(brain)
	local actor = brain._Objactor
	if actor._proc then
        GObjects:ToKill(actor._proc)
        actor._proc = nil
	end
	actor._objStone = nil
end

function Vamp._CustomAiStates.throwVamp:Evaluate(brain)
	if self.active or brain._submode == "throw" then
		return 0.5
	end
	return 0
end


--------------------------
Vamp._CustomAiStates.earthqVamp = {
	name = "earthqVamp",
	active = false,
}

function Vamp._CustomAiStates.earthqVamp:OnInit(brain)
	local actor = brain._Objactor
	actor:Stop()
	brain._submode = nil
	self.active = true
	if brain._walkArea then
		local size = table.getn(brain._walkArea.Points)
		local dist = 99999
		self.i = -1
		for i=1,size do
			local d = Dist3D(brain._walkArea.Points[i].X, brain._walkArea.Points[i].Y, brain._walkArea.Points[i].Z, actor._groundx, actor._groundy, actor._groundz)
			if d < dist then
				self.i = i
				dist = d
			end
		end
		if self.i > 0 then
			actor:RotateToVectorWithAnim(brain._walkArea.Points[self.i].X, brain._walkArea.Points[self.i].Y, brain._walkArea.Points[self.i].Z)
			self.substate = -1
		else
			self.substate = 1
		end
	else
		self.substate = 1
	end
end

function Vamp._CustomAiStates.earthqVamp:OnUpdate(brain)
	local actor = brain._Objactor
	if self.substate == -1 and not actor._isRotating then
		actor:WalkTo(brain._walkArea.Points[self.i].X, brain._walkArea.Points[self.i].Y, brain._walkArea.Points[self.i].Z)
		self.substate = 0
	end
	if self.substate == 0 then
		if not actor._isWalking then
			local d = Dist3D(brain._walkArea.Points[self.i].X, 0, brain._walkArea.Points[self.i].Z, actor._groundx, 0, actor._groundz)
			if d > 0.5 then
				-- try again
				--if debugMarek then Game:Print("try again") end
				if math.random(100) < 33 then
					actor:WalkTo(brain._walkArea.Points[self.i].X, brain._walkArea.Points[self.i].Y, brain._walkArea.Points[self.i].Z)
				else
					self.active = nil
				end
			else
				self.substate = 1
				actor:RotateToWithAnim(brain._walkArea.Points[self.i].A * 180/math.pi)
			end
		end
	end
	if self.substate == 1 then
		if not actor._isRotating and not actor._proc then
			actor:SetAnim("earthquake", false)
			actor._proc = CloneTemplate("TEarthquake.CProcess")
			if actor.stones and type(actor.stones) == "string" then
				actor.stones = getfenv()[actor.stones]
			end

			actor._proc:Init(actor._groundx, actor._groundy, actor._groundz, actor, actor.stones)
		end
		if actor._proc then
			if not actor._isAnimating then
				self.active = nil
				actor._proc.TimeOut = -1
				actor._proc:Update()
				actor._proc = nil
			else
				actor._proc:Update()
			end
		end
	end
end

function Vamp._CustomAiStates.earthqVamp:OnRelease(brain)
	self.active = nil
end

function Vamp._CustomAiStates.earthqVamp:Evaluate(brain)
	if self.active or brain._submode == "earthq" then
		return 0.5
	end
	return 0
end


function Vamp:OnThrow()
	ENTITY.PO_EnableGravity(self._objTakenToThrow._Entity, false)
end
