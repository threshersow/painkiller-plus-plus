function Gladiator:OnInitTemplate()
    self:SetAIBrain()
end


function Gladiator:CustomOnDeath()
    ENTITY.UnregisterAllChildren(self._Entity, ETypes.ParticleFX)
end


function Gladiator:ShieldBlow(par3, par4)
	local br = self._AIBrain
	if br and br.r_closestEnemy and br.r_closestEnemy._Class == "CPlayer" then
		local aiParams = self.AiParams
		local dist = Dist3D(self._groundx, self._groundy, self._groundz, br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz)
		local angleAttack = math.atan2(br.r_closestEnemy._groundx - self._groundx, br.r_closestEnemy._groundz - self._groundz)
		local aDist = AngDist(self.angle, angleAttack)
		
		if dist <= aiParams.attackRange and math.abs(aDist) < aiParams.attackRangeAngle*math.pi/180 then
			local cam = aiParams.ShieldBlow
			Game._EarthQuakeProc:Add(br.r_closestEnemy._groundx, br.r_closestEnemy._groundy, br.r_closestEnemy._groundz, cam.cameraShakeTime, self.StompRange, cam.cameraShake * 0.1, cam.cameraShake)
			local x,y,z = CAM.GetAng()
			--x = math.mod(x, 360)
			--y = math.mod(y, 360)
			--z = math.mod(z, 360)
			x = x - cam.cameraMess.X * FRand(0.9, 1.1)
			y = y - cam.cameraMess.Y * FRand(0.9, 1.1)
			z = z - cam.cameraMess.Z * FRand(0.9, 1.1)
			CAM.SetAng(x,y,z)

            PlaySound2D(self._SoundDirectory.."zombie_shieldhit")
		end
	end
end




function o:CustomOnDamage(he,x,y,z,obj, damage, type)
    if type == AttackTypes.Demon then
        return false
    end

    if he then
        local t,e,j = PHYSICS.GetHavokBodyInfo(he)
        local jName = MDL.GetJointName(e,j)
        if jName == "sword1" or jName == "r_l_lokiec" then
            if type == AttackTypes.Shotgun or type == AttackTypes.MiniGun or type == AttackTypes.Painkiller then
				self:PlaySound({"$/actor/maso/maso_hit_impact1","$/actor/maso/maso_hit_impact2"},22,52)
            end
			return true
		end
	end
	return false
end