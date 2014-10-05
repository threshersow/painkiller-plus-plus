function Loki_Small_v3:CustomOnDeath()
	--self:Explode()
	self:PlaySound({'tick_big_explode'})
	GObjects:ToKill(self)

	local aiParams = self.AiParams
	for i=0,aiParams.throwItemCount do
		local x,y,z = self.Pos.X + FRand(-0.5,0.5), self.Pos.Y + FRand(0.1,1.0), self.Pos.Z + FRand(-0.5,0.5)
		local e = AddItem(aiParams.ThrowableItem, nil, Vector:New(x,y,z), true)
		
		local angle = math.random(0,360)
		local x = math.sin(angle) + math.cos(angle)
		local z = math.cos(angle) - math.sin(angle)
		local a = FRand(0.8,1.2)
		x = x * aiParams.meatforce[1] * a
		y = aiParams.meatforce[2] * FRand(0.8,1.2)
		z = z * aiParams.meatforce[3] * a

		MDL.ApplyVelocitiesToJointLinked(e, MDL.GetJointIndex(e,"root"), x,y,z, FRand(0,10),FRand(0,10),FRand(0,10))
	end
end

