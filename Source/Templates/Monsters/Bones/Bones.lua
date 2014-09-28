function Bones:OnInitTemplate()
    self:SetAIBrain()
	--Game:Print("I'm Bones, James Bones")
	self._AIBrain._ready = false
end

function Bones:drainsoul()
	if Player and Player.SoulsCount and Player.SoulsCount > 0 then
		Player.SoulsCount = Player.SoulsCount - 1
	end
end

function Bones:OnApply()
	if self.Animation == "enter" then
		MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0.0)
		MDL.SetMeshVisibility(self._Entity, "pCubeShape1", false)
		self.disableNoAnimDetection = true
		self._disableHits = true
	end
end

function Bones:PlaySoundAttack()
	if self._snd then
		local e = ENTITY.GetPtrByIndex(self._snd)
		if e then
			ENTITY.Release(self._snd)		-- pozniej fade
		end
		self._snd = nil
	end
	local snd
	snd, self._snd = self:BindRandomSound("attack")
end

function Bones:OnSetAnim(anim)
	if anim ~= "atak2" then
		if self._snd then
			local e = ENTITY.GetPtrByIndex(self._snd)
			if e then
				ENTITY.Release(e)		-- pozniej fade
			end
			self._snd = nil
		end
	end
end

function Bones:Explode()
	self._explode = true
	self._disableDeathSounds = true
	self:OnDamage(self.Health + 1000, self)
end

function Bones:CustomOnDeathAfterRagdoll()
	if self._gibbed or self._explode then		-- narazie self_explode
		local fx = self.s_SubClass.ParticlesDefinitions.bones
		if fx then
			for i,v in self.s_SubClass.DeathJoints do
				local pfx = self:AddPFX(fx.pfx,fx.scale)
				ENTITY.RegisterChild(self._Entity,pfx)
				PARTICLE.SetParentOffset(pfx,fx.offset.X,fx.offset.Y,fx.offset.Z,v)
			end
		end
		local x,y,z = self:GetJointPos("root")
		WORLD.Explosion2(x,y,z,1500,2.0,nil,AttackTypes.Grenade,0)
		self:PlaySound("explode")
	end
	MDL.SetMeshVisibility(self._Entity, "pCubeShape1", false)
	if self._glowfx then
		PARTICLE.Die(self._glowfx)
		self._glowfx = nil
	end
end

function Bones:GetThrowItemRotation()
	local q = Quaternion:New()
	q:FromEuler(0, -self.angle,0)	-- -self.angle - math.pi/2
	return q
end


--------------------------------

Bones._CustomAiStates = {}

Bones._CustomAiStates.wakeup = {
	name = "wakeup",
}
function Bones._CustomAiStates.wakeup:OnInit(brain)
	local actor = brain._Objactor
	local aiParams = actor.AiParams
    actor._DontCheckFloors = true
	if aiParams.activateTimer >= 0 then
		self.activateTimer = aiParams.activateTimer + math.random(0,30)
	end
	self.timer = 30
end

function Bones._CustomAiStates.wakeup:OnUpdate(brain)
	local actor = brain._Objactor
	if self.active then
		local speed = MDL.GetAnimTimeScale(actor._Entity, actor._CurAnimIndex)
		if speed == 0 or not actor._isAnimating or actor.Animation ~= "enter" then
			--actor:SetAnim("idle", false)
            if debugMarek then
                if actor._isAnimating then
                    Game:Print("koniec, bo "..speed.." "..actor.Animation)
                else
                    Game:Print("koniec, bo "..speed.." NIE ANIM")
                end
            end
			actor._isAnimating = false
			brain._ready = true
			actor._disableHits = false
			self.active = false
		end
	else
		if self.timer then
			self.timer = self.timer - 1
			if self.timer < 0 then
				ENTITY.PO_SetPinned(actor._Entity, true)
				self.timer = nil
			end
		end
		local aiParams = actor.AiParams
		if aiParams.activateOnEnemy and (brain.r_closestEnemy or brain._lastTimeHEAR) then
			MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, actor.s_SubClass.Animations.enter[1])
			MDL.SetMeshVisibility(self._Entity, "pCubeShape1", true)
			actor._glowfx = actor:BindFX("glow")
			self.active = true
			actor._animLoop = false
			return
		end
		if self.activateTimer then
			self.activateTimer = self.activateTimer - 1
			if self.activateTimer < 0 then
				MDL.SetAnimTimeScale(actor._Entity, actor._CurAnimIndex, actor.s_SubClass.Animations.enter[1])
				MDL.SetMeshVisibility(self._Entity, "pCubeShape1", true)
				actor._glowfx = actor:BindFX("glow")
				self.active = true
				actor._animLoop = false
				self.activateTimer = nil
			end
		end
	end
end

function Bones._CustomAiStates.wakeup:OnRelease(brain)
    local actor = brain._Objactor
    actor._DontCheckFloors = false
	ENTITY.PO_SetPinned(actor._Entity, false)
end

function Bones._CustomAiStates.wakeup:Evaluate(brain)
	if not brain._ready then
		return 0.9
	end
	return 0.0
end


function Bones:CustomOnHit()
	local aiParams = self.AiParams
	if not self._ABdo and self._AIBrain._ready then
		if self._HealthMax * aiParams.ABhp > self.Health and ENTITY.PO_IsOnFloor(self._Entity) then
			self._ABdo = 0
		end
	end
end


--------------------------
Bones._CustomAiStates.ABbones = {
	name = "ABbones",
}
function Bones._CustomAiStates.ABbones:OnInit(brain)
	local actor = brain._Objactor
	actor._disableHits = true
	actor:Stop()
	actor:RotateToVector(Player._groundx,Player._groundy,Player._groundz)
	self.mode = 0
end

function Bones._CustomAiStates.ABbones:OnUpdate(brain)
	local actor = brain._Objactor
	if self.mode == 0 and not actor._isRotating then
		actor:SetAnim("atak1",false)
		self.mode = 1
	end
	if self.mode == 1 then
		if not actor._isAnimating or actor.Animation ~= "atak1" then
			actor._ABdo = false
		end
	end
end

function Bones._CustomAiStates.ABbones:OnRelease(brain)
	local actor = brain._Objactor
	actor._ABdone = true
	actor._disableHits = false
	actor:OnDamage(actor.Health + 2, actor)
end

function Bones._CustomAiStates.ABbones:Evaluate(brain)
	local actor = brain._Objactor
	if actor._ABdo and actor._state ~= "ATTACKING" then
		return 0.55
	end
	return 0.01
end

