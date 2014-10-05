function Loki:OnPrecache()
	Cache:PrecacheActor("Loki_Small.CActor")
end


function Loki:OnInitTemplate()
    self:SetAIBrain()
end


function Loki:UnBind()
	if self._spawnProcesses then
		for i,v in self._spawnProcesses do
			local obj = EntityToObject[v._tEntity]
			if obj then
                if not obj._died then
                    obj:OnUnbind()
                else
                    GObjects:ToKill(obj)
                end
			end
			GObjects:ToKill(v)
		end
		self._spawnProcesses = nil
	end
	self:EndTrailSword2()
end


function Loki:BindTrailSword2(name, joint1, joint2, joint3)
	if self._trailSword2 then
		Game:Print(self._Name.."  bylu JUZ TRAIL")
		ENTITY.Release(self._trailSword2)
	end
	self._trailSword2 = self:BindTrail(name, joint1, joint2, joint3)
end

function Loki:EndTrailSword2()
	if self._trailSword2 then
		ENTITY.Release(self._trailSword2)
		self._trailSword2 = nil
	end
end




Loki.CustomDelete = Loki.UnBind
Loki.CustomOnDeath = Loki.UnBind

function Loki:Spawn()
    if self._died then 
        if debugMarek then Game:Print(">>>>>>>>>>> cancel spawn bo dead") end
        return
    end
    local aiParams = self.AiParams

	self._spawnProcesses = {}
	for i=1, aiParams.SpawnCount do
		
		local Joint = MDL.GetJointIndex(self._Entity, self.s_SubClass.SpawnJoints[i])
		local x,y,z = MDL.TransformPointByJoint(self._Entity,Joint,0,0,0)

		local obj = GObjects:Add(TempObjName(),CloneTemplate("Loki_Small.CActor"))
		obj.Pos.X = x
		obj.Pos.Y = y
		obj.ObjOwner = self
		obj.Pos.Z = z
		local v = Vector:New(x - self.Pos.X, y - self.Pos.Y, z - self.Pos.Z)
		local force = aiParams.SpawnSpeed

		v.Y = math.abs(v.Y) * force
		v.X = v.X * force
		v.Z = v.Z * force
		obj.angle = math.atan2(v.X, v.Z)
		obj._angleDest = obj.angle

		obj:Apply()
		obj:Synchronize()

		--local _proc = PBindToJoint:New(obj._Entity,self._Entity,self.s_SubClass.SpawnJoints[i],0.0, 0.0, 0.0)
		--GObjects:Add(TempObjName(),_proc)
		
		local _proc = AddObject(Templates["PBindToJoint.CProcess"]:New(obj._Entity,self._Entity,self.s_SubClass.SpawnJoints[i],0.0, 0.0, 0.0))
		_proc.addVel = v
		obj._addVel = v
		--_proc.TimeToLive = aiParams.spawnTime
		table.insert(self._spawnProcesses, _proc)
	end
	--if debugMarek then
	--	MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0)
	--end
end

----------------------
Loki._CustomAiStates = {}

Loki._CustomAiStates.spawn = {
	name = "spawn",
	timer = nil,
	_lastTimeSpawn = 0,
}


function Loki._CustomAiStates.spawn:OnInit(brain)
	local actor = brain._Objactor
	--Game:Print("call")
	actor._disableHits = true
	actor:SetAnim("call",false)
	self.active = true
end

function Loki._CustomAiStates.spawn:OnUpdate(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
	if not actor._isAnimating then
		self.active = false
		--Game:Print("call end no anim")
	else
		if actor.Animation ~= "call" then
			self.active = false
			--Game:Print("call end inna anim "..actor.Animation)
		end
	end
	self._lastTimeSpawn = brain._currentTime
end

function Loki._CustomAiStates.spawn:OnRelease(brain)
	local actor = brain._Objactor
	self.active = false
    if actor._spawnProcesses then
        for i,v in actor._spawnProcesses do
            local obj = EntityToObject[v._tEntity]
            if obj then
                if not obj._died then
                    obj:OnUnbind()
                else
                    GObjects:ToKill(obj)
                end
			end
            GObjects:ToKill(v)
        end
        actor._spawnProcesses = nil
       	actor.DeathTimer = FRand(30,40)
    end
    actor:OnDamage(actor.Health + 2, actor)
end

function Loki._CustomAiStates.spawn:Evaluate(brain)
	if self.active then
		return 0.8
	end
    
	if self._lastTimeSpawn + 1.0 < brain._currentTime and brain._enemyLastSeenTime > 0 then
		self._lastTimeSpawn = brain._currentTime
		local actor = brain._Objactor
		if FRand(0.0, 1.0) < actor.AiParams.spawnChancePerSec then
			actor:Stop()
			actor._angleDest = actor.angle
			return 0.8
        end
	end
	return 0.0
end
