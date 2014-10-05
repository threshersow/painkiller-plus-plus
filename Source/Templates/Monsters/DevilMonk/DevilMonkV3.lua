function DevilMonkV3:OnCreateEntity()
	self._AIBrain._lastThrowTime = FRand(-20, -10)
	self:ReplaceFunction("CustomUpdate", nil)
	self:ReplaceFunction("CustomOnDeathUpdate",nil)
end

function DevilMonkV3:Render(delta)
	if self._drawLighing then
		self._s0 = self._s0 + delta
		--R3D.DrawSprite1DOF(self._s1,self._s2,self._s3,self._s4,self._s5,self._s6,0.08,R3D.RGB(0,0,255),"particles/trailkolek") 
		if self._s0 > 0.05 then
			self._drawLighing = nil
		end
		
	    local d = Templates["ElectroDisk.CItem"]
		local p = VectorA:New(self._s1,self._s2,self._s3,0)
		local x,y,z = ENTITY.GetPosition(self._Entity)
		d:RenderFX(self._s4,self._s5,self._s6,p)
		--d:RenderFX(0,0,0,p)
		
	end
end


function DevilMonkV3:lighting()
	-- trace przed siebie
	local x,y,z = self:GetJointPos("dlo_lewa_root")
	self._s0 = 0.0
	self._s1 = x
	self._s2 = y
	self._s3 = z
	AddPFX(self.lightingFX, 0.3, Vector:New(x,y,z))
	self._drawLighing = true
	local v = Vector:New(self._targetX - x, self._targetY - y, self._targetZ - z)
	v:Normalize()
	v:MulByFloat(self.AiParams.lightingDist)
	self._s4 = PX	--x + v.X
	self._s5 = PY	--y + v.Y 
	self._s6 = PZ	--z + v.Z

	--ENTITY.RemoveRagdollFromIntersectionSolver(self._Entity)
	local b,d,xcol,ycol,zcol,nx,ny,nz,he,e = WORLD.LineTraceHitPlayerBalls(x,y,z, Player.Pos.X,Player.Pos.Y + 1.0,Player.Pos.Z)
	--ENTITY.AddRagdollToIntersectionSolver(self._Entity)
	if b and e then
    	CheckStartGlass(he,xcol,ycol,zcol,0.4, xcol, ycol, zcol)

		local r = Quaternion:New(1,0,0,0)
		local ay = math.atan2(nx,-nz) + 1.57
		r:FromEuler(0,ay,-1.57 + ny*1.57)    
		AddPFX("DM3spellhit",0.5,Vector:New(xcol,ycol,zcol),r)
		
		local obj = EntityToObject[e]
		 --self.d1 = xcol
		 --self.d2 = ycol
		 --self.d3 = zcol
		 --DEBUG1, DEBUG2, DEBUG3, DEBUG4, DEBUG5, DEBUG6 = xcol, ycol, zcol, x,y,z
        --Game:Print("ONDAMAGE lighting?")
		if obj and obj.OnDamage then
            --Game:Print("ONDAMAGE lighting")
			obj:OnDamage(self.AiParams.lightingDamage, self)
		--else
		--	Game:Print("ONDAMAGE no obj")
		end
		self._s4 = xcol
		self._s5 = ycol
		self._s6 = zcol

	end
	self._targetX = nil
	self._targetY = nil
	self._targetZ = nil
end

function DevilMonkV3:lockTarget()
	self._targetX = Player._groundx
	self._targetY = Player._groundy + 1.6
	self._targetZ = Player._groundz
	self:RotateToVector(self._targetX, self._targetY, self._targetZ)
end
