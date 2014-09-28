function C3L3_Truck:OnInitTemplate()
    self._Synchronize = self.Synchronize
    self.Synchronize = nil
end

function C3L3_Truck:OnCreateEntity()
    ENTITY.SetPosition( self._Entity, self.PosStart.X, self.PosStart.Y, self.PosStart.Z )
	self:PO_Create(BodyTypes.FromRagdoll)

	--self:PO_Create(BodyTypes.Simple, 0.2)
	MDL.SetRagdollCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)
	ENTITY.PO_SetCollisionGroup(self._Entity, ECollisionGroups.HCGNormalNCWithSelf)

	ENTITY.PO_SetFriction( self._Entity, 0.1 )    
    ENTITY.PO_SetAngularDamping( self._Entity, 0.99 )
--    ENTITY.PO_MaintainPosition( self._Entity, true, self.PosStart.X, self.PosStart.Y, self.PosStart.Z, 15.0 )
--    ENTITY.PO_EnableSpeedDamping( self._Entity, true, 3.0, 0.0, 0.5 )
----    ENTITY.PO_SetFreedomOfRotation( self._Entity, EFreedomsOfRotation.XAxis )
    ----ENTITY.RemoveRagdoll( self._Entity )
    ENTITY.PO_SetMovedByExplosions(self._Entity, false)
    ENTITY.PO_SetPinned( self._Entity, true )
    MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0 )
end


--function C3L3_Truck:Tick()
--	local x,y,z = ENTITY.GetVelocity(self._Entity)
--end

function C3L3_Truck:Update()

    if self.GoingState == self.TruckStates.Stopped then

        if self.Go then
            self.Go = false
            self.GoingState = self.TruckStates.Going
            ENTITY.PO_SetPinned( self._Entity, false )
            --ENTITY.PO_SetCollisionGroup( C3L3_Podstawka_001._Entity, ECollisionGroups.HCGNormalNCWithSelf)
            ENTITY.SetVelocity( self._Entity, 0, 0, 0 )
            self.CurSpeed = 0.0
            self._snd = self:BindSound("misc/car-move-loop", 15, 60, true,nil,nil,nil,nil,nil,true)
            SOUND3D.SetVolume(self._snd, 0)
            SOUND3D.SetVolume(self._snd, 100, 1.5)
        end

    else
        if self.GoingState == self.TruckStates.Going then

            local x,y,z = ENTITY.GetPosition( self._Entity )
            local distVec = Clone( self.PosStart )
            distVec:Sub( x, y, z )

            if distVec.Y > self.DistGoHoriz then
                --Game:Print( 'GoHorizontal - Pos: '..x..','..y..','..z )
                self.GoingState = self.TruckStates.GoingHorizontally
            end

            MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0.5*self.CurSpeed )
            if self.CurSpeed < self.MaxSpeed then
                self.CurSpeed = self.CurSpeed + self.Acceleration
                ENTITY.SetVelocity( self._Entity, self.SpeedVector.X*self.CurSpeed, self.SpeedVector.Y*self.CurSpeed, self.SpeedVector.Z*self.CurSpeed )
            end

        else
            if self.GoingState == self.TruckStates.GoingHorizontally then

                local x,y,z = ENTITY.GetPosition( self._Entity )
                local distVec = Clone( self.PosStart )
                distVec:Sub( x, y, z )
                distVec.Y = 0
                local len = distVec:Len()

                if len > self.DistGoFree then

                    --Game:Print( 'GoFree - Pos: '..x..','..y..','..z..' , len: '..len )
                    self.GoingState = self.TruckStates.GoingFree
                    self._TimerToPin = 0
                    MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0 )
                    
                    ENTITY.PO_MaintainLinearMovement( self._Entity, false )
                    ENTITY.PO_MaintainVelocity( self._Entity, false )

                    ENTITY.PO_SetLinearDamping( self._Entity, 0.95 )
                    --ENTITY.PO_SetAngularDamping( self._Entity, 0.99 )
                    --ENTITY.PO_SetHardDeactivator()

					PlaySound3D("impacts/hook-ground",x,y,z,60,120)
                    -- open the gates
                    MDL.EnableRagdoll(C3L3_Brama_001._Entity,true,ECollisionGroups.RagdollNonColliding)
                    if self._snd then
						ENTITY.Release(self._snd)
						self._snd = nil
                    end
                    
                    local action = {
                            {"Launch:fejkowywybuch"}, 
                        }
                        AddAction(action,self)
                        
                else
                    MDL.SetAnimTimeScale(self._Entity, self._CurAnimIndex, 0.5*self.CurSpeed )
                    ENTITY.SetVelocity( self._Entity, self.SpeedVector.X*self.CurSpeed, 0, self.SpeedVector.Z*self.CurSpeed )
                end
            else
                if self.GoingState == self.TruckStates.GoingFree then
                    self._TimerToPin = self._TimerToPin + 1
                    if self._TimerToPin >= 60 then
                        ENTITY.PO_SetPinned( self._Entity, true )
                        MDL.SetPinned( C3L3_Brama_001._Entity, true )
                        self.GoingState = self.TruckStates.Pinned                        
                        local action = {
                            {"Open:siatka"},
                            {"Open:siatka001"}, 
                            {"Open:siatka002"}, 
                            {"Open:siatka003"}, 
                        }
                        AddAction(action,self)
                    end
                end
                -- else self.GoingState == self.TruckStates.Pinned
            end
        end
    end
end
