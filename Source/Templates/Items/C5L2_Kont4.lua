function o:OnCreateEntity()
	self:AddTimer("Start",1.0)
end

function o:Start()
    MDL.SetRagdollLinearDamping(self._Entity,0.8)
    MDL.SetRagdollAngularDamping(self._Entity,0.8)
    MDL.EnableRagdoll(self._Entity,true,ECollisionGroups.RagdollNonColliding)
	local j = MDL.GetJointIndex(self._Entity, "joint4_getmass")
	ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 0.1, 0.2)
	self._snd = false
    self._lastTimeSound = 0
	self:ReleaseTimers()
end


function C5L2_Kont4:OnDamage()
	if not self._disableDamageSelf then
		if Explosion_012 then
			Explosion_012:OnLaunch()
			self._disableDamageSelf = true
		end
	end
end

function C5L2_Kont4:fend()
	ENTITY.EnableCollisions(self._Entity, false)		-- nie dziala!
	MDL.SetPinned(self._Entity, true)
	self:ReleaseTimers()
	self._lastTimeSound = 99999
end

function C5L2_Kont4:Update()
    if self.timer then
        self.timer = self.timer - 1
        if self.timer < 0 then
			--local j = MDL.GetJointIndex(self._Entity, "joint4_getmass")
            --ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 1000.0, 2000)
            -- self.OnUpdate = nil
            self._disableDamage = true			-- narazie, pozniej wylaczac kolizje
            --ENTITY.EnableCollisions(self._Entity, false)
            --Game:Print("disable damage !!!!!!!!!!!!!!!!!!!!!")
            --local j = MDL.GetJointIndex(self._Entity, "joint4_getmass")
			--ENTITY.EnableCollisionsToRagdoll(self._Entity, j, 1.0, 2.0)
			self:AddTimer("fend",5.0)
            self.timer = nil
        end
    end
end

function C5L2_Kont4:OnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl)	--e.he
	if self._lastTimeSound + 12 < Game.currentTime and vl > 1.0 then
		PlaySound3D("impacts/klapa-wybuch",x,y,z, math.random(4,20), 50)
		self._lastTimeSound = Game.currentTime + math.random(10,22)
	end
	
	if not self._disableDamage then
		if e_other then
			local obj = EntityToObject[e_other]
			if obj and obj.OnDamage then
				obj:OnDamage(self.RagdollCollDamage, self)
				if obj._deathTimer then
					obj._deathTimer = 0
				end
				--if obj == Player and self.s_SubClass.Sounds and self.s_SubClass.Sounds.damageByRagdoll then
				--	self:PlayRandomSound2D(self.s_SubClass.Sounds.damageByRagdoll)
				--end
				if not self._snd then		-- pozniej min. co 0.5 sek?
					local s = {"impacts/gib_big","impacts/gib_big2","impacts/gib_big3"}
					local snd = s[math.random(1,3)]
					PlaySound3D("impacts/klapa-wybuch-ver2",x,y,z, 40, 120)
					PlaySound3D(snd, x,y,z, 40, 120)
					self._snd = true
					self._lastTimeSound = Game.currentTime
				end
				if not self.timer then
					self.timer = 30
				end
			end
		end
	end
end
