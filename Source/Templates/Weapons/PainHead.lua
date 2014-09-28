o.OnInitTemplate = CItem.StdOnInitTemplate

function PainHead:OnCreateEntity()

    ENTITY.EnableNetworkSynchronization(self._Entity,true,true,2)        
    local param = "n"
    if self._spinning then param = "s" end
        
    ENTITY.SetSynchroString(self._Entity,"PainHead.CItem"..":"..param)
    
    self:PO_Create(BodyTypes.Simple,0.01,ECollisionGroups.Noncolliding)
    ENTITY.RemoveFromIntersectionSolver(self._Entity)
    self.StartPos = Clone(self.Pos)        
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)    
    
    self:Client_OnCreateEntity(self._Entity,param)
    ENTITY.PO_SetMissile(self._Entity, MPProjectileTypes.PainHead )
end

--============================================================================
function PainHead:Client_OnCreateEntity(entity,param)
    if param == "s" then
        local t = Templates["PainKiller.CWeapon"]
        BindSoundToEntity(entity,t:GetSndInfo("rotor_loop"),10,40,true,nil,nil,nil,nil,0)   
    else
        local fx = AddPFX("FX_pain_2",0.5,Vector:New(0,0,0))
        ENTITY.RegisterChild(entity,fx,true)
        PARTICLE.SetParentOffset(fx,0,0,-0.1,nil)
    end
end
--============================================================================
function PainHead:OnPrecache()
	Cache:PrecacheParticleFX("FX_pain_2")
--    Cache:PrecacheDecal("splash")        
end

function PainHead:Trace(ex,ey,ez,sx,sy,sz)
    ENTITY.RemoveFromIntersectionSolver(self.ObjOwner._Entity)    
    if self.r_BindedActor and self.r_BindedActor._Entity then ENTITY.RemoveFromIntersectionSolver(self.r_BindedActor._Entity) end    
    local b,d,tx,ty,tz,nx,ny,nz,he,e = WORLD.LineTrace(ex,ey,ez,sx,sy,sz)    
    ENTITY.AddToIntersectionSolver(self.ObjOwner._Entity)    
    if self.r_BindedActor and self.r_BindedActor._Entity then ENTITY.AddToIntersectionSolver(self.r_BindedActor._Entity) end
    return b,d,tx,ty,tz,nx,ny,nz,he,e
end

function PainHead:Tick(delta)

    if self.ObjOwner._died or self.ObjOwner._ToKill then
        GObjects:ToKill(self)
        return
    end
    
    if self._back then -- powrot
        ENTITY.PO_Remove(self._Entity)
        local x,y,z = ENTITY.GetPosition(self._Entity)
        local px,py,pz = ENTITY.GetPosition(self.ObjOwner._Entity)   
        py = py+1.62
        local d = Dist3D(x,y,z,px,py,pz)
        
        if d <= 20 and not self._bsnd then
            Templates["PainKiller.CWeapon"]:Snd2D("head_back")
            self._bsnd = true
        end

        if d  < 1.5 then            
            GObjects:ToKill(self)
        else
            local dir = Vector:New(px,py,pz)
            dir:Sub(x,y,z)
            dir:Normalize()
            dir:MulByFloat(delta*self.BackSpeed)
            ENTITY.SetPosition(self._Entity,x+dir.X,y+dir.Y,z+dir.Z)
        end 
        return
    end
        
    if not ENTITY.PO_IsEnabled(self._Entity) then return end    
    
    local x,y,z = ENTITY.GetPosition(self._Entity)
    local vx,vy,vz,l  = ENTITY.GetVelocity(self._Entity)
    local dx,dy,dz  = vx/l, vy/l, vz/l -- znormalizowany kierunek         

    local d = Dist3D(x,y,z,self.StartPos.X,self.StartPos.Y,self.StartPos.Z)
    if d >= self.Range then 
        self._back = true
        return 
    end    
    
    -- wyliczam zakres trace'a
    self.Rot:FromEntity(self._Entity) 
    local x1,y1,z1 = self.Rot:TransformVector(0,0,-0.5)
    
    local sx,sy,sz = x+x1,y+y1,z+z1    
    if self._lastTraceStartPoint then
        ex,ey,ez = self._lastTraceStartPoint.X,self._lastTraceStartPoint.Y,self._lastTraceStartPoint.Z 
    else
        self._lastTraceStartPoint = Vector:New(sx,sy,sz)
    end    
    self._lastTraceStartPoint:Set(sx,sy,sz)
    
    -- czy w cos sie wbil?    
    local b,d,tx,ty,tz,nx,ny,nz,he,e = self:Trace(ex,ey,ez,sx,sy,sz)    
    
    local cg = ENTITY.PO_GetCollisionGroup(e)
    if CheckStartGlass(he,tx,ty,tz,0.3,vx,vy,vz) or cg==7 or cg==8 then
        return
    end
    
    -- tak, w cos uderzyl
    if e then 
        if ENTITY.IsWater(e) then 
--            ENTITY.SpawnDecal(e,'splash',tx,ty,tz,nx,ny,nz)
            Templates["PainKiller.CWeapon"]:Snd3D("head_hit_water",tx,ty,tz)
            self._back = true
            return
        end
        
        if ENTITY.IsFixedMesh(e) and not ENTITY.PO_IsFixed(e) then 
            self._back = true
            return
        end
        
        -- sprawdzam czy to entity posiada obiekt logiczny                
        local obj = EntityToObject[e]             

        if obj then                                
            -- sprawdzam czy trafilem w cialo czy w jakis odpadajacy element, np kosa czy naramiennik                
            if  obj._Class == "CActor" and not obj.stakeCanHitNotLinkedJoint then
                local joint = MDL.GetJointFromHavokBody(e,he)                
                local cb = MDL.JointsLinked(e,joint,MDL.GetJointIndex(e, "root"))               
                if not cb then cb = MDL.JointsLinked(e,joint,MDL.GetJointIndex(e, "k_sub_root")) end -- stare modele
                if not cb and not obj.DontTestRootLink then 
                    -- wyjmuje ten obiekt z havoka i ponawiam trace'a
                    local ohe = he
                    PHYSICS.RemoveHavokBodyFromIS(ohe,true)
                    b,d,tx,ty,tz,nx,ny,nz,he,e = self:Trace(ex,ey,ez,sx,sy,sz)
                    PHYSICS.RemoveHavokBodyFromIS(ohe,false)                         
                    --Game:Print("przelatuje: "..joint.." "..MDL.GetJointName(e,joint)) 
                    if not b or not (e and EntityToObject[e]) then return end -- przelatuje  
                    obj = EntityToObject[e]
                end
            end

            -- zadaje obrazenia
            if obj.OnDamage then
                obj:OnDamage(self.Damage,self.ObjOwner,AttackTypes.Painkiller,tx,ty,tz,nx,ny,nz,he)  
            end
   			if not PHYSICS.IsHavokBodyInWorld(he) then
				he = nil		-- jak sie np. zgibuje to jest robione ragdoll.remove i he moze byc zle
			end
        end                
        
        if not self._spinning then
            -- przesuwam srodek w punkt, w ktory sie wbil
            ENTITY.SetPosition(self._Entity,tx,ty,tz)        
            -- wylaczam fizyke
            ENTITY.PO_Remove(self._Entity)
            -- nadaje impuls trafionemu entity       
            if obj and (obj._Class == "CActor" or obj._Class == "CPlayer") and ENTITY.GetType(e) == ETypes.Model then --and  MDL.IsRagdoll(self._Entity) then                        
                local a = Dist3D(tx,ty,tz,self.StartPos.X,self.StartPos.Y,self.StartPos.Z)
                a = a * 0.65 * self.MonstersBackVelocity
                local j = MDL.GetJointFromHavokBody(e, he)
    
                -- wyrzucanie monetek
                if Game.GMode == GModes.SingleGame and not obj._gibbed and obj._enabledRD and not obj.disableFreeze then
                    if not obj._hitByPainCount then
                        if obj._diedByAttackType == AttackTypes.Painkiller then
                            obj._hitByPainCount = 0
                        else
                            obj._hitByPainCount = 1
                        end
                    else
                        obj._hitByPainCount = obj._hitByPainCount + 1
                        if obj._hitByPainCount >= self.ThrowItemFromBodyHitCount then
                            obj._hitByPainCount = 0
                            if not obj._treasuresGained then
                                obj._treasuresGained = 1
                            else
                                obj._treasuresGained = obj._treasuresGained + 1
                            end
                            if obj._treasuresGained <= self.ThrowItemFromBodyMaxCount then
                                local name = self.ThrowItemFromBody[math.random(1,table.getn(self.ThrowItemFromBody))]
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
                --
    
                local g, ge = self.ObjOwner:IsOnGround()
                if not g or EntityToObject[ge] ~= obj then                    
                    if Game.GMode == GModes.SingleGame then
                        if PHYSICS.IsHavokBodyPinned(he) or MDL.IsPinned(e) then
                            WORLD.HitPhysicObject(he,tx,ty,tz,dx*self.BackImpulse,dy*self.BackImpulse,dz*self.BackImpulse)
                        else
                            if j >= 0 then
                                MDL.ApplyVelocitiesToJointLinked(e,j,dx*a/10,dy*a/10 + 5, dz*a/10)
                            else
                                MDL.ApplyVelocitiesToAllJoints(e,dx*a/10,dy*a/10 + 5, dz*a/10)
                            end
                            PHYSICS.SetHavokBodyVelocity(he,dx*a, dy*a + 20, dz*a)                                
                        end
                    else
                        --WORLD.HitPhysicObject(he,x,y,z,fv.X*s.PhysicsImpulse*a,fv.Y*s.PhysicsImpulse*a,fv.Z*s.PhysicsImpulse*a)
                        local d = -5
                        ENTITY.SetVelocity(e,dx*d, 12, dz*d)            
                    end
                end
                            
                Templates["PainKiller.CWeapon"]:Snd3D("head_hit_enemy",tx,ty,tz)
                -- zrobic jednak liniowo, max 100 i proporcjonalnie zinterpolowac
            else
                --Game:Print("item")
                WORLD.HitPhysicObject(he,tx,ty,tz,dx*self.BackImpulse,dy*self.BackImpulse,dz*self.BackImpulse)
                --PHYSICS.SetHavokBodyVelocity(he,dx*self.Impulse,dy*self.Impulse,dz*self.Impulse)
                --ENTITY.SetVelocity(e,dx*self.Impulse,dy*self.Impulse,dz*self.Impulse)
                self.CL_HitWallSFX(self._Entity)
            end
            
            if not ENTITY.IsFixedMesh(e) then
                self._back = true
            end
        else
            if e and not (obj and (obj._Class == "CActor" or obj.DestroyPack)) then
                WORLD.HitPhysicObject(he,tx,ty,tz,dx*250,dy*250,dz*250)
                ENTITY.PO_Remove(self._Entity)
                self._back = true
                MDL.SetAnim(self._Entity,"close",false,1,0.2)
            end        
        end
    end
end

function PainHead:__Render()
    self.Rot:FromEntity(self._Entity) 
    local x,y,z = ENTITY.GetPosition(self._Entity)
    local x1,y1,z1 = self.Rot:TransformVector(0,0,0.5)
    local x2,y2,z2 = self.Rot:TransformVector(0,0,-0.5)
    
    R3D.RenderBox(x+x1-0.1,y+y1-0.1,z+z1,x+x1+0.1,y+y1+0.1,z+z1+0.1,2222)        
    R3D.RenderBox(x+x2-0.1,y+y2-0.1,z+z2,x+x2+0.1,y+y2+0.1,z+z2+0.1,1112)               
end

function PainHead:CL_HitWallSFX(e)
    Templates["PainKiller.CWeapon"]:SndEnt("head_hit_wall",e)
end
Network:RegisterMethod("PainHead.CL_HitWallSFX", NCallOn.AllClients, NMode.Unreliable, "e") 

