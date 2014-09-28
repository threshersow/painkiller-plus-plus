--============================================================================
-- Item class
--============================================================================
CItem =
{
    Health = 50,
    Pack = "pudelka.dat",
    Mesh = "polySurfaceShape209",
    Model = nil,
    Pos = Vector:New(0.01,0.01,0.01),
    Rot = Quaternion:New(),
    ObjOwner = nil,
    --Type = 0,
    RespawnTime = nil,    
    Impulse =
    {
        Strength = 200,
        Pos = Vector:New(0,0,0),
        Rot = Quaternion:New(),
    },
    NotCountable = nil,
    --Friction = 1,		-- jest ustawiane domyslnie na 1 dla citem-ow w cobject.lua
    Scale = 1,
    Place = 0, -- 0 level, 1 bag, 2 hand
    _Rst = 0, -- respawn time counter
    _curAnimTime = 9999,

    DefaultMaterial = "";
    CubeMap = 
    {
        DefaultCubeTex = false,
        Tex = "",
    },
    DetailMap = 
    {
        DefaultDetailTex = true,
        Tex = "",
        TileMultiplier = 1,
    },
    NormalMap = 
    {
        DefaultNormalTex = false,
        Tex = "",
    },
	
    _Class = "CItem",    
    -- default explosion variables; not used until DestroyPack is not nil
    Destroy =
    {
        Effect  = nil,
        EffectScale  = 1,
        AverageDelay = 5,
        AverageVariation = nil, 
        ExplosionStrength = 0,
        ExplosionStrengthVariation = nil,
        ExplosionRadius = 6,
        ExplosionDamage = 200,
        Strength = 300,
        LifetimeAfterExplosion = 5, -- sec
        Radius = 6,
        --MonsterDamageModifier = 1.0,
        PartsNoncollidableWithSelf = false,
    },    

	s_SubClass = {
	},
}


Inherit(CItem,CObject)

--============================================================================
function CItem:OnClone(old)
    if old == CItem then 
        self.Pos = OppositeToCamera() 
    else
        self.Pos.X = old.Pos.X - 2
        self.Pos.Z = old.Pos.Z - 2
    end
    self._Entity = 0
 end
--============================================================================
function CItem:Delete()
    if self.OnRelease then
		self:OnRelease()
    end
    ENTITY.Release(self._Entity)
    self._Entity = nil    
end
--============================================================================
function CItem:Apply(old)

    --Game:Print(MPCfg.GameState)
    if MPCfg.GameState == GameStates.WarmUp or MPCfg.GameState == GameStates.Counting then
        if self.RespawnTime and self.RespawnTime <= 0 then
            self._mpWarmUp = true
        end
    end

    if self.PreApply then self:PreApply() end
    if not old or old.Mesh ~= self.Mesh or old.Model ~= self.Model or old.Scale ~= self.Scale then 
        ENTITY.Release(self._Entity)
        if self.Model and self.Model ~= "" then
            self._Entity = ENTITY.Create(ETypes.Model,self.Model,"",self.Scale*0.1)
            self._CurAnimIndex = MDL.SetAnim(self._Entity,"idle",true)    
        else
            self._Entity = ENTITY.Create(ETypes.Mesh,"../Data/Items/"..self.Pack,self.Mesh,self.Scale,not self.DontTranslateToZero)
            if self.DontLighting then
                MESH.SetLighting(self._Entity,false)
            end
        end    
                
        ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
        self.Rot:ToEntity(self._Entity)
        
        WORLD.AddEntity(self._Entity)        
        EntityToObject[self._Entity] = self

        if self.DestroyPack or (self.Destroy and self.Destroy.MinSpeedOnCollision) then -- automatycznie synchronizujemy wszytskie rozwalalne itemy
            ENTITY.EnableNetworkSynchronization(self._Entity,true,false,1)
        else
            self.Destroy = nil -- kasuja ta tablice, zeby sie nie sejwowala
        end

        if self.OnCreateEntity then self:OnCreateEntity() end        
        
        -- addditional for ragdolls
        if self.Mass then  ENTITY.PO_SetMass(self._Entity,self.Mass) end
        if self.InertiaTensorMultiplier then  ENTITY.PO_ScaleInertiaTensor(self._Entity,self.InertiaTensorMultiplier) end
        
        local coll = self.CollisionDetect
		if coll then
			if coll.joint then
				local j = MDL.GetJointIndex(self._Entity, coll.joint)
				if j < 0 then
					Game:Print(self._Name.." CollisionDetect, joint not found")
				end

				ENTITY.EnableCollisionsToRagdoll(self._Entity, j, coll.MinTime, coll.MinStren)
			else
				ENTITY.EnableCollisions(self._Entity, true, coll.MinTime, coll.MinStren)
			end
			self:ReplaceFunction("OnCollision","StdOnCollision")
		else
			if self.Destroy and self.Destroy.MinSpeedOnCollision and not self.OnCollision then
				local minVel = self.Destroy.MinSpeedOnCollision
				if self.s_SubClass.SoundsDefinitions and self.s_SubClass.SoundsDefinitions.SoundImpact then
					minVel = minVel * 0.2
				end
				ENTITY.EnableCollisions(self._Entity, true, 0.5, minVel)
				self:ReplaceFunction("OnCollision","StdOnCollision")
			end
		end
        
        if self.RagdollCreakSound then
            self:AddTimer("StdCreak",--[[self.RagdollCreakSound.checkSpeed--]]0.2)
            self._j = MDL.GetJointIndex(self._Entity, self.RagdollCreakSound.joint) 
            if self._j < 0 then
                Game:Print(self._Name.." RagdollCreakSound, joint not found")
            end
            self._delayCreak = nil
        end
        
        if self.s_SubClass.bindFX then			-- ### do cobject?
            local xx = {self.s_SubClass.bindFX}
            if type(self.s_SubClass.bindFX[1]) == "table" then 
                xx = self.s_SubClass.bindFX 
            end

            for i,v in xx do
                if not v[4] then v[4] = {0,0,0} end
                if not v[5] then v[5] = {} end
                self:BindFX(v[1],v[2],v[3],v[4][1],v[4][2],v[4][3],v[5][1],v[5][2],v[5][3]) 
            end
        end
        if self.RespawnTime then
			if not XBOX or Game.GMode ~= GModes.SingleGame then
	            self._RespawnPos = Clone(self.Pos)
		        self._RespawnRot = Clone(self.Rot)
			    self._RespawnHealth = self.Health
			end
        end
    else
        ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
        self.Rot:ToEntity(self._Entity)
    end

	CItem_ApplyTextures(self._Entity,self)
	
    self:ApplySpecular()
    self:ApplyFresnel()
	
    if self.TestDeathZone then ENTITY.EnableDeathZoneTest(self._Entity,true) end

    if self.Synchronize then self:Synchronize() end
    if self._Synchronize then self:_Synchronize() end

    if self.OnApply then self:OnApply(old) end
	if self.s_SubClass.SoundsDefinitions and self.s_SubClass.SoundsDefinitions.SoundImpact then
	    self._lastPlayedImpactSound = -1
		self._lastPlayedImpactSoundDelay = nil
	end

    if self.DefaultMaterial ~= "" then
        MESH.SetDefaultMaterial(self._Entity,self.DefaultMaterial);
    end

	if self.Model and self.shadow then
		MDL.CreateShadowMap(self._Entity, self.shadow)
	end

    if self.s_SubClass and self.s_SubClass.AnimActions and not self.Tick then
        self:ReplaceFunction("Tick","AnimActionTick")
        AddObjToTable(GObjects.TickListItems,self)
    end
end
--============================================================================
function CItem:PO_Create(bodytype,bodyscale,collisionGroup)
    if self.Synchronize then self:Synchronize() end
    if self._Synchronize then self:_Synchronize() end
    if not bodyscale then bodyscale = self.Scale end
    
    --local x,y,z =  ENTITY.GetPosition(self._Entity)
    --Game:Print("Pos = "..x.." "..y.." "..z)
    --Game:Print("self.Pos = "..self.Pos.X.." "..self.Pos.Y.." "..self.Pos.Z)
    if not ENTITY.PO_Exist(self._Entity) then
        CObject.PO_Create(self,bodytype,bodyscale,collisionGroup)
    end        
    -- local x,y,z =  ENTITY.GetPosition(self._Entity)
    --Game:Print("Pos = "..x.." "..y.." "..z)
    --Game:Print("self.Pos = "..self.Pos.X.." "..self.Pos.Y.." "..self.Pos.Z)
end
--============================================================================
function CItem:CheckDistFromPlayers(dist,delta)
   
    if MPCfg.GameState ~= GameStates.Playing and MPCfg.GameState ~= GameStates.WarmUp or self.Frozen then return end

	if not dist then
		dist = 2.0
	end
    
    -- optymalizacja dla singleplayera
    if not Game:IsServer() then
        if PLAYER.GetDistanceFromPoint(Player._Entity,self.Pos.X,self.Pos.Y-1,self.Pos.Z) <= dist then
        --local px,py,pz = ENTITY.GetPosition(Player._Entity)
        --if self.Pos:Dist(PX,PY+1,PZ) < dist then
			if ENTITY.IsDrawEnabled(self._Entity) then
				if self:OnTake(Player,delta) then return end
                if self._blockedBy then
                    self.Place = 1
                    CItem.Show(self._Entity,false)
                    -- zabije sie po skonczniu
                else
                    GObjects:ToKill(self)
                end
			end
        end
    else    
        local x,y,z = self.Pos:Get()
        for i,o in Game.Players do
            if not o._died then
                --local px,py,pz = ENTITY.GetPosition(o._Entity)
                if PLAYER.GetDistanceFromPoint(o._Entity,x,y-1,z) <= dist then
                    local ps = Game.PlayerStats[o.ClientID]
                    --if ps then
                    --    Game:Print(ps.Name .. " has taken item "..self._Name.." : "..self.BaseObj)
                    --end
                    if not self:OnTake(o) then
                        if not self.RespawnTime or (self.RespawnTime and self.RespawnTime <= 0) then
                            --MsgBox("kill")
                            GObjects:ToKill(self)                            
                            return
                        end                        
                        --MsgBox("show")
                        CItem.Show(self._Entity,false)
                            --ENTITY.Release(self._Entity)
                            --self._Entity = nil
   
                        self.Place = 1
     
			self._Rst = self.RespawnTime * 30 
			if Cfg.ItemRespawnFix then self._Rst = INP.GetTime() + self.RespawnTime end
			
                        break
                    end
                end
            end
        end
    end
    
    return -2
end

--function CItem:Tick(delta)
--end
--============================================================================
function CItem:StdOnInitTemplate()
    self:ReplaceFunction("Update","nil")
    self:ReplaceFunction("_Synchronize","Synchronize")
    self:ReplaceFunction("Synchronize","nil")
end
--============================================================================
function CItem:TryToRespawn(force)
    if force then 
        self._Rst = -1 
        self.Place = 1
    end
    if self.Place == 1 and not self._blockedBy then 
        --Game:Print(self._Rst)
        if not Cfg.ItemRespawnFix then self._Rst = self._Rst - 1 end  
        if self._Rst < 0 and self.RespawnTime and self.RespawnTime > 0 and not Cfg.ItemRespawnFix or Cfg.ItemRespawnFix and self._Rst < INP.GetTime() and self.RespawnTime and self.RespawnTime > 0  or Cfg.ItemRespawnFix and self.RespawnTime and math.abs(self._Rst - INP.GetTime()) > self.RespawnTime + 1 then
            self.Place = 0
            self._Rst = 0 
            self.Pos = Clone(self._RespawnPos)
            self.Rot = Clone(self._RespawnRot)
            self.Health = self._RespawnHealth
            if self._Entity then
                ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
                self.Rot:ToEntity(self._Entity)
                CItem.ShowAndPos(self._Entity,true,true,self.Pos.X,self.Pos.Y,self.Pos.Z)
            else
                self:Apply()
            end
            if not force and self.OnRespawn then self.OnRespawn(self._Entity) end
        end        
    end
end
--============================================================================
function CItem:Update()
    if self.OnUpdate then self:OnUpdate() end
    
    if self.OnTake and self.Place == 0 then 
        self:CheckDistFromPlayers(self.takeDistance, delta)
    end

    self:TryToRespawn()
    
    if self.TimeToLive then
		if self.TimeToLive > 0 then
			self.TimeToLive = self.TimeToLive - 1
		else
			GObjects:ToKill(self)
		end
	end
end
--============================================================================
function CItem:Synchronize()
    if not self._Entity then return end    
    -- synchronization with  C++ object
    if not ENTITY.PO_Exist(self._Entity) then
        ENTITY.SetPosition(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z)
        self.Rot:ToEntity(self._Entity)
    else
        self.Pos.X,self.Pos.Y,self.Pos.Z = ENTITY.GetPosition(self._Entity)
    end
    self.Rot:FromEntity(self._Entity)
end
--============================================================================
function CItem:OnDamage( damage, owner, attacktype, x, y, z, nx, ny, nz, he )
    if self.Immortal or not self._Entity then return end
    if self.CustomOnDamage then
		if self:CustomOnDamage(damage, owner, attacktype, x, y, z, nx, ny, nz, he) then
			return
		end
    end
    if self.Health > 0 then
		--[[if debugMarek then
            if self.Pack then
                Game:Print(self._Name.." damage "..damage.." "..self.Pack)
            else
                Game:Print(self._Name.." damage "..damage)
            end
        end]]
		if owner ~= self and self.Destroy then
			self.Destroy._Strength = nil
		end
        self.Health = self.Health - damage
        --if self.Damaged.Pack and self.Damaged.Health and self.Damaged.Mesh and self.Health > 0 and self.Health <= self.Damaged.Health then
        --    tempEnt = ENTITY.DamageItem( self._Entity, "../Data/Items/"..self.Damaged.Pack, self.Damaged.Mesh )            
        --    if tempEnt then
        --        EntityToObject[self._Entity] = nil
        --        self._Entity = tempEnt
        --        EntityToObject[self._Entity] = self
        --    end
        --    self.Damaged.Health = nil
        --else
        if self.Health <= 0 then
            if self.CustomOnDeath then
				self:CustomOnDeath(x,y,z)
            end
            if attacktype == AttackTypes.OutOfLevel then
				GObjects:ToKill(self)
				return
            end

            if self.enableGibWhenHPBelow and self.Model then
				local gib = MDL.MakeGib(self._Entity, ECollisionGroups.RagdollNonColliding, self.gibGetVelFromJoint)
				if gib then
					self._CurAnimIndex = 0
					self._gibbed = true
					ENTITY.RemoveRagdoll( self._Entity )
					ENTITY.EnableDraw( self._Entity, false, true )
					ENTITY.Release( self._Entity )
					self._Entity = gib
					EntityToObject[self._Entity] = self
					if self.CustomOnGib then
						self:CustomOnGib()
					end
					local rcoll = self.s_SubClass.RagdollCollisionsGib
                    self._raggDollPrecomputedCollData = {}

					if rcoll then
						for i,v in rcoll.Bones do
							local j = MDL.GetJointIndex(self._Entity, v[1])
							if j >= 0 then
								ENTITY.EnableCollisionsToRagdoll(self._Entity, j, rcoll.MinTime, rcoll.MinStren)
								self._raggDollPrecomputedCollData[j] = {v[2], v[3]}
							else
								if debugMarek then
									Game:Print(self._Name.." set ragdoll col. joint not found: "..v[1])
								end
							end
						end
						self:ReplaceFunction("OnCollision","StdRagdollOnCollision")
					end
					
				else
					GObjects:ToKill(self)
				end
				return
				
            end
            -- entity, destroy pack, strength, radius, owner, weapon_type
            if self.Destroy and not self.Destroy._Timer and self._Entity and self.DestroyPack then
                if not self.NotCountable and not self.AddedToDestroyedCounter then
                    Game.PlayerDestroyedItems = Game.PlayerDestroyedItems + 1
                    self.AddedToDestroyedCounter = true
                end
                if attacktype == AttackTypes.OutOfLevel then
					GObjects:ToKill(self)
					return
                end
                self.Destroy._Owner = owner
                self.Destroy._AttackType = attacktype
                if not ( attacktype == AttackTypes.Explosion ) then
                    self:AddTimer("DestroyMe",0)
                else
                    local tm = self.Destroy.AverageDelay / 30
                    if self.Destroy.AverageVariation and self.Destroy.AverageVariation > 0 then
                        tm = FRand( self.Destroy.AverageDelay-self.Destroy.AverageVariation, self.Destroy.AverageDelay+self.Destroy.AverageVariation )
                        if tm < 1 then tm = 1 end
                        tm = tm /30
                    end
                    self:AddTimer("DestroyMe",tm)
                end
            end
        end
        --end
    end
end
--============================================================================
function CItem:BindFX(name,scale,joint,ox,oy,oz,cox,coy,coz)
	if self.s_SubClass and self.s_SubClass.ParticlesDefinitions then
		local fx = self.s_SubClass.ParticlesDefinitions[name]
		if fx then
			name = fx.pfx
			scale = fx.scale
			joint = fx.joint
			if offset then
				ox = offset.X
				oy = offset.Y
				oz = offset.Z
			end
		end
	end
    return BindFX(self._Entity,name,scale,joint,ox,oy,oz,cox,coy,coz)
end
--============================================================================
function CItem:ApplySpecular(other)
    if not self.s_SubClass then return end    
	if not self.Model then return end
	if self.Model == "" then return end
	
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
function CItem:ApplyFresnel(other)
    if not self.s_SubClass then return end    
	if not self.Model then return end
	if self.Model == "" then return end
	
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
function CItem:DestroyMe()
    if self.Destroy then
        if self.Synchronize then self:Synchronize() end
        if self._Synchronize then self:_Synchronize() end

        local radius = 0
        -- physical explosion
        if self.Destroy.ExplosionStrength > 0 then
            local strength = 0
            if self.Destroy.ExplosionStrengthVariation and self.Destroy.ExplosionStrengthVariation > 0 then
                strength = FRand(self.Destroy.ExplosionStrength-self.Destroy.ExplosionStrengthVariation,self.Destroy.ExplosionStrength+self.Destroy.ExplosionStrengthVariation)
            else
                strength = self.Destroy.ExplosionStrength
            end        
   			if strength > 0 then
                --if self.Destroy.ExplosionRadiusVariation and self.Destroy.ExplosionRadiusVariation > 0 then
                --    radius = FRand(self.Destroy.ExplosionRadius-self.Destroy.ExplosionRadiusVariation,self.Destroy.ExplosionRadius+self.Destroy.ExplosionRadiusVariation)
                --else
                    radius = self.Destroy.ExplosionRadius
                --end                

                if radius > 0 then
					ENTITY.PO_Enable(self._Entity,false)
                    Explosion(self.Pos.X,self.Pos.Y,self.Pos.Z,strength,radius,nil,AttackTypes.Explosion,self.Destroy.ExplosionDamage)
                end
            end
        end
        

        -- DestroyFX
        if Game.GMode == GModes.SingleGame then
            CItem.DestroyItemFX(self._Entity,self._Name,radius)
        elseif self.BaseObj ~= "CItem" and Templates[self.BaseObj] then
            local tml = Templates[self.BaseObj]
            if tml then CItem.DestroyItemFX(self._Entity,self.BaseObj,radius) end
        end


        -- treasures & throw items - only in single player mode
        if Game.GMode == GModes.SingleGame then
            if self.OnDestroy then self:OnDestroy() end
            if self.Destroy.Treasures then GenerateTreasures(self,self.Destroy.Treasures) end
            if self.Destroy.ThrowItem then
                local count = 1
                if self.Destroy.ThrowItemCount then
                    count = self.Destroy.ThrowItemCount
                end
                local x,y,z = ENTITY.GetPosition(self._Entity)
                for i=1,count do
                    local name = self.Destroy.ThrowItem
                    if type(name) == "table" then
                        name = name[math.random(1,table.getn(name))]
                    end
                    local obj = GObjects:Add(TempObjName(),CloneTemplate(name))
                    local rnd = 0.25
                    if self.Destroy.ThrowItemSpread then
						rnd = self.Destroy.ThrowItemSpread
                    end
                    obj.Pos.X = x + FRand(-rnd, rnd)
                    obj.Pos.Y = y + FRand( 0.0, rnd)
                    obj.Pos.Z = z + FRand(-rnd, rnd)
                    
                    obj:Apply()
                    if obj.Synchronize then
						obj:Synchronize()
					else
						if obj._Synchronize then
							obj:_Synchronize()
						end
					end
                end
                self.Destroy.ThrowItem = nil
            end
        end
        if self.CustomOnDeathAfterDestroy then
			self:CustomOnDeathAfterDestroy()
		end

        if self.RespawnTime and self.RespawnTime > 0 then
            -- respawn
            EntityToObject[self._Entity] = nil
            ENTITY.Release(self._Entity)            
            self._Entity = nil
            self:ReleaseTimers()
            self.Place = 1             
            self._Rst = self.RespawnTime * 30 
            if Cfg.ItemRespawnFix then self._Rst = INP.GetTime() + self.RespawnTime end
            
        else
            -- kill object
            GObjects:ToKill(self)
        end
            
    end
end
--============================================================================
function CItem:DestroyItemFX(entity,tmlname,radius)
                
        local tml = FindObj(tmlname)        
        if not tml then return end
        
        local dInfo = tml.Destroy        
        local x,y,z = ENTITY.GetWorldPosition(entity)	--ENTITY.GetPosition(entity)
        
        -- EarthQuake
        Game._EarthQuakeProc:Add(x,y,z,6,radius,false)

        -- particle fx
        if dInfo.Effect then 
            AddPFX(dInfo.Effect,dInfo.EffectScale,Vector:New(x,y,z)) 
        end
        -- explode entity on client
        local strength2 = dInfo.Strength
        --if dInfo.StrengthVariation > 0 then
        --    strength2 = FRand(dInfo.Strength-dInfo.StrengthVariation,dInfo.Strength+dInfo.StrengthVariation)
        --end
        if dInfo._Strength then
			strength2 = dInfo._Strength * FRand(0.9, 1.1)
        end
        --Game:Print("ENTITY.ExplodeItem")
        
        if dInfo.VelocityFactor then
            local vx,vy,vz = ENTITY.GetVelocity(entity)
            ENTITY.SetVelocity(entity,vx*dInfo.VelocityFactor.X,vy*dInfo.VelocityFactor.Y,vz*dInfo.VelocityFactor.Z)
        end
        
        ENTITY.PO_Enable(entity,false)
		--Game:Print(tml._Name.." expl i "..strength2)
        local _oneOfDestroyed = ENTITY.ExplodeItem(entity, "../Data/Items/"..tml.DestroyPack, strength2, dInfo.Radius, dInfo.LifetimeAfterExplosion, nil, dInfo.BindEffectTo, dInfo.PartsNoncollidableWithSelf)

		local parts = WORLD.GetLastExplodedEntities(entity)
		for i,o in parts do
			CItem_ApplyTextures(o,tml)
		end

        -- add some fire to burned item
        if tml._burning or dInfo.BurningParts then 
            local parts = WORLD.GetLastExplodedEntities(entity)
            for i,o in parts do
                if math.random(0,1) == 1 then
                    local pfx = AddPFX('barrel_part_FX',FRand(0.15,0.2))
                    local ox,oy,oz = MESH.GetRandomPoint(o)
                    PARTICLE.SetParentOffset(pfx,ox,oy,oz)
                    ENTITY.RegisterChild(o,pfx) 
                end
            end
        end

        if dInfo.BindEffect and _oneOfDestroyed then 
			for i,v in dInfo.BindEffect do
                local p = tml.s_SubClass.ParticlesDefinitions[v]
				local e = ENTITY.GetPtrByIndex(_oneOfDestroyed)
				if e then
					local x,y,z = ENTITY.GetWorldPosition(e)
					local fx = AddPFX(p.pfx,p.scale,Vector:New(x,y,z)) 
					if fx then
						ENTITY.RegisterChild(e,fx,true)
						PARTICLE.SetParentOffset(fx,p.offset.X,p.offset.Y,p.offset.Z)
					end
				end
			end
		end
        
		tml:Snd3D("DestroySound",x,y,z)

        --light
        if dInfo.Light then
            AddAction({{"Light:a[1],a[2],a[3],255,255,150, 8, 10 , 1, 0.01,0.05,0.01"}},nil,nil,x,y+0.5,z)
        end
end
Network:RegisterMethod("CItem.DestroyItemFX", NCallOn.ServerAndAllClients, NMode.Reliable, "esf") 
--============================================================================
function AddItem(template,scale,pos,collect,rot)
    local obj = CloneTemplate(template)
    if scale then obj.Scale = obj.Scale * scale end
    if pos then obj.Pos:Set(pos) end
	if rot then obj.Rot = Clone(rot) end
    obj:Apply()
    obj._dontFirstApply = true
    if not collect then
        EntityToObject[obj._Entity] = nil        
    else
        GObjects:Add(TempObjName(),obj)
    end
    return obj._Entity,obj
end
--============================================================================
function CItem:InDeathZone(x,y,z,zone)

    if string.find(zone,"wat",1,true) then
        if not self.SmallWaterSplash then
            AddObject("FX_splash.CActor",1.5,Vector:New(x,y,z),nil,true)        
        else
            AddPFX("HaingunHitWater",0.3,Vector:New(x,y,z))
        end
        local snd = "impacts/water-splash"..math.random(1,3)
        if self.SoundInWater then snd = self.SoundInWater end
        PlaySound3D(snd,x,y,z,20,50)
    end

    ENTITY.RemoveFromIntersectionSolver(self._Entity)
--    local b,d,dx,dy,dz,nx,ny,nz,he,e = WORLD.LineTrace(x,y+5,z,x,y-5,z)    
--    if b and e and ENTITY.IsWater(e) then
--        ENTITY.SpawnDecal(e,'splash_big',dx,dy,dz,0,1,0)
--    end
    
--    Game:Print(self._Name.." IN DEATH ZONE")
    if not self._ToKill then
--		if self.DestroyPack and not self.NotCountable then
--            Game.PlayerDestroyedItems = Game.PlayerDestroyedItems + 1
--            Log("Destroyed item "..self._Name.."\n")
--        end
        self.Immortal = nil
        if self.OnDamage then
			--Game:Print(self._Name.." IN DEATH ZONE 99999")
			self:OnDamage(99999,nil,AttackTypes.OutOfLevel)
		else
			--Game:Print(self._Name.." IN DEATH ZONE to kill")
			GObjects:ToKill(self)
		end
        --GObjects:ToKill(self)
    end
end
-------------------------------------------------------------------------------
function CItem:StdOnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl,velocity_me, velocity_other)
	local o = EntityToObject[e_other]

	if self.CustomOnCollision then
		if self:CustomOnCollision(e_other, velocity_me, velocity_other, x,y,z) then
			return
		end
	end
	if self._giveDamageOnCollision then
		if o and o.OnDamage then
			o:OnDamage(self._giveDamageOnCollision * FRand(0.8,1.1), self.ObjOwner)
		end
		self._giveDamageOnCollision = nil
    end

	
	if self.killOnCollision then
		ENTITY.EnableCollisions(self._Entity, false)
		self:OnDamage(self.Health + 2)
		return
	end
	
	if self.Destroy and self.Destroy.MinSpeedOnCollision then
        vl = vl * INP.GetTimeMultiplier()
		if vl >= self.Destroy.MinSpeedOnCollision or self._onCollsionDestroy then
			
			if self._onCollsionDestroy then
				self.Destroy._Strength = nil
				self:OnDamage(self.Health + 1, self, AttackTypes.ItemCollision, x,y,z,nx,ny,nz)
			else
				local s = (vl - self.Destroy.MinSpeedOnCollision)/self.Destroy.MinSpeedOnCollision
				if s > 1 then
					s = 1
				end
				if s < 0.1 then
					s = 0.1
				end
				self.Destroy._Strength = self.Destroy.Strength * s
				--Game:Print(self._Name.." >>>>> self.Destroy.Strength = "..self.Destroy._Strength)
                if self.OnDamage then
                    self:OnDamage(vl * 0.3, self, AttackTypes.ItemCollision)
                end
			end
		end
		--local x1,y1,z1 = ENTITY.GetVelocity(self._Entity)
		--if debugMarek then Game:Print(self._Name.." ITEM col "..vl.." "..self.Destroy.MinSpeedOnCollision.." "..vy.." vlme "..velocity_me.." vlother"..velocity_other.." ny= "..ny) end
		--if debugMarek then Game:Print(self._Name.." Predkosc "..x1.." "..y1.." "..z1) end
		
		local enableSound = true
		if o and o._Class and o._Class == "CPlayer" then
			if velocity_me < velocity_other and vl < self.Destroy.MinSpeedOnCollision then
				enableSound = false
			end
		end
		
		if self.Health > 0 and enableSound and (math.abs(vy) > self.Destroy.MinSpeedOnCollision * 0.1 or ny < 0.9) and self.s_SubClass.SoundsDefinitions then		-- zeby pchany item nie mial dzwieku kolizji
			local si = self.s_SubClass.SoundsDefinitions.SoundImpact
			if self.Destroy and si then
				--[[local name = si[math.random(1,table.getn(si))]

                local res = string.find(name,"$/")
                local sndDir = "impacts/"
		 
                if res then
                    name = string.gsub(name,"$/","")
                    sndDir = ""
                end--]]

				if self._lastPlayedImpactSoundDelay then
					if self._lastPlayedImpactSoundDelay + self.SoundImpactMinDelay*30 < Game.currentTime then
						self._lastPlayedImpactSoundDelay = nil
					end
				end
				if not self._lastPlayedImpactSoundDelay then
					if not SOUND3D.IsPlaying(self._lastPlayedImpactSound) then
						self._lastPlayedImpactSound = self:Snd3D("SoundImpact",x,y,z)
						
						local volume = 100
						local max = self.Destroy.MinSpeedOnCollision * 0.7
						if vl < max then
							volume = 100 - (max - vl)/max * 90
						end
						
						--if debugMarek then Game:Print(self._Name.." volume "..volume) end
						
						SOUND3D.SetVolume(self._lastPlayedImpactSound, volume)
						if self.SoundImpactMinDelay then
							self._lastPlayedImpactSoundDelay = Game.currentTime
						end
					end
				end
			end
		end
	end
	local col = self.CollisionDetect
	if col then
		--if debugMarek then Game:Print(self._Name.." ITEM collisiondetect0 "..vy) end
		if vy < -col.MinStren * 0.2 or col.enableShuffle then
			if not col.myVelocityMustBeGreater or velocity_me > velocity_other then
				if self._lastPlayedImpactSoundDelay then
					if self._lastPlayedImpactSoundDelay + self.SoundImpactMinDelay*30 < Game.currentTime then
						self._lastPlayedImpactSoundDelay = nil
					end
				end
				if not self._lastPlayedImpactSoundDelay then
					if not SOUND3D.IsPlaying(self._lastPlayedImpactSound) then
						self._lastPlayedImpactSound = self:Snd3D("collisiondetect",x,y,z)
						if self.SoundImpactMinDelay then
							self._lastPlayedImpactSoundDelay = Game.currentTime
						end
					end
				end
			end
		end
	end
end
-------------------------------------------------------------------------------
function CItem:DropOut()
   	local angle = math.random(0,360)
	local x = math.sin(angle) + math.cos(angle)
	local z = math.cos(angle) - math.sin(angle)
	local y = FRand(1.5, 2.0)
	x = x * self.force[1]
	y = y * self.force[2]
	z = z * self.force[3]
	self:PO_Create(BodyTypes.FromMesh,nil,ECollisionGroups.InsideItems)
	ENTITY.SetAngularVelocity(self._Entity, self.rotate[1]*FRand(0.9,1.1), self.rotate[2]*FRand(0.7,1.2), self.rotate[3]*FRand(0.9,1.1))
	ENTITY.PO_SetAngularDamping(self._Entity, self.angularDamping)
	ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    ENTITY.RemoveFromIntersectionSolver(self._Entity) 
	ENTITY.PO_Hit(self._Entity,self.Pos.X,self.Pos.Y,self.Pos.Z,x,y,z)
	self.TimeToLive = self.TimeToLive * FRand(0.8, 1.1)
    self.OnDamage = nil
end
--============================================================================
function CItem:Show(entity,show)
    if show then
		ENTITY.UpdatePart(entity)
	end
    ENTITY.EnableDraw(entity,show,true)
end
-------------------------------------------------------------------------------
Network:RegisterMethod("CItem.Show", NCallOn.ServerAndAllClients, NMode.Reliable, "eB")
--============================================================================
function CItem:ShowAndPos(entity,show,setpos,x,y,z)
    if setpos then
        ENTITY.SetPosition(entity,x,y,z)
    end
    if show then
		ENTITY.UpdatePart(entity)
	end
    ENTITY.EnableDraw(entity,show,true)
end
-------------------------------------------------------------------------------
Network:RegisterMethod("CItem.ShowAndPos", NCallOn.ServerAndAllClients, NMode.Reliable, "eBBfff")
--============================================================================
function CItem:OnRespawn(entity)
    if not Cfg.LowQualityMultiplayerSFX then
        local x,y,z = ENTITY.GetPosition(entity)
        AddObject("FX_ItemRespawn.CActor",1,Vector:New(x,y,z),nil,true) 
    end
end
-------------------------------------------------------------------------------
Network:RegisterMethod("CItem.OnRespawn", NCallOn.AllClients, NMode.Reliable, "e")
--============================================================================
function CItem:Client_OnTake(eplayer,eitem,tml)
    local template = Templates[tml..".CItem"]
    local player = EntityToObject[eplayer]
    if player then        
        if template.BonusItemValue then
			player.BonusItems = player.BonusItems + template.BonusItemValue
			player.Money = player.Money + template.BonusItemValue
			Game.PlayerMoney = Game.PlayerMoney + template.BonusItemValue
			Game.PlayerMoneyFound = Game.PlayerMoneyFound + template.BonusItemValue * Game.TreasureFoundFactor
		elseif template.Value then
			player.Money = player.Money + template.Value
			Game.PlayerMoney = Game.PlayerMoney + template.Value
			Game.PlayerMoneyFound = Game.PlayerMoneyFound + template.Value * Game.TreasureFoundFactor
		end

        if not template.isHolyItem then
			Game.PlayerCoinsFound = Game.PlayerCoinsFound + 1 -- XXX ? dlaczego to jest w Game
		else
			Player.HolyItems = Player.HolyItems + 1
		end
        player:PickupFX()
    end    
    local x,y,z = ENTITY.GetPosition(eitem)    
    template:Snd3D("SoundTake",x,y,z)
end
-------------------------------------------------------------------------------
Network:RegisterMethod("CItem.Client_OnTake", NCallOn.ServerAndSingleClient, NMode.Reliable, "ees")
--============================================================================

function CItem:StdCreak()
	if self._gibbed then return end
    local s = self.RagdollCreakSound
	if self._soundSample then
		if not SOUND3D.IsPlaying(self._soundSample) then
			if self._delayCreak then
				self._delayCreak = self._delayCreak - 0.2 --s.checkSpeed
				if self._delayCreak > 0 then
					return
				else
					self._soundSample = nil
					self._delayCreak = nil
				end
			else
				self._soundSample = nil
			end
		else
			return
		end
	end
	
	
    local vx,vy,vz,vl,ax,ay,az,al = MDL.GetVelocitiesFromJoint(self._Entity,self._j)
    if s.angular then
		vx = ax
		vy = ay
		vz = az
		vl = al
    end
    local x,y,z = MDL.GetJointPos(self._Entity, self._j)
    --if debugMarek and vl > 0.01 then
    --    Game:Print(vx.." "..vy.." "..vz.." "..vl)
    --end
	  if vl > s.minVel then
		self._soundSample = self:Snd3D("CreakSound",x,y,z)
		--if debugMarek then Game:Print("pl "..sample.." "..self._soundSample) end
		self._delayCreak = s.minDelayBetweenSounds
        --
    end
end

function CItem:AddPFX(effect,scale,pos,rot,norm)
	if self.disablePFX then return end
	if self.s_SubClass.ParticlesDefinitions then
		local ef = self.s_SubClass.ParticlesDefinitions[effect]
		if ef then
			effect = ef.pfx
			if ef.scale then
				scale = ef.scale
			end
			pos = Clone(self.Pos)
			if ef.offset then
				pos.X = pos.X + ef.offset.X
				pos.Y = pos.Y + ef.offset.Y
				pos.Z = pos.Z + ef.offset.Z
			end
			if ef.joint then
				pos = Vector:New(self:GetJointPos(ef.joint))
			end
		end
	end
	return AddPFX(effect,scale,pos,rot,norm)
end

function CItem_ApplyTextures(e,obj)
	-- apply textures
	if not obj.Model or obj.Model=="" then 
        
        if not obj.DetailMap then return end

		local u = Lev.DetailMap.TileU*obj.DetailMap.TileMultiplier
		local v = Lev.DetailMap.TileV*obj.DetailMap.TileMultiplier
	
		if obj.DetailMap.DefaultDetailTex then
			MESH.SetDetailMap(e,Lev.DetailMap.Tex,u,v)
		else
			MESH.SetDetailMap(e,obj.DetailMap.Tex,u,v)
		end

		if obj.CubeMap.DefaultCubeTex then
			MESH.SetCubeMap(e,Lev.CubeMap.Tex)
		else
			MESH.SetCubeMap(e,obj.CubeMap.Tex)
		end		

		if obj.NormalMap.DefaultNormalTex then
			MESH.SetNormalMap(e,Lev.NormalMap.Tex)
		else
			MESH.SetNormalMap(e,obj.NormalMap.Tex)
		end		
	end
end

function CItem:StdRagdollOnCollision(x,y,z,nx,ny,nz,e_other,h_me,h_other,vx,vy,vz,vl, velocity_me, velocity_other)	--e.he
	local j = MDL.GetJointFromHavokBody(self._Entity, h_me)

	--[[if self.CustomOnRagdollCollision then
		self:CustomOnRagdollCollision(x,y,z,nx,ny,nz,j)
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
	end--]]
	
	if j and j ~= -1 then
		if self._raggDollPrecomputedCollData[j] then
            local name	-- = ""

            if self._frozen then
				name = "frozenSplash"
			else
				name = self._raggDollPrecomputedCollData[j][1]
			end
			
            self:PlaySound(name,nil,nil,nil,nil,x,y,z)
       		if self._raggDollPrecomputedCollData[j][2] and not self._frozen and not self.notBleeding then
                self:BloodFX(x,y,z)		-- dodac cos zeby rozmazywalo np. uzaleznic od predkosci
            end
		end
	end
end

function CItem:AnimActionTick(delta)    
    --Game:Print(MDL.GetAnimTime(self._Entity,self._CurAnimIndex))
    local tm = MDL.GetAnimTime(self._Entity,self._CurAnimIndex)
    if self._curAnimTime > tm then
        local action = self.s_SubClass.AnimActions["idle"]    
        AddAction(action,self)
        --Game:Print(tm)
    end
    self._curAnimTime = tm    
end