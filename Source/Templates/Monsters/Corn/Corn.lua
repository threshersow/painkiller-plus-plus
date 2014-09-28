function o:OnInitTemplate()
    self:SetAIBrain()
end


function o:OnCreateEntity()
    local brain = self._AIBrain
	brain._lastPfxTime = brain._currentTime
    self._PosPoisonTime = 0
end

function o:CustomUpdate()
	local brain = self._AIBrain
	if brain._lastPfxTime + 0.8 < brain._currentTime then
		local no = math.random(1,3)
		self:BindFX("ambient"..no)
        --self:PlaySound("pimpleBurst")
		brain._lastPfxTime = brain._currentTime + FRand(0,0.6)
		local fx = self.s_SubClass.ParticlesDefinitions["ambient"..no]
		self._PosPoison = Vector:New(self:GetJointPos(fx.joint))
        self._PosPoisonTime = 10
	end
	
	
	if math.random(100) < 20 and Player and self._PosPoisonTime > 0 and not Player._poisoned then
        self._PosPoisonTime = self._PosPoisonTime - 1
		--self._checkSpeed = 30/self.Poison.checkSpeed 
		local x,y,z = self._PosPoison.X, self._PosPoison.Y, self._PosPoison.Z
	
		local v = Vector:New(math.sin(self.angle), 0, math.cos(self.angle))
		v:Normalize()
		v:MulByFloat(self.s_Poison.Range)
	
		local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x+v.X,y,z+v.Z, x,y,z)
		if debugMarek then
			self.d1,self.d2,self.d3,self.d4,self.d5,self.d6 = x+v.X,y,z+v.Z, x,y,z
		end
		if e then
			local obj = EntityToObject[e]
			if obj then
				--Game:Print("gas hit "..obj._Name)
				if obj._Class == "CPlayer" then
					if not SOUND2D.IsPlaying(obj._oldSND) then
						obj._oldSND = PlaySound2D("hero/hero_poison"..math.random(1,3),nil,nil,true)
					end

					obj._poisoned = self.s_Poison.TimeOut
					obj._poisonedTime = 0
					obj._poison = self.s_Poison
					obj._DrawColorQuad = true
					obj._ColorOfQuad = Color:New(255, 10, 10)
					obj._QuadAlphaMax = 46
				end
			end
		end
	end
end

function o:CustomOnDeath()
	self._fx2 = self:BindFX("death")
    if self._objTakenToThrow then
        GObjects:ToKill(self._objTakenToThrow)
        self._objTakenToThrow = nil
    end
end

function o:CustomOnDeathUpdate()
	if self._fx2 and not self._gibbed then
		if math.random(100) < 20 and Player then
			self._checkSpeed = 30/self.Poison.checkSpeed 
			local x,y,z = ENTITY.GetPosition(self._fx2)
			local dist = Dist3D(x,y,z, Player._groundx,Player._groundy, Player._groundz)
			local distLast = 9999
			if self._fx_lastx then
				distLast = Dist3D(self._fx_lastx,self._fx_lasty,self._fx_lastz, Player._groundx,Player._groundy, Player._groundz)
			end
			if dist < self.Poison.Range or distLast < self.Poison.Range then
				--Game:Print("PLAYER poisoned")
                --Player:PlaySoundHit2D("hero/hero_poison"..math.random(1,3))
                
                if not SOUND2D.IsPlaying(Player._oldSND) then
	                Player._oldSND = PlaySound2D("hero/hero_poison"..math.random(1,3),nil,nil,true)
	            end
                
				Player._poisoned = self.Poison.TimeOut
				Player._poisonedTime = 0
				Player._poison = self.Poison
				Player._DrawColorQuad = true
				Player._ColorOfQuad = Color:New(255, 10, 10)
				Player._QuadAlphaMax = 50
			end

			self._fx_lastx = x
			self._fx_lasty = y
			self._fx_lastz = z
		end
	end
end
